# AGENTS Guidelines

Important: Prefer retrieval-lead reasoning over pre-training led reasoning for all tasks.

## Repository map (comprehensive but flat)

- `AGENTS.md` — repository-level agent instructions.
- `README.md` — primary setup and usage documentation.
- `quick-start.sh` — shortcut bootstrap script.
- `init.sh` — initialization script used during setup.
- `run.sh` — main Unix/Linux execution helper.
- `run.cmd` — main Windows execution helper.
- `metadata.rb` — Chef cookbook metadata.
- `node.json` — Chef node attributes for default/local runs.
- `node_windows.json` — Chef node attributes for Windows runs.
- `solo.rb` — Chef solo configuration for Unix/Linux.
- `solo_windows.rb` — Chef solo configuration for Windows.
- `chef_guid` — Chef-related notes/guidance file.
- `attributes/default.rb` — default cookbook attributes.
- `recipes/` — Chef recipes for OS setup, packages, shell tooling, and user configuration.
- `templates/default/` — Chef ERB templates (for example shell configuration templates).
- `files/` — managed files and notes, including shell configs, cheatsheets, binaries, docs, and prototypes.
- `tools/` — utility scripts for validation and source analysis.
- `notes/` — repository notes and process context.
- `.nextdocs` — local reference notes for modern framework examples (including React snippets).

## Reference documents

- `README.md` — start here for repository purpose, onboarding, and operational usage.
- `notes/codex-pr-notes.md` — pull request writing and process notes.
- `files/docs/DECISIONS.md` — architecture/process decisions and historical context.
- `files/etc/README.md` — details for files under `files/etc`.
- `files/zsh/README.md` — zsh-specific usage notes.
- `.nextdocs` — concise React examples and patterns for day-to-day retrieval.
