# Chef Cookbook

This folder contains the cookbook and helper scripts that used to live at the repository root.

<!-- Historical example: several embedded paths still point at the original cookbook root; update them before trying to run this as a live cookbook. -->

## Files

- `attributes/` - default configuration attributes for the cookbook.
- `files/` - helper scripts, configuration, and notes used by the cookbook.
  See `files/etc/README.md`, `files/docs/DECISIONS.md`, and `files/zsh/README.md`
  for focused details.
- `recipes/` - main Chef recipes to configure different platforms.
- `templates/` - template files for configuration.
- `tools/` - utility scripts such as Ruby analysis helpers.
- `node.json` and `node_windows.json` - sample node attribute files.
- `solo.rb` and `solo_windows.rb` - Chef solo configuration.
- `run.sh` and `run.cmd` - helper scripts to run the cookbook on Linux or Windows.
- `metadata.rb` - cookbook metadata.
- `init.sh` - example bootstrap script.
- `quick-start.sh` - bootstrap the oh-my-zsh setup from this repository without Chef.

## Running It

Clone the repository, then run the helper from this directory:

```bash
cd code-portfolio/chef
./quick-start.sh
```

The script installs oh-my-zsh, pulls the recommended plugins (fzf, autosuggestions,
syntax highlighting, and the powerlevel10k theme), and writes a `.zshrc` that
sources the configuration in `files/zsh/`. Your previous `.zshrc` is backed up
with a timestamped suffix if it existed.
