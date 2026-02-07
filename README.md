# example run

```
dir='/opt/chef/cookbooks'
mkdir -p $dir && cd $dir
git clone git@github.com:brad1/development-setup.git
sudo bash --login -c 'rvm use 2.4.1; chef-solo -c /opt/chef/cookbooks/development-setup/solo.rb'
```
## Project Index

- `attributes/` - default configuration attributes for the cookbook.
- `files/` - various helper scripts, notes and configuration files used by the cookbook:
  - `bash/` - shell examples and SSH helpers.
  - `bin/` - custom command line utilities and prototype scripts. The
      `git-branch-hop` utility (requires `fzf`) lets you switch to a recent branch via fuzzy search. Two
      zsh functions `git-branch-hop` and `git-branch-hop-old` provide the same
      idea with different implementations for easy comparison.
  - `cheatsheets/` - quick reference guides for tools (git, tmux, etc.).
  - `custom/` - personal cheat entries for the `cheat` or `navi` utilities,
    letting you fuzzy find frequently used commands.
  - `docs/` - assorted documentation like logs and setup notes.
    See `docs/DECISIONS.md` for project choices.
  - `etc/` - sample configuration files such as `knife.rb.example`.
  - `notes/` - topic-specific notes (cron, virtualbox, etc.).
  - `pseudocode/` - design notes and planning snippets.
  - `tmux/`, `vim/`, `zsh/` - configuration directories for these tools. The
    `zsh` folder includes an oh-my-zsh setup. Most custom helpers live in
    `functions.zsh` sources several `fn_*.zsh` modules that replace many older aliases. Over time,
    commands from `files/custom` can be searched with `navi`, making even the
    functions themselves optional (see `zsh/README.md`).
  - `unix.example.0` and `matches` - example command snippets.
- `recipes/` - main Chef recipes to configure different platforms.
- `templates/` - template files for configuration (e.g. `zshrc.erb`).
- `tools/` - utility scripts such as Ruby analysis helpers.
- `node.json` and `node_windows.json` - sample node attribute files.
- `solo.rb` and `solo_windows.rb` - Chef solo configuration.
- `run.sh` and `run.cmd` - helper scripts to run the cookbook on Linux or Windows.
- `metadata.rb` - cookbook metadata.
- `init.sh` - example bootstrap script.
- `quick-start.sh` - bootstrap the oh-my-zsh setup from this repository without Chef.

## Quick start

To install the zsh configuration without running Chef, clone the repository and
execute the helper script:

```
git clone git@github.com:brad1/development-setup.git
cd development-setup
./quick-start.sh
```

The script installs oh-my-zsh, pulls the recommended plugins (fzf, autosuggestions,
syntax highlighting, and the powerlevel10k theme), and writes a `.zshrc` that
sources the configuration in `files/zsh/`. Your previous `.zshrc` is backed up
with a timestamped suffix if it existed.

## Flask dashboard backend

`flaskdashboard/README.md` covers how to start the minimal Flask API (`FLASK_APP=app flask run --port 5000`). The API exposes `GET /api/widgets` and `GET /health`, and `flaskdashboard/requirements.txt` lists the dependencies.

See `docs/local-automation.md` for the sequence of commands that mirror `.github/workflows/reactdashboard-ci.yml` locally.

## Notes on Codex pull requests

See `notes/codex-pr-notes.md` for a summary of the Codex-authored pull requests (#34 and #35) and the areas they touched.
