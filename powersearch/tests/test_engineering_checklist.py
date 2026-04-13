import sys
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

import main as powersearch


def test_cli_adapter_parses_valid_args(monkeypatch):
    monkeypatch.setattr(
        sys,
        "argv",
        [
            "powersearch",
            "scan",
            "--roots",
            "src",
            "tests",
            "--name",
            "*.py",
            "--max-depth",
            "2",
            "--context",
            "1",
            "--dry-run",
        ],
    )

    req = powersearch.CLIAdapter.parse_args()

    assert req.mode == "scan"
    assert req.roots == ["src", "tests"]
    assert req.name_glob == "*.py"
    assert req.max_depth == 2
    assert req.context == 1
    assert req.dry_run is True


@pytest.mark.parametrize(
    "argv, message",
    [
        (["powersearch", "scan", "--max-depth", "-1"], "--max-depth must be >= 0"),
        (["powersearch", "scan", "--context", "-1"], "--context must be >= 0"),
    ],
)
def test_cli_adapter_rejects_invalid_values(monkeypatch, argv, message):
    monkeypatch.setattr(sys, "argv", argv)

    with pytest.raises(ValueError, match=message):
        powersearch.CLIAdapter.parse_args()


def test_search_request_is_frozen():
    req = powersearch.SearchRequest("scan", ["."], None, None, None, None, None, False, 0, False)

    with pytest.raises(Exception):
        req.mode = "match"  # type: ignore[misc]


def test_planner_is_deterministic():
    req = powersearch.SearchRequest(
        mode="combo",
        roots=["src", "tests"],
        name_glob="*.py",
        path_expr=None,
        file_type=None,
        max_depth=2,
        pattern="needle",
        ignore_case=True,
        context=3,
        dry_run=False,
    )

    plan1 = powersearch.Planner.build_plan(req)
    plan2 = powersearch.Planner.build_plan(req)

    assert plan1 == plan2


def test_planner_happy_paths_match_current_translation():
    scan = powersearch.SearchRequest("scan", ["."], "found.txt", None, None, None, None, False, 0, False)
    match = powersearch.SearchRequest("match", ["."], None, "*.txt", None, None, "hello", False, 0, False)
    combo = powersearch.SearchRequest("combo", ["src"], "*.txt", None, None, None, "needle", False, 0, False)
    preview = powersearch.SearchRequest("preview", ["."], None, "*.txt", None, None, "hello", False, 0, False)

    assert powersearch.Planner.build_plan(scan).command == "find . -name found.txt"
    assert powersearch.Planner.build_plan(match).command == "grep -n hello *.txt"
    assert powersearch.Planner.build_plan(combo).command == "find src -name '*.txt' -print0 | xargs -0 grep -n needle"
    assert powersearch.Planner.build_plan(preview).command == "grep -n hello *.txt"


def test_exit_policy_uses_execution_exit_code():
    result = powersearch.ExecutionResult(exit_code=125, resource_exhausted=True)
    assert powersearch.ExitPolicy.from_execution(result) == 125


def test_main_returns_internal_failure_as_nonzero(monkeypatch):
    monkeypatch.setattr(
        powersearch.CLIAdapter,
        "parse_args",
        staticmethod(lambda: (_ for _ in ()).throw(RuntimeError("boom"))),
    )
    assert powersearch.main() == 1


def test_planner_enforces_allowed_shell_executable_allowlist():
    req = powersearch.SearchRequest("scan", ["."], None, None, None, None, None, False, 0, False)
    assert powersearch.Planner.build_plan(req).shell == "/bin/bash"


def test_planner_enforces_hard_command_length_limit():
    req = powersearch.SearchRequest("scan", ["."], "x" * (powersearch.HARD_MAX_COMMAND_LENGTH + 1), None, None, None, None, False, 0, False)
    with pytest.raises(ValueError, match="command length exceeds hard limit"):
        powersearch.Planner.build_plan(req)


def test_planner_rejects_unsupported_mode_combinations():
    req = powersearch.SearchRequest("match", ["."], None, None, None, None, None, False, 0, False)
    with pytest.raises(ValueError, match="--pattern is required for match mode"):
        powersearch.Planner.build_plan(req)

    req = powersearch.SearchRequest("combo", ["."], None, None, None, None, None, False, 0, False)
    with pytest.raises(ValueError, match="--pattern is required for combo mode"):
        powersearch.Planner.build_plan(req)


@pytest.mark.skip(reason="not implemented yet: concurrent subprocess guard")
def test_executor_rejects_concurrent_subprocess_groups():
    pass


@pytest.mark.skip(reason="not implemented yet: output streamer abstraction")
def test_output_streamer_streams_incrementally():
    pass


@pytest.mark.skip(reason="not implemented yet: output streamer abstraction")
def test_output_streamer_bounds_buffered_bytes():
    pass


@pytest.mark.skip(reason="not implemented yet: output streamer abstraction")
def test_output_streamer_bounds_emitted_lines():
    pass


@pytest.mark.skip(reason="not implemented yet: output streamer abstraction")
def test_output_streamer_emits_overflow_marker():
    pass


@pytest.mark.skip(reason="not implemented yet: telemetry sink abstraction")
def test_telemetry_sink_records_lifecycle_events():
    pass


def test_presenter_renders_previews_summaries_and_errors_consistently(capsys):
    powersearch.Presenter.show_plan("find .")
    powersearch.Presenter.show_error("bad news")
    powersearch.Presenter.show_no_matches()

    captured = capsys.readouterr()
    assert "[powersearch] find ." in captured.out
    assert "No matches found" in captured.out
    assert "bad news" in captured.err


@pytest.mark.skip(reason="not implemented yet: no-zombie integration test")
def test_executor_always_reaps_child_processes():
    pass


@pytest.mark.skip(reason="not implemented yet: wall-time and timeout harness coverage")
def test_executor_enforces_wall_time_and_timeout():
    pass


@pytest.mark.skip(reason="not implemented yet: descendant termination verification")
def test_executor_terminates_descendants_on_timeout():
    pass
