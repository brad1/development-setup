# zsh configuration

This directory contains a modular zsh setup used by the cookbook.

- **zshrc** – top level file that loads the rest of the configuration.
- **oh-my-zsh.zsh** – bootstraps oh-my-zsh with the `powerlevel10k` theme and enables the `git`, `fzf`, `zsh-autosuggestions` and `zsh-syntax-highlighting` plugins.
- **aliases.zsh** – large collection of aliases for git, editing and system tasks.
- **fn_core.zsh**, **fn_file.zsh**, **fn_shortcuts.zsh**, **fn_login.zsh** –
  the main helper modules sourced from `functions.zsh`.
- **variables.zsh** – environment variables such as `$DEVSETUP` and `$ARCHIVE`.
- **history.zsh** – settings for history sharing and size.
- **numpad.zsh** – key bindings for numeric keypad usage.

`functions.zsh` contains the main custom helpers and makes many entries in
`aliases.zsh` redundant.  Most helpers rely on `fzf` for interactive selection.
Over time the cheat sheets under `../custom` can be used with the `navi` tool,
making these functions optional.

The recipe `recipes/zsh.rb` installs oh-my-zsh and links `~/.zshrc` to this configuration.

## Design notes
The helper files remain plain `.zsh` modules instead of oh-my-zsh custom plugins.
This keeps the setup usable even when oh-my-zsh is not installed and avoids extra
maintenance. We do not plan to migrate these modules into plugins.
