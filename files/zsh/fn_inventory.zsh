# Helpers to inspect the personal zsh setup.

typeset -gr _SHELL_INVENTORY_DOUBLE_QUOTE=$'"'
typeset -gr _SHELL_INVENTORY_DEFAULT_PREFIX=': ${'
typeset -gr _SHELL_INVENTORY_DEFAULT_DELIM=':='
typeset -gr _SHELL_INVENTORY_DEFAULT_SUFFIX='}'
typeset -gr _SHELL_INVENTORY_ALIAS_PREFIX='alias '
typeset -gr _SHELL_INVENTORY_COMMENT_PREFIX='#'
typeset -gr _SHELL_INVENTORY_EXPORT_PREFIX='export '
typeset -gr _SHELL_INVENTORY_FUNCTION_KEYWORD='function '
typeset -gr _SHELL_INVENTORY_CHECK_ICON=$'✓'
typeset -gr _SHELL_INVENTORY_FAIL_ICON=$'✗'

_shell_inventory_section_header() {
  local title="$1"
  print
  print -- "== $title =="
}

_shell_inventory_trim() {
  local value="$1"
  value=${${value##[[:space:]]#}%%[[:space:]]#}
  if [[ $value == ${_SHELL_INVENTORY_DOUBLE_QUOTE}*${_SHELL_INVENTORY_DOUBLE_QUOTE} ]]; then
    value=${value#${_SHELL_INVENTORY_DOUBLE_QUOTE}}
    value=${value%${_SHELL_INVENTORY_DOUBLE_QUOTE}}
  fi
  print -r -- "$value"
}

_shell_inventory_verbose_mark() {
  local icon="$1" message="$2" state="$3"
  [[ -z ${state:-} ]] && return
  print -- "  $icon $message"
}

_shell_inventory_mark_ok() {
  _shell_inventory_verbose_mark "${_SHELL_INVENTORY_CHECK_ICON}" "$1" "$2"
}

_shell_inventory_mark_fail() {
  _shell_inventory_verbose_mark "${_SHELL_INVENTORY_FAIL_ICON}" "$1" "$2"
}

_shell_inventory_report_file() {
  local label="$1" path="$2" format="$3" verbose_state="$4"
  if [[ -f $path ]]; then
    _shell_inventory_mark_ok "$label found" "$verbose_state"
    printf "$format" "$label" "$path"
  else
    _shell_inventory_mark_fail "$label missing ($path)" "$verbose_state"
  fi
}

shell-zsh-inventory() {
  local _SHELL_INVENTORY_VERBOSE=""
  case "$1" in
    -v|--verbose)
      _SHELL_INVENTORY_VERBOSE=1
      shift
      ;;
    *)
      [[ -n ${SHELL_INVENTORY_VERBOSE:-} ]] && _SHELL_INVENTORY_VERBOSE=1
      ;;
  esac

  local devsetup include_dir oh_my_file sources_file variables_file aliases_file
  local history_file functions_file zshrc_file
  devsetup="${DEVSETUP:-/opt/chef/cookbooks/development-setup}"
  include_dir="${INCLUDE:-$devsetup/files/zsh}"
  oh_my_file="$include_dir/oh-my-zsh.zsh"
  sources_file="$include_dir/sources.zsh"
  variables_file="$include_dir/variables.zsh"
  aliases_file="$include_dir/aliases.zsh"
  history_file="$include_dir/history.zsh"
  functions_file="$include_dir/functions.zsh"
  zshrc_file="$include_dir/zshrc"

  if [[ ! -d $include_dir ]]; then
    _shell_inventory_mark_fail "include directory not found: $include_dir" "${_SHELL_INVENTORY_VERBOSE:-}"
    print -u2 -- "shell-zsh-inventory: include directory not found: $include_dir"
    return 1
  fi
  _shell_inventory_mark_ok "include directory located: $include_dir" "${_SHELL_INVENTORY_VERBOSE:-}"

  print -- "Personal zsh customization inventory"
  if command -v date >/dev/null 2>&1; then
    local timestamp
    timestamp=$(command date -u '+%Y-%m-%d %H:%M:%S %Z' 2>/dev/null || command date)
    print -- "Generated: $timestamp"
  fi

  _shell_inventory_section_header "Key directories"
  printf '  %-20s %s\n' "DEVSETUP" "$devsetup"
  printf '  %-20s %s\n' "INCLUDE" "$include_dir"
  local personal_dir navicustom_dir work_zshrc zsh_dir tmp_dir
  personal_dir="${PERSONAL_DIR:-/var/brad}"
  navicustom_dir="${NAVI_CUSTOM_DIR:-$HOME/.local/share/navi/cheats/custom}"
  work_zshrc="${WORK_ZSHRC:-~/Projects/sandbox/zshrc}"
  zsh_dir="${ZSH:-$HOME/.oh-my-zsh}"
  tmp_dir="${TMPDIR:-/tmp}"
  printf '  %-20s %s\n' "PERSONAL_DIR" "$personal_dir"
  printf '  %-20s %s\n' "NAVI_CUSTOM_DIR" "$navicustom_dir"
  printf '  %-20s %s\n' "WORK_ZSHRC" "$work_zshrc"
  printf '  %-20s %s\n' "ZSH" "$zsh_dir"
  printf '  %-20s %s\n' "TMPDIR" "$tmp_dir"

  _shell_inventory_section_header "Primary configuration files"
  _shell_inventory_report_file "zshrc template" "$zshrc_file" '  %-24s %s\n' "${_SHELL_INVENTORY_VERBOSE:-}"
  _shell_inventory_report_file "sources.zsh" "$sources_file" '  %-24s %s\n' "${_SHELL_INVENTORY_VERBOSE:-}"
  _shell_inventory_report_file "functions.zsh" "$functions_file" '  %-24s %s\n' "${_SHELL_INVENTORY_VERBOSE:-}"
  _shell_inventory_report_file "oh-my-zsh.zsh" "$oh_my_file" '  %-24s %s\n' "${_SHELL_INVENTORY_VERBOSE:-}"
  _shell_inventory_report_file "aliases.zsh" "$aliases_file" '  %-24s %s\n' "${_SHELL_INVENTORY_VERBOSE:-}"
  _shell_inventory_report_file "variables.zsh" "$variables_file" '  %-24s %s\n' "${_SHELL_INVENTORY_VERBOSE:-}"
  _shell_inventory_report_file "history.zsh" "$history_file" '  %-24s %s\n' "${_SHELL_INVENTORY_VERBOSE:-}"
  if [[ -n $work_zshrc ]]; then
    local work_expanded="${work_zshrc/#~/$HOME}"
    if [[ -f $work_expanded ]]; then
      _shell_inventory_mark_ok "work override found" "${_SHELL_INVENTORY_VERBOSE:-}"
      printf '  %-24s %s\n' "work override" "$work_zshrc"
    else
      _shell_inventory_mark_fail "work override missing ($work_zshrc)" "${_SHELL_INVENTORY_VERBOSE:-}"
    fi
  fi

  if [[ -f $sources_file ]]; then
    _shell_inventory_section_header "Source order"
    local line
    while IFS= read -r line; do
      [[ -z $line ]] && continue
      [[ $line == ${_SHELL_INVENTORY_COMMENT_PREFIX}* ]] && continue
      printf '  %s\n' "$line"
    done < "$sources_file"
  else
    _shell_inventory_mark_fail "source order unavailable; sources.zsh missing" "${_SHELL_INVENTORY_VERBOSE:-}"
  fi

  _shell_inventory_section_header "Oh My Zsh"
  local omz_theme effective_theme
  if (( ${+OMZ_THEME} )); then
    omz_theme="$OMZ_THEME"
    _shell_inventory_mark_ok "OMZ_THEME provided via environment" "${_SHELL_INVENTORY_VERBOSE:-}"
  elif [[ -f $oh_my_file ]]; then
    local oh_line
    while IFS= read -r oh_line; do
      [[ -z $oh_line ]] && continue
      [[ $oh_line == ${_SHELL_INVENTORY_COMMENT_PREFIX}* ]] && continue
      if [[ $oh_line == "OMZ_THEME="* ]]; then
        omz_theme=${oh_line#OMZ_THEME=}
        omz_theme=${omz_theme#${_SHELL_INVENTORY_DOUBLE_QUOTE}}
        omz_theme=${omz_theme%${_SHELL_INVENTORY_DOUBLE_QUOTE}}
        break
      fi
    done < "$oh_my_file"
    if [[ -n $omz_theme ]]; then
      _shell_inventory_mark_ok "OMZ_THEME parsed from oh-my-zsh.zsh" "${_SHELL_INVENTORY_VERBOSE:-}"
    else
      _shell_inventory_mark_fail "OMZ_THEME not found in oh-my-zsh.zsh" "${_SHELL_INVENTORY_VERBOSE:-}"
    fi
  else
    _shell_inventory_mark_fail "OMZ theme detection skipped; oh-my-zsh.zsh missing" "${_SHELL_INVENTORY_VERBOSE:-}"
  fi
  effective_theme="${ZSH_THEME:-$omz_theme}"
  [[ -n $omz_theme ]] && printf '  %-12s %s\n' "OMZ_THEME" "$omz_theme"
  [[ -n $effective_theme ]] && printf '  %-12s %s\n' "ZSH_THEME" "$effective_theme"
  local -a omz_plugins effective_plugins
  if (( ${+OMZ_PLUGINS} )); then
    omz_plugins=("${(@)OMZ_PLUGINS}")
    _shell_inventory_mark_ok "OMZ_PLUGINS provided via environment" "${_SHELL_INVENTORY_VERBOSE:-}"
  elif [[ -f $oh_my_file ]]; then
    local oh_line omz_raw
    while IFS= read -r oh_line; do
      [[ -z $oh_line ]] && continue
      [[ $oh_line == ${_SHELL_INVENTORY_COMMENT_PREFIX}* ]] && continue
      if [[ $oh_line == "OMZ_PLUGINS="* ]]; then
        omz_raw=${oh_line#OMZ_PLUGINS=(}
        omz_raw=${omz_raw%)}
        omz_raw=${omz_raw//${_SHELL_INVENTORY_DOUBLE_QUOTE}}
        omz_raw=$(_shell_inventory_trim "$omz_raw")
        IFS=' ' read -rA omz_plugins <<< "$omz_raw"
        break
      fi
    done < "$oh_my_file"
    if (( ${#omz_plugins} )); then
      _shell_inventory_mark_ok "OMZ_PLUGINS parsed from oh-my-zsh.zsh" "${_SHELL_INVENTORY_VERBOSE:-}"
    else
      _shell_inventory_mark_fail "OMZ_PLUGINS not found in oh-my-zsh.zsh" "${_SHELL_INVENTORY_VERBOSE:-}"
    fi
  else
    _shell_inventory_mark_fail "OMZ plugins detection skipped; oh-my-zsh.zsh missing" "${_SHELL_INVENTORY_VERBOSE:-}"
  fi
  if (( ${#omz_plugins} )); then
    printf '  %-12s %s\n' "OMZ_PLUGINS" "${(j: :)omz_plugins}"
  fi
  if (( ${+plugins} )); then
    effective_plugins=("${(@)plugins}")
    _shell_inventory_mark_ok "plugins provided via environment" "${_SHELL_INVENTORY_VERBOSE:-}"
  elif [[ -f $oh_my_file ]]; then
    local oh_line plugins_raw
    while IFS= read -r oh_line; do
      [[ -z $oh_line ]] && continue
        [[ $oh_line == ${_SHELL_INVENTORY_COMMENT_PREFIX}* ]] && continue
      if [[ $oh_line == "plugins="* ]]; then
        plugins_raw=${oh_line#plugins=(}
        plugins_raw=${plugins_raw%)}
        plugins_raw=${plugins_raw//${_SHELL_INVENTORY_DOUBLE_QUOTE}}
        plugins_raw=$(_shell_inventory_trim "$plugins_raw")
        IFS=' ' read -rA effective_plugins <<< "$plugins_raw"
        break
      fi
    done < "$oh_my_file"
    if (( ${#effective_plugins} )); then
      _shell_inventory_mark_ok "plugins parsed from oh-my-zsh.zsh" "${_SHELL_INVENTORY_VERBOSE:-}"
    else
      _shell_inventory_mark_fail "plugins not found in oh-my-zsh.zsh" "${_SHELL_INVENTORY_VERBOSE:-}"
    fi
  else
    _shell_inventory_mark_fail "plugins detection skipped; oh-my-zsh.zsh missing" "${_SHELL_INVENTORY_VERBOSE:-}"
  fi
  if (( ${#effective_plugins} )); then
    printf '  %-12s %s\n' "plugins" "${(j: :)effective_plugins}"
  fi
  printf '  %-12s %s\n' "ZSH" "$zsh_dir"

  if [[ -f $variables_file ]]; then
    _shell_inventory_section_header "Environment variables (from variables.zsh)"
    local var_line name value
    local -i var_line_no=0
    while IFS= read -r var_line; do
      var_line_no+=1
      [[ -z $var_line ]] && continue
      [[ $var_line == ${_SHELL_INVENTORY_COMMENT_PREFIX}* ]] && continue
      if [[ $var_line == ${_SHELL_INVENTORY_EXPORT_PREFIX}* ]]; then
        var_line=${var_line#${_SHELL_INVENTORY_EXPORT_PREFIX}}
        printf '  %s\n' "$var_line"
      elif [[ ${var_line:0:2} == ': ' && $var_line == *${_SHELL_INVENTORY_DEFAULT_DELIM}* ]]; then
        if [[ $var_line =~ '^: \$\{([A-Za-z_][A-Za-z0-9_]*)[:?]?=([^}]*)\}$' ]]; then
          name=${match[1]}
          value=${match[2]}
          value=$(_shell_inventory_trim "$value")
          printf '  %s (default) = %s\n' "$name" "$value"
        else
          _shell_inventory_mark_fail "variables.zsh malformed default at line $var_line_no: $var_line" "${_SHELL_INVENTORY_VERBOSE:-}"
          printf '  %s\n' "$var_line"
        fi
      else
        printf '  %s\n' "$var_line"
      fi
    done < "$variables_file"
  else
    _shell_inventory_mark_fail "variables.zsh missing; environment defaults not listed" "${_SHELL_INVENTORY_VERBOSE:-}"
  fi

  if [[ -f $aliases_file ]]; then
    _shell_inventory_section_header "Aliases"
    local alias_line
    while IFS= read -r alias_line; do
      [[ -z $alias_line ]] && continue
      [[ $alias_line == ${_SHELL_INVENTORY_COMMENT_PREFIX}* ]] && continue
      if [[ $alias_line == ${_SHELL_INVENTORY_ALIAS_PREFIX}* ]]; then
        alias_line=${alias_line#${_SHELL_INVENTORY_ALIAS_PREFIX}}
      fi
      printf '  %s\n' "$alias_line"
    done < "$aliases_file"
  else
    _shell_inventory_mark_fail "aliases.zsh missing; alias inventory skipped" "${_SHELL_INVENTORY_VERBOSE:-}"
  fi

  if [[ -f $history_file ]]; then
    _shell_inventory_section_header "History options"
    local hist_line
    while IFS= read -r hist_line; do
      [[ -z $hist_line ]] && continue
      printf '  %s\n' "$hist_line"
    done < "$history_file"
  else
    _shell_inventory_mark_fail "history.zsh missing; history options not reported" "${_SHELL_INVENTORY_VERBOSE:-}"
  fi

  local -a fn_files
  fn_files=(${include_dir}/fn_*.zsh(N))
  if (( ${#fn_files} )); then
    _shell_inventory_section_header "Function modules"
    local file module_name
    for file in "${fn_files[@]}"; do
      module_name="${file:t}"
      local -a names preview_list
      names=()
      if [[ -r $file ]]; then
        local func_line stripped name
        while IFS= read -r func_line; do
          [[ -z $func_line ]] && continue
          stripped=$(_shell_inventory_trim "$func_line")
          [[ -z $stripped ]] && continue
          if [[ $stripped == ${_SHELL_INVENTORY_FUNCTION_KEYWORD}* ]]; then
            name=${stripped#${_SHELL_INVENTORY_FUNCTION_KEYWORD}}
            name=${name%%(*}
            name=${name%%{*}
            name=${name%% *}
          elif [[ $stripped == *"(){"* ]] || [[ $stripped == *"() {"* ]]; then
            name=${stripped%%(*}
          elif [[ $stripped == *") {"* ]]; then
            name=${stripped%% *}
          else
            continue
          fi
          name=$(_shell_inventory_trim "$name")
          [[ -z $name ]] && continue
          names+=("$name")
        done < "$file"
      fi
      local count=${#names}
      local plural=""
      [[ $count -ne 1 ]] && plural="s"
      if (( count )); then
        local limit=$(( count < 5 ? count : 5 ))
        preview_list=()
        local idx=1
        while (( idx <= limit )); do
          preview_list+=("${names[idx]}")
          (( idx++ ))
        done
        local preview="${(j: :)preview_list}"
        if (( count > limit )); then
          preview="$preview, ..."
        fi
        printf '  %-24s %2d function%s: %s\n' "$module_name" "$count" "$plural" "$preview"
      else
        printf '  %-24s %2d function%s\n' "$module_name" "$count" "$plural"
      fi
    done
    print '  Tip: Run `list-functions` for a live list with definitions.'
  fi

  typeset -A seen_files
  local track_file
  for track_file in "$aliases_file" "$variables_file" "$history_file" "$oh_my_file" "$sources_file" "$functions_file"; do
    [[ -z $track_file ]] && continue
    seen_files["$track_file"]=1
  done
  for track_file in "${fn_files[@]}"; do
    seen_files["$track_file"]=1
  done

  local -a supplemental
  supplemental=(${include_dir}/*.zsh(N))
  local extra_count=0
  for track_file in "${supplemental[@]}"; do
    [[ -n ${seen_files[$track_file]:-} ]] && continue
    (( extra_count++ ))
    if (( extra_count == 1 )); then
      _shell_inventory_section_header "Supplemental modules"
    fi
    local desc=""
    if [[ -r $track_file ]]; then
      local sup_line
      while IFS= read -r sup_line; do
        [[ -z $sup_line ]] && continue
        if [[ $sup_line == ${_SHELL_INVENTORY_COMMENT_PREFIX}* ]]; then
          desc=${sup_line:1}
          desc=$(_shell_inventory_trim "$desc")
          break
        fi
      done < "$track_file"
    fi
    if [[ -n $desc ]]; then
      printf '  %-24s %s — %s\n' "${track_file:t}" "$track_file" "$desc"
    else
      printf '  %-24s %s\n' "${track_file:t}" "$track_file"
    fi
  done
}

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

