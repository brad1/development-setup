#!/usr/bin/env bash
set -euo pipefail

if [[ "${TRACE-}" == "1" ]]; then
  set -x
fi

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "quick-start: missing required command '$1'" >&2
    exit 1
  fi
}

sync_git_repo() {
  local url="$1"
  local dest="$2"

  if [[ -d "$dest/.git" ]]; then
    echo "Updating ${dest#$HOME/}"
    git -C "$dest" fetch --tags --prune
    git -C "$dest" pull --ff-only
  else
    echo "Cloning ${dest#$HOME/}"
    mkdir -p "$(dirname "$dest")"
    git clone "$url" "$dest"
  fi
}

require_command git
require_command zsh

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
oh_my_dir="$HOME/.oh-my-zsh"
custom_dir="$oh_my_dir/custom"

sync_git_repo "https://github.com/robbyrussell/oh-my-zsh.git" "$oh_my_dir"

sync_git_repo "https://github.com/zsh-users/zsh-autosuggestions.git" \
  "$custom_dir/plugins/zsh-autosuggestions"

sync_git_repo "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
  "$custom_dir/plugins/zsh-syntax-highlighting"

sync_git_repo "https://github.com/romkatv/powerlevel10k.git" \
  "$custom_dir/themes/powerlevel10k"

managed_marker="# Managed by development-setup/quick-start.sh"
zshrc_path="$HOME/.zshrc"
if [[ -f "$zshrc_path" || -L "$zshrc_path" ]]; then
  if ! grep -Fq "$managed_marker" "$zshrc_path" 2>/dev/null; then
    backup="$zshrc_path.$(date +%Y%m%d%H%M%S).bak"
    echo "Backing up existing .zshrc to ${backup##$HOME/}"
    mv "$zshrc_path" "$backup"
  fi
fi

cat > "$zshrc_path" <<EOF2
$managed_marker
export DEVSETUP="$repo_root"
export INCLUDE="\${DEVSETUP}/files/zsh"
source "\${DEVSETUP}/files/zsh/zshrc"
EOF2

echo "Installed oh-my-zsh customizations."
echo "Restart your shell or run 'zsh --login' to use the configuration."
