#!/usr/bin/env python3
"""Toy CLI wrapper over find/grep/bash expansion workflows."""

from __future__ import annotations

import argparse
import os
import selectors
import shlex
import signal
import subprocess
import sys
import threading
import time
from dataclasses import dataclass
from typing import BinaryIO, List

DEFAULT_TIMEOUT_SECONDS = 30
HARD_TIMEOUT_SECONDS = 300
DEFAULT_MAX_OUTPUT_BYTES = 64 * 1024
HARD_MAX_OUTPUT_BYTES = 1024 * 1024
DEFAULT_MAX_OUTPUT_LINES = 10_000
HARD_MAX_OUTPUT_LINES = 100_000
DEFAULT_MAX_COMMAND_LENGTH = 8 * 1024
HARD_MAX_COMMAND_LENGTH = 32 * 1024
SHELL_PATH = "/bin/bash"
OUTPUT_LIMIT_MARKER = "[powersearch] output limit exceeded; stream truncated\n"


class ValidationError(ValueError):
    """User input failed CLI validation."""


class PlanningError(ValueError):
    """Request could not be translated into a supported plan."""


class ResourceLimitError(RuntimeError):
    """Execution exceeded a configured resource limit."""


class ConcurrentExecutionError(RuntimeError):
    """Only one subprocess group may run at a time."""


class TimeoutExecutionError(RuntimeError):
    """Execution exceeded the configured wall time."""


@dataclass(frozen=True)
class SearchRequest:
    mode: str
    roots: List[str]
    name_glob: str | None
    path_expr: str | None
    file_type: str | None
    max_depth: int | None
    pattern: str | None
    ignore_case: bool
    context: int
    dry_run: bool


@dataclass(frozen=True)
class ExecutionPlan:
    command: str
    timeout_seconds: int = DEFAULT_TIMEOUT_SECONDS
    max_output_bytes: int = DEFAULT_MAX_OUTPUT_BYTES
    max_output_lines: int = DEFAULT_MAX_OUTPUT_LINES
    max_command_length: int = DEFAULT_MAX_COMMAND_LENGTH
    shell: str = SHELL_PATH


@dataclass(frozen=True)
class ExecutionResult:
    exit_code: int
    timed_out: bool = False
    resource_exhausted: bool = False
    startup_failed: bool = False
    error_message: str | None = None


class CLIAdapter:
    @staticmethod
    def parse_args() -> SearchRequest:
        parser = argparse.ArgumentParser(
            prog="powersearch",
            description="Friendly wrapper around find, grep, and bash expansion",
        )
        parser.add_argument("mode", choices=["scan", "match", "combo", "preview"])
        parser.add_argument("--roots", nargs="+", default=["."], help="Search roots")
        parser.add_argument("--name", dest="name_glob", help="find -name pattern")
        parser.add_argument("--path", dest="path_expr", help="Bash expansion path expression")
        parser.add_argument("--type", dest="file_type", choices=["f", "d"], help="find -type")
        parser.add_argument("--max-depth", type=int, help="find -maxdepth")
        parser.add_argument("--pattern", help="grep pattern")
        parser.add_argument("-i", "--ignore-case", action="store_true", help="grep -i")
        parser.add_argument("-C", "--context", type=int, default=0, help="grep -C")
        parser.add_argument("--dry-run", action="store_true", help="Print generated command only")

        args = parser.parse_args()

        if args.max_depth is not None and args.max_depth < 0:
            raise ValidationError("--max-depth must be >= 0")
        if args.context < 0:
            raise ValidationError("--context must be >= 0")

        return SearchRequest(
            mode=args.mode,
            roots=args.roots,
            name_glob=args.name_glob,
            path_expr=args.path_expr,
            file_type=args.file_type,
            max_depth=args.max_depth,
            pattern=args.pattern,
            ignore_case=args.ignore_case,
            context=args.context,
            dry_run=args.dry_run,
        )


