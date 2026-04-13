# Executive Summary

`powersearch` is a toy CLI that makes `find`, `grep`, and bash expansion easier to use without hiding how they work. This specification is the engineering source of truth for implementation constraints, component boundaries, and runtime safety.

This document intentionally emphasizes **how** the software is built (ownership, process control, failure semantics, and observability), not only **what** user-facing features exist.

Core engineering goals:

1. Keep each entity single-purpose with explicit input/output contracts.
2. Make entity wiring explicit and deterministic.
3. Bound resource usage (process count, buffered output, execution time).
4. Guarantee child-process lifecycle hygiene (no zombies, no runaway subprocess trees).
5. Preserve transparency with reproducible command plans and structured diagnostics.

# List of entities

- **CLIAdapter**
  - Concern starts: parsing argv into strongly validated options.
  - Concern ends: emits immutable `SearchRequest` or validation errors.
  - Forbidden concerns: shell construction, process execution.

- **SearchRequest (value object)**
  - Concern starts: represent normalized user intent.
  - Concern ends: immutable data transfer between layers.
  - Forbidden concerns: business decisions, side effects.

- **Planner**
  - Concern starts: convert `SearchRequest` into `ExecutionPlan`.
  - Concern ends: returns declarative command graph + safety metadata.
  - Forbidden concerns: launching processes, rendering user output.

- **ExecutionPlan (value object)**
  - Concern starts: encode one or more commands, pipelines, and limits.
  - Concern ends: handoff contract for execution.
  - Forbidden concerns: mutable runtime state.

- **Executor**
  - Concern starts: execute an `ExecutionPlan` with resource/time limits.
  - Concern ends: emits `ExecutionResult` and guarantees process cleanup.
  - Forbidden concerns: argument parsing, planning logic.

- **OutputStreamer**
  - Concern starts: stream stdout/stderr incrementally to avoid memory bloat.
  - Concern ends: forwards bounded chunks/events to Presenter.
  - Forbidden concerns: command semantics, retries.

- **Presenter**
  - Concern starts: render preview, logs, summaries, and user-facing errors.
  - Concern ends: stable human-readable output format.
  - Forbidden concerns: command mutation, subprocess lifecycle.

- **TelemetrySink**
  - Concern starts: collect structured events (start/stop/timeout/exit code).
  - Concern ends: append-only diagnostics channel.
  - Forbidden concerns: decision-making or control flow.

- **ExitPolicy**
  - Concern starts: map `ExecutionResult` + validation failures to exit codes.
  - Concern ends: one final process exit status.
  - Forbidden concerns: rendering or execution.

# Tables

## Table 1 — Entity Wiring & Call Order

| Step | Caller | Callee | Data In | Data Out | Sync/Async | Failure Ownership |
|---|---|---|---|---|---|---|
| 1 | `main` | `CLIAdapter` | raw `argv` | `SearchRequest` or parse error | sync | `CLIAdapter` returns typed validation errors |
| 2 | `main` | `Planner` | `SearchRequest` | `ExecutionPlan` | sync | `Planner` raises planning errors only |
| 3 | `main` | `Presenter` | `ExecutionPlan` | preview text | sync | `Presenter` cannot fail closed; fallback plain text |
| 4 | `main` | `Executor` | `ExecutionPlan` | `ExecutionResult` | async runtime, sync API | `Executor` owns child lifecycle + timeout handling |
| 5 | `Executor` | `OutputStreamer` | subprocess pipes | output events | async | `OutputStreamer` owns bounded buffering |
| 6 | `main` | `TelemetrySink` | lifecycle events | none | fire-and-forget | telemetry failures never break command flow |
| 7 | `main` | `ExitPolicy` | parse/plan/exec result | integer exit code | sync | `ExitPolicy` is final arbiter |

## Table 2 — Boundary Contracts (What Each Entity Must Not Do)

| Entity | Allowed Responsibilities | Explicitly Out of Scope |
|---|---|---|
| `CLIAdapter` | parse flags, enforce required args, normalize defaults | building shell strings, spawning processes |
| `Planner` | create deterministic command graph, attach safety limits | reading process output, formatting terminal logs |
| `Executor` | spawn process group, enforce timeout, terminate descendants, collect status | reinterpreting business intent, changing plan at runtime |
| `OutputStreamer` | non-blocking reads, chunking, backpressure-aware forwarding | whole-output accumulation in memory |
| `Presenter` | human-readable lines, preview blocks, concise diagnostics | decision logic for retries/timeouts |
| `TelemetrySink` | append structured events with timestamps | user-facing display formatting |
| `ExitPolicy` | stable mapping to exit codes | any side effects |

## Table 3 — Runtime Safety & Resource Controls

| Control | Owner | Default | Hard Limit | Enforcement Point |
|---|---|---|---|---|
| Max wall time per execution | `Executor` | 30s | 300s | kill process group on timeout |
| Max concurrent subprocess groups | `Executor` | 1 | 1 | reject additional execution attempts |
| Max buffered bytes per stream | `OutputStreamer` | 64 KiB | 1 MiB | ring buffer + truncation marker |
| Max emitted lines | `OutputStreamer` + `Presenter` | 10,000 | 100,000 | stop streaming + emit overflow event |
| Max command length | `Planner` | 8 KiB | 32 KiB | pre-exec validation failure |
| Allowed shell executable | `Planner`/`Executor` | `/bin/bash` | fixed allowlist only | reject unsupported shells |

## Table 4 — Process Lifecycle Guarantees

| Lifecycle Phase | Required Behavior | Failure Fallback | Verifiable Signal |
|---|---|---|---|
| Spawn | start child in isolated process group | return startup error, no partial state | `process_started(pid, pgid)` event |
| Stream | drain stdout/stderr without blocking main loop | truncate + continue with warning | `stream_chunk(channel, size)` events |
| Timeout | send TERM to process group, wait grace period | escalate to KILL after grace window | `timeout`, `term_sent`, `kill_sent` events |
| Normal exit | collect exit code and rusage where available | report partial metrics if unavailable | `process_exited(code, duration_ms)` |
| Abnormal exit | capture signal/exception details | map to non-zero exit via `ExitPolicy` | `process_failed(reason)` |
| Cleanup | always reap child processes | best-effort reap loop with warning | `cleanup_complete(reaped_count)` |

## Table 5 — Failure Taxonomy & Exit Mapping

| Failure Class | Origin Entity | User Message Style | Exit Code |
|---|---|---|---|
| ValidationError | `CLIAdapter` | concise actionable flag guidance | 2 |
| PlanningError | `Planner` | unsupported combination + remediation hint | 2 |
| TimeoutError | `Executor` | includes configured timeout and command id | 124 |
| ResourceLimitError | `OutputStreamer`/`Executor` | limit exceeded + which limit | 125 |
| SubprocessError | `Executor` | show child exit code/signal | propagate child or 1 |
| InternalError | any entity | opaque-safe summary + event id | 1 |

## Table 6 — Determinism & Testability Requirements

| Requirement | Mechanism | Owner | Acceptance Check |
|---|---|---|---|
| Plan determinism | same input yields byte-identical `ExecutionPlan` | `Planner` | snapshot tests on plan serialization |
| Side-effect isolation | pure parse/plan layers | `CLIAdapter`/`Planner` | unit tests with no subprocess creation |
| Bounded memory | stream, never full-capture | `OutputStreamer` | stress test with very large stdout |
| No zombie processes | guaranteed wait/reap paths | `Executor` | integration test inspects child state post-exit |
| Stable exits | centralized mapping table | `ExitPolicy` | table-driven tests for all failure classes |
