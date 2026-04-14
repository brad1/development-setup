# Engineering Checklist

Checklist derived from `ENGINEERING_SPEC.md` and the implemented CLI surface in `main.py`.

## Current task

Bring the remaining user-facing formatting in `Presenter` up to the same level of consistency as planning and execution.

## Current task sentinment

No blocking issue. The executor split is done, runtime checks are covered, and the remaining work is mostly presentation polish plus any future telemetry expansion.

## Next task

Decide whether `Presenter` needs an explicit execution summary surface or whether the existing plan, error, and no-match messages are sufficient for the engineering spec.

| unimplemented | item |
|---|---|
| false | `CLIAdapter` parses argv into a validated `SearchRequest` |
| false | `CLIAdapter` rejects invalid `--max-depth` values |
| false | `CLIAdapter` rejects invalid `--context` values |
| false | `SearchRequest` remains immutable and layer-only |
| false | `Planner` builds a deterministic `ExecutionPlan` from the same input |
| false | `Planner` attaches explicit safety metadata to the plan |
| false | `Planner` enforces the allowed shell executable allowlist |
| false | `Planner` enforces the hard command-length limit |
| false | `Planner` rejects unsupported mode combinations with clear errors |
| false | `Executor` runs each plan in its own isolated process group |
| false | `Executor` enforces the default and hard wall-time limits |
| false | `Executor` terminates descendants on timeout |
| false | `Executor` always reaps child processes and avoids zombies |
| false | `Executor` rejects concurrent subprocess groups beyond the limit of one |
| false | `OutputStreamer` streams stdout and stderr incrementally |
| false | `OutputStreamer` bounds buffered bytes per stream |
| false | `OutputStreamer` bounds emitted line count |
| false | `OutputStreamer` emits a truncation or overflow marker when limits are hit |
| false | `TelemetrySink` records lifecycle events without affecting control flow |
| true | `Presenter` renders previews, summaries, and user-facing errors consistently |
| false | `ExitPolicy` maps validation, planning, timeout, and resource errors to stable exit codes |
| false | `main` catches internal failures and returns a safe non-zero exit code |
| false | `scan` mode emits the expected `find` command |
| false | `match` mode emits the expected `grep` command |
| false | `combo` mode emits the expected `find | xargs grep` pipeline |
| false | `preview` mode prints the generated command without execution |
| false | The implementation has tests covering plan determinism |
| false | The implementation has tests covering cleanup and no-zombie behavior |
| false | The implementation has tests covering exit-code mapping |