class Planner:
    @staticmethod
    def _quote_many(values: List[str]) -> str:
        return " ".join(shlex.quote(v) for v in values)

    @staticmethod
    def _effective_mode(req: SearchRequest) -> str:
        if req.mode != "preview":
            return req.mode
        if req.pattern:
            return "match" if req.path_expr else "combo"
        return "scan"

    @classmethod
    def build_plan(cls, req: SearchRequest) -> ExecutionPlan:
        find_parts = ["find", cls._quote_many(req.roots)]
        if req.max_depth is not None:
            find_parts.append(f"-maxdepth {req.max_depth}")
        if req.file_type:
            find_parts.append(f"-type {shlex.quote(req.file_type)}")
        if req.name_glob:
            find_parts.append(f"-name {shlex.quote(req.name_glob)}")

        find_cmd = " ".join(find_parts)

        grep_parts = ["grep", "-n"]
        if req.ignore_case:
            grep_parts.append("-i")
        if req.context > 0:
            grep_parts.extend(["-C", str(req.context)])
        if req.pattern is not None:
            grep_parts.append(shlex.quote(req.pattern))
        grep_cmd = " ".join(grep_parts)

        mode = cls._effective_mode(req)
        if mode == "scan":
            command = find_cmd
        elif mode == "match":
            if not req.pattern:
                raise PlanningError("--pattern is required for match mode")
            target = req.path_expr or cls._quote_many(req.roots)
            command = f"{grep_cmd} {target}"
        elif mode == "combo":
            if not req.pattern:
                raise PlanningError("--pattern is required for combo mode")
            command = f"{find_cmd} -print0 | xargs -0 {grep_cmd}"
        else:
            raise PlanningError(f"unsupported mode: {mode}")

        if len(command) > HARD_MAX_COMMAND_LENGTH:
            raise PlanningError(f"command length exceeds hard limit ({HARD_MAX_COMMAND_LENGTH} bytes)")

        return ExecutionPlan(command=command)


class TelemetrySink:
    events: list[dict[str, object]] = []

    @classmethod
    def record(cls, event: str, **payload: object) -> None:
        try:
            cls.events.append(
                {
                    "event": event,
                    "timestamp": time.time(),
                    **payload,
                }
            )
        except Exception:
            return

    @classmethod
    def reset(cls) -> None:
        cls.events.clear()


class OutputStreamer:
    @classmethod
    def stream(
        cls,
        proc: subprocess.Popen[bytes],
        *,
        timeout_seconds: int,
        max_output_bytes: int,
        max_output_lines: int,
        telemetry: type[TelemetrySink] = TelemetrySink,
        stdout_sink: BinaryIO | None = None,
        stderr_sink: BinaryIO | None = None,
    ) -> tuple[bool, bool]:
        selector = selectors.DefaultSelector()
        assert proc.stdout is not None
        assert proc.stderr is not None
        stdout_sink = stdout_sink or sys.stdout.buffer
        stderr_sink = stderr_sink or sys.stderr.buffer
        selector.register(proc.stdout, selectors.EVENT_READ, ("stdout", stdout_sink))
        selector.register(proc.stderr, selectors.EVENT_READ, ("stderr", stderr_sink))

        total_lines = 0
        bytes_by_stream = {"stdout": 0, "stderr": 0}
        timed_out = False
        resource_exhausted = False
        start = time.monotonic()

        try:
            while selector.get_map():
                if time.monotonic() - start > timeout_seconds:
                    timed_out = True
                    telemetry.record("timeout", timeout_seconds=timeout_seconds, pid=proc.pid)
                    Executor._terminate_process_group(proc, telemetry=telemetry)
                    break

                events = selector.select(timeout=0.2)
                for key, _ in events:
                    chunk = key.fileobj.read1(4096)
                    if not chunk:
                        selector.unregister(key.fileobj)
                        continue

                    channel, sink = key.data
                    bytes_by_stream[channel] += len(chunk)
                    total_lines += chunk.count(b"\n")
                    sink.write(chunk)
                    sink.flush()
                    telemetry.record("stream_chunk", channel=channel, size=len(chunk))

                    if (
                        bytes_by_stream[channel] > max_output_bytes
                        or total_lines > max_output_lines
                    ):
                        resource_exhausted = True
                        sink.write(OUTPUT_LIMIT_MARKER.encode("utf-8"))
                        sink.flush()
                        telemetry.record(
                            "stream_limit_exceeded",
                            channel=channel,
                            bytes=bytes_by_stream[channel],
                            lines=total_lines,
                        )
                        Executor._terminate_process_group(proc, telemetry=telemetry)
                        break

                if resource_exhausted:
                    break
        finally:
            selector.close()

        return timed_out, resource_exhausted


