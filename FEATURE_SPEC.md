# Executive Summary

`powersearch` is a toy command-line utility that gives developers a friendlier interface over three highly productive shell primitives:

- `find` for recursive file discovery
- `grep` for content filtering
- Bash glob/brace expansion for expressive target selection

The utility focuses on usability, not replacing shell tooling. It translates intuitive CLI flags into concrete shell commands, previews what will run, and executes through `bash -lc` so standard shell expansions work as users expect.

Primary outcomes:

1. Reduce memorization burden for common `find | grep` flows.
2. Preserve transparency by showing the generated commands.
3. Keep architecture minimal so the tool can be extended later.

# List of entities

- **PowerSearchCLI**: top-level argument parser and command router.
- **SearchRequest**: normalized request object derived from CLI inputs.
- **ShellCommandPlan**: ordered shell command strings produced from a request.
- **CommandBuilder**: logic that maps request fields to `find`, `grep`, and expansion-aware bash snippets.
- **CommandExecutor**: runs planned commands (`bash -lc`) and streams output.
- **PreviewFormatter**: renders dry-run/preview output for developer trust.
- **ExitStatusPolicy**: maps subprocess outcomes to CLI exit codes.

# Tables

## Table 1 — Command Surface

| Command | Purpose | Core Inputs | Output | Notes |
|---|---|---|---|---|
| `scan` | File discovery using `find` wrappers | roots, name pattern, type, max depth | matching paths | supports multiple roots and simple defaults |
| `match` | Content search via `grep` wrappers | pattern, path selectors, case mode, context lines | matching lines | can operate on explicit paths or expansion results |
| `combo` | Compose discovery + content filtering | find filters + grep pattern | matching lines from matched files | equivalent to common `find ... -print0 | xargs -0 grep ...` flows |
| `preview` | Show generated shell command without execution | any command inputs | rendered command string(s) | aids learning and trust |

## Table 2 — `SearchRequest` Schema

| Field | Type | Required | Example | Description |
|---|---|---|---|---|
| `mode` | enum(`scan`,`match`,`combo`,`preview`) | yes | `combo` | selected workflow |
| `roots` | list[str] | no | `['src', 'tests']` | search roots; defaults to current directory |
| `name_glob` | str | no | `"*.py"` | file name filter passed to `find -name` |
| `path_expr` | str | no | `"**/*.md"` | bash-expansion path expression (evaluated in shell) |
| `file_type` | enum(`f`,`d`) | no | `f` | `find -type` restriction |
| `max_depth` | int | no | `4` | `find -maxdepth` |
| `grep_pattern` | str | conditional | `"TODO|FIXME"` | regex/text pattern for grep-dependent modes |
| `ignore_case` | bool | no | `true` | maps to `grep -i` |
| `context_lines` | int | no | `2` | maps to `grep -C` |
| `dry_run` | bool | no | `true` | preview only; do not execute |

## Table 3 — Translation Rules (CLI → Shell)

| Rule ID | Condition | Translation | Example |
|---|---|---|---|
| TR-01 | `mode=scan` with `name_glob` | build `find <roots> -name '<glob>'` | `find src -name '*.py'` |
| TR-02 | `file_type` provided | append `-type` predicate | `find . -type f` |
| TR-03 | `max_depth` provided | append `-maxdepth N` near root segment | `find . -maxdepth 3 -name '*.md'` |
| TR-04 | `mode=match` + `path_expr` | expand via `bash -lc` then run `grep` over expanded paths | `grep -n 'foo' **/*.py` |
| TR-05 | `ignore_case=true` | add `grep -i` | `grep -ni 'foo' file.txt` |
| TR-06 | `context_lines>0` | add `grep -C <n>` | `grep -n -C 2 'foo' app.log` |
| TR-07 | `mode=combo` | produce safe two-step pipeline (`find ... -print0` + `xargs -0 grep`) | `find . -name '*.py' -print0 \| xargs -0 grep -n 'foo'` |
| TR-08 | `dry_run=true` or `mode=preview` | render command(s) only | prints generated shell without exec |

## Table 4 — Error and Exit Behavior

| Scenario | Detection | User Message | Exit Code |
|---|---|---|---|
| missing grep pattern in `match/combo` | argument validation | `--pattern is required for this mode` | 2 |
| invalid depth (<0) | argument validation | `--max-depth must be >= 0` | 2 |
| shell command failure | subprocess return code != 0 | show failed command and code | propagate subprocess code |
| no results found | successful run with empty output | `No matches found` (optional) | 0 |
| internal planner error | exception during build | concise diagnostic | 1 |

## Table 5 — Non-Functional Requirements

| Requirement | Target | Rationale |
|---|---|---|
| Transparency | always show runnable command in verbose/dry-run paths | builds trust and teaches shell usage |
| Portability | assume POSIX shell with bash available | enables glob/brace expansion support |
| Simplicity | single-file prototype acceptable | optimize for learning and iteration |
| Extensibility | modular entity boundaries retained even in one file | future growth (extra filters, exclude rules) |
