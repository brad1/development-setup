# Simplified check that focuses only on the include directory and primary files.
# Inspired by `shell-zsh-inventory`, but avoids its broader parsing so it can be
# sourced safely even if the original function is currently broken.
shell-zsh-inventory-basic() {
  local devsetup include_dir
  devsetup="${DEVSETUP:-/opt/chef/cookbooks/development-setup}"
  include_dir="${INCLUDE:-$devsetup/files/zsh}"

  print -- "shell-zsh-inventory-basic"
  print -- "  INCLUDE: $include_dir"
  if [[ -d $devsetup ]]; then
    print -- "  ✓ DEVSETUP: $devsetup"
  else
    print -- "  ✗ DEVSETUP missing: $devsetup"
  fi

  if [[ ! -d $include_dir ]]; then
    print -u2 -- "include directory missing: $include_dir"
    return 1
  fi

  local -a important_files missing
  local -i unreadable_primary=0
  important_files=(
    "$include_dir/oh-my-zsh.zsh"
    "$include_dir/sources.zsh"
    "$include_dir/variables.zsh"
    "$include_dir/aliases.zsh"
    "$include_dir/history.zsh"
    "$include_dir/functions.zsh"
    "$include_dir/zshrc"
  )
  missing=()

  local file
  for file in "${important_files[@]}"; do
    if [[ -f $file ]]; then
      if [[ -r $file ]]; then
        print -- "  ✓ $(basename "$file")"
      else
        print -- "  ✗ $(basename "$file") unreadable (expected at $file)"
        (( unreadable_primary++ ))
      fi
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

  local zsh_home
  zsh_home="${ZSH:-$HOME/.oh-my-zsh}"
  if [[ -d $zsh_home ]]; then
    print -- "  ✓ Oh My Zsh directory: $zsh_home"
  else
    print -- "  ✗ Oh My Zsh directory missing: $zsh_home"
  fi

  local -i missing_sources
  missing_sources=0
  if [[ -r $include_dir/sources.zsh ]]; then
    print -- "  Source targets:"
    local src_line raw_target target_path
    while IFS= read -r src_line; do
      [[ -z $src_line || $src_line == \#* ]] && continue
      case "$src_line" in
        source*)
          raw_target=${src_line#source }
          ;;
        .\ *)
          raw_target=${src_line#. }
          ;;
        *)
          continue
          ;;
      esac
      raw_target=${raw_target#"\""}
      raw_target=${raw_target%"\""}
      raw_target=${raw_target//\$INCLUDE/$include_dir}
      raw_target=${raw_target//\$\{INCLUDE\}/$include_dir}
      if [[ $raw_target == /* ]]; then
        target_path="$raw_target"
      else
        target_path="$include_dir/$raw_target"
      fi
      if [[ -f $target_path ]]; then
        print -- "    ✓ $(basename "$target_path")"
      else
        print -- "    ✗ $(basename "$target_path") (expected at $target_path)"
        (( missing_sources++ ))
      fi
    done < "$include_dir/sources.zsh"
  fi

  local omz_theme theme_source effective_theme effective_source omz_line
  local omz_plugins_raw plugin_source
  local -a omz_plugins parsed_plugins
  local -i missing_plugins=0 missing_theme_file=0

  # Theme detection: prefer explicit environment, then parse oh-my-zsh.zsh.
  if [[ -n ${OMZ_THEME:-} ]]; then
    omz_theme="$OMZ_THEME"
    theme_source="OMZ_THEME env"
  elif [[ -r $include_dir/oh-my-zsh.zsh ]]; then
    while IFS= read -r omz_line; do
      [[ -z $omz_line || $omz_line == \#* ]] && continue
      if [[ $omz_line == "OMZ_THEME="* ]]; then
        omz_theme=${omz_line#OMZ_THEME=}
        omz_theme=${omz_theme//\"/}
        theme_source="oh-my-zsh.zsh"
        break
      fi
    done < "$include_dir/oh-my-zsh.zsh"
  fi

  if [[ -n ${ZSH_THEME:-} ]]; then
    effective_theme="$ZSH_THEME"
    effective_source="ZSH_THEME env"
  elif [[ -n $omz_theme ]]; then
    effective_theme="$omz_theme"
    effective_source="$theme_source"
  fi

  if [[ -n $effective_theme ]]; then
    print -- "  ✓ Theme: $effective_theme (${effective_source:-unknown source})"
    if [[ -d $zsh_home ]]; then
      local theme_path
      theme_path="$zsh_home/themes/${effective_theme}.zsh-theme"
      if [[ -f $theme_path ]]; then
        print -- "    ✓ Theme file present: $theme_path"
      else
        print -- "    ✗ Theme file missing: $theme_path"
        (( missing_theme_file++ ))
      fi
    fi
  else
    print -- "  ✗ Theme not detected (set OMZ_THEME or ZSH_THEME)"
  fi

  # Plugins detection: prefer explicit environment, then parse oh-my-zsh.zsh.
  if [[ -n ${OMZ_PLUGINS:-} ]]; then
    omz_plugins_raw="$OMZ_PLUGINS"
    plugin_source="OMZ_PLUGINS env"
  elif [[ -n ${plugins:-} ]]; then
    omz_plugins_raw="$plugins"
    plugin_source="plugins env"
  elif [[ -r $include_dir/oh-my-zsh.zsh ]]; then
    while IFS= read -r omz_line; do
      [[ -z $omz_line || $omz_line == \#* ]] && continue
      if [[ $omz_line == "plugins="* ]]; then
        omz_plugins_raw=${omz_line#plugins=(}
        omz_plugins_raw=${omz_plugins_raw%)}
        plugin_source="oh-my-zsh.zsh"
        break
      fi
    done < "$include_dir/oh-my-zsh.zsh"
  fi

  if [[ -n $omz_plugins_raw ]]; then
    # shellcheck disable=SC2206
    omz_plugins=( ${=omz_plugins_raw} )
    parsed_plugins=("${(u)omz_plugins[@]}")
    print -- "  ✓ Plugins (${plugin_source:-unknown source}): ${(j: :)parsed_plugins}"
    if [[ -d $zsh_home ]]; then
      local plugin_name plugin_path
      for plugin_name in "${parsed_plugins[@]}"; do
        plugin_path="$zsh_home/custom/plugins/$plugin_name"
        if [[ ! -d $plugin_path ]]; then
          plugin_path="$zsh_home/plugins/$plugin_name"
        fi
        if [[ -d $plugin_path ]]; then
          print -- "    ✓ ${plugin_name} at $plugin_path"
        else
          print -- "    ✗ ${plugin_name} plugin directory missing under $zsh_home"
          (( missing_plugins++ ))
        fi
      done
    fi
  else
    print -- "  ✗ Plugins not detected (set OMZ_PLUGINS or plugins)"
  fi

  if (( missing_sources )); then
    print -u2 -- "missing ${missing_sources} source target(s); inventory incomplete"
    return 3
  fi

  local -i exit_code=0
  if (( unreadable_primary )); then
    print -u2 -- "${unreadable_primary} primary file(s) unreadable; check permissions"
    exit_code=4
  fi
  if (( missing_theme_file )); then
    print -u2 -- "theme file missing for detected theme"
    exit_code=5
  fi
  if (( missing_plugins )); then
    print -u2 -- "missing ${missing_plugins} plugin directory(ies); check ZSH path"
    exit_code=6
  fi

  return $exit_code
}