class Executor:
    _active_run_lock = threading.Lock()

    @staticmethod
    def _terminate_process_group(
        proc: subprocess.Popen[bytes],
        grace_seconds: float = 1.5,
        telemetry: type[TelemetrySink] = TelemetrySink,
    ) -> None:
        try:
            os.killpg(proc.pid, signal.SIGTERM)
            telemetry.record("term_sent", pid=proc.pid)
        except ProcessLookupError:
            return

        deadline = time.monotonic() + grace_seconds
        while time.monotonic() < deadline:
            if proc.poll() is not None:
                return
            time.sleep(0.05)

        try:
            os.killpg(proc.pid, signal.SIGKILL)
            telemetry.record("kill_sent", pid=proc.pid)
        except ProcessLookupError:
            return

    @classmethod
    def run(cls, plan: ExecutionPlan, telemetry: type[TelemetrySink] = TelemetrySink) -> ExecutionResult:
        if not cls._active_run_lock.acquire(blocking=False):
            raise ConcurrentExecutionError("concurrent subprocess groups are not allowed")

        timeout_seconds = min(plan.timeout_seconds, HARD_TIMEOUT_SECONDS)
        max_output_bytes = min(plan.max_output_bytes, HARD_MAX_OUTPUT_BYTES)
        max_output_lines = min(plan.max_output_lines, HARD_MAX_OUTPUT_LINES)

        try:
            proc = subprocess.Popen(
                [plan.shell, "-lc", plan.command],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                start_new_session=True,
            )
        except OSError as exc:
            cls._active_run_lock.release()
            return ExecutionResult(exit_code=1, startup_failed=True, error_message=str(exc))

        telemetry.record("process_started", pid=proc.pid, pgid=proc.pid, command=plan.command)

        try:
            timed_out, resource_exhausted = OutputStreamer.stream(
                proc,
                timeout_seconds=timeout_seconds,
                max_output_bytes=max_output_bytes,
                max_output_lines=max_output_lines,
                telemetry=telemetry,
            )
        finally:
            proc.wait()
            telemetry.record("cleanup_complete", pid=proc.pid, returncode=proc.returncode)
            cls._active_run_lock.release()

        if timed_out:
            telemetry.record("process_failed", reason="timeout", pid=proc.pid)
            return ExecutionResult(exit_code=124, timed_out=True, error_message="execution timed out")
        if resource_exhausted:
            telemetry.record("process_failed", reason="resource_limit", pid=proc.pid)
            return ExecutionResult(
                exit_code=125,
                resource_exhausted=True,
                error_message="output limits exceeded",
            )
        telemetry.record("process_exited", pid=proc.pid, exit_code=proc.returncode)
        return ExecutionResult(exit_code=proc.returncode)


class Presenter:
    @staticmethod
    def show_plan(command: str) -> None:
        print(f"[powersearch] {command}")

    @staticmethod
    def show_error(message: str) -> None:
        print(message, file=sys.stderr)

    @staticmethod
    def show_no_matches() -> None:
        print("No matches found")


class ExitPolicy:
    @staticmethod
    def from_execution(result: ExecutionResult) -> int:
        if result.timed_out:
            return 124
        if result.resource_exhausted:
            return 125
        if result.startup_failed:
            return 1
        return result.exit_code


def main() -> int:
    try:
        req = CLIAdapter.parse_args()
        plan = Planner.build_plan(req)
    except (ValidationError, PlanningError) as exc:
        Presenter.show_error(str(exc))
        return 2
    except Exception as exc:
        Presenter.show_error(f"internal error: {exc}")
        return 1

    Presenter.show_plan(plan.command)

    if req.dry_run or req.mode == "preview":
        return 0

    try:
        result = Executor.run(plan)
    except ConcurrentExecutionError as exc:
        Presenter.show_error(str(exc))
        return 125

    if result.error_message:
        Presenter.show_error(result.error_message)
    if result.exit_code == 1:
        Presenter.show_no_matches()
    return ExitPolicy.from_execution(result)


if __name__ == "__main__":
    raise SystemExit(main())
