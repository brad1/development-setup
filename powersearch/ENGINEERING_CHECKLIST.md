# Engineering Checklist

Checklist derived from `ENGINEERING_SPEC.md` and the implemented CLI surface in `main.py`.

## Current task

Extract an explicit `OutputStreamer` from `Executor` and enforce bounded streaming with overflow/truncation signaling.

## Current task sentinment

No blocking issue yet. This is the first task that requires real structure changes instead of test-only work, but it should unlock multiple remaining checklist items at once.

## Next task

Add `TelemetrySink` lifecycle events around spawn, stream, timeout, exit, and cleanup. This benefits from a completed `OutputStreamer` because the stream boundary and overflow events become easier to emit consistently once streaming is no longer inlined inside `Executor`.

| unimplemented | item |
|---|---|
| false | `CLIAdapter` parses argv into a validated `SearchRequest` |
| false | `CLIAdapter` rejects invalid `--max-depth` values |
| false | `CLIAdapter` rejects invalid `--context` values |
| false | `SearchRequest` remains immutable and layer-only |
| false | `Planner` builds a deterministic `ExecutionPlan` from the same input |
| true | `Planner` attaches explicit safety metadata to the plan |
| false | `Planner` enforces the allowed shell executable allowlist |
| false | `Planner` enforces the hard command-length limit |
| false | `Planner` rejects unsupported mode combinations with clear errors |
| false | `Executor` runs each plan in its own isolated process group |
| true | `Executor` enforces the default and hard wall-time limits |
| true | `Executor` terminates descendants on timeout |
| true | `Executor` always reaps child processes and avoids zombies |
| true | `Executor` rejects concurrent subprocess groups beyond the limit of one |
| true | `OutputStreamer` streams stdout and stderr incrementally |
| true | `OutputStreamer` bounds buffered bytes per stream |
| true | `OutputStreamer` bounds emitted line count |
| true | `OutputStreamer` emits a truncation or overflow marker when limits are hit |
| true | `TelemetrySink` records lifecycle events without affecting control flow |
| false | `Presenter` renders previews, summaries, and user-facing errors consistently |
| false | `ExitPolicy` maps validation, planning, timeout, and resource errors to stable exit codes |
| false | `main` catches internal failures and returns a safe non-zero exit code |
| false | `scan` mode emits the expected `find` command |
| false | `match` mode emits the expected `grep` command |
| false | `combo` mode emits the expected `find | xargs grep` pipeline |
| false | `preview` mode prints the generated command without execution |
| false | The implementation has tests covering plan determinism |
| true | The implementation has tests covering cleanup and no-zombie behavior |
| false | The implementation has tests covering exit-code mapping |
