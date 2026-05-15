#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: zsh-validate.sh [path]

Checks zsh files for syntax errors without sourcing them.

Arguments:
  path  Optional file or directory. Defaults to ./files/zsh

Examples:
  tools/zsh-validate.sh
  tools/zsh-validate.sh files/zsh/functions.zsh
USAGE
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

target="${1:-$(pwd)/files/zsh}"
files=()

if [[ -d "$target" ]]; then
  while IFS= read -r -d '' file; do
    files+=("$file")
  done < <(find "$target" -maxdepth 1 -type f \( -name "*.zsh" -o -name "zshrc" \) -print0 | sort -z)
else
  files+=("$target")
fi

if (( ${#files[@]} == 0 )); then
  echo "No zsh files found under: $target" >&2
  exit 1
fi

failures=0
for file in "${files[@]}"; do
  if zsh -n "$file"; then
    printf 'OK  %s\n' "$file"
  else
    printf 'ERR %s\n' "$file" >&2
    failures=$((failures + 1))
  fi
done

if (( failures > 0 )); then
  echo "${failures} file(s) failed syntax checks." >&2
  exit 1
fi
