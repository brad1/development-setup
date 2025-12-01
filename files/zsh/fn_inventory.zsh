# Simplified check that focuses only on the include directory and primary files.
# Inspired by `shell-zsh-inventory`, but avoids its broader parsing so it can be
# sourced safely even if the original function is currently broken.
shell-zsh-inventory-basic() {
  local devsetup include_dir
  devsetup="${DEVSETUP:-/opt/chef/cookbooks/development-setup}"
  include_dir="${INCLUDE:-$devsetup/files/zsh}"

  print -- "shell-zsh-inventory-basic"
  print -- "  INCLUDE: $include_dir"

  if [[ ! -d $include_dir ]]; then
    print -u2 -- "include directory missing: $include_dir"
    return 1
  fi

  local -a important_files missing
  important_files=("$include_dir/oh-my-zsh.zsh" "$include_dir/sources.zsh" "$include_dir/variables.zsh")
  missing=()

  local file
  for file in "${important_files[@]}"; do
    if [[ -f $file ]]; then
      print -- "  ✓ $(basename "$file")"
    else
      print -- "  ✗ $(basename "$file") (expected at $file)"
      missing+=("$file")
    fi
  done

  if (( ${#missing} )); then
    print -u2 -- "missing ${#missing} primary file(s); inventory incomplete"
    return 2
  fi

  print -- "  All primary files present."
}

