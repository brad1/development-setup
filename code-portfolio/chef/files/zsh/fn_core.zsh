# conventions
# <context>-<object>-<verb>
# shell-vbox-list
#
# Many helpers in this file wrap basic tooling. You can often rely on
# dedicated utilities instead:
#   - `navi` to recall commands from cheat sheets. Example:
#       `navi --query "git log"`
#   - `zoxide` for directory jumping. Example:
#       `zoxide add ~/projects/myapp` then `z myapp`
#   - The oh-my-zsh `git` plugin provides aliases such as `gdiff`.


#
# Section: new, experimental




# # # # # # #
# Section: Local variables
#


fp_copied_paths="$PERSONAL_DIR/copied-paths.list"
jobsd="$PERSONAL_DIR/login-splash-jobs"
zsh_functions_debug=0

# Display a message using desktop notifications when available.
shell-notify() {
  local msg="$1"
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "$msg"
  elif command -v terminal-notifier >/dev/null 2>&1; then
    terminal-notifier -message "$msg"
  else
    echo "$msg"
  fi
}

#
#
# # # # # # # # # #




# # # # # # # # # #
# Section: misc
#

#
#
# # # # # # # # # #


#
# Section: invariants
#
# Example: automatically run on login:
# - enforce navi...custom/example.cheat <--- title MUST match filename
#
#
# # # # # # # # # #




















# # # # # # # #
# Section: tmux, terminal mgmt, workflow
#

# Not good candidates for navi cheatsheets; they modify shell state.
# Keep them as functions for convenience.

# run in one tmux tab to keep the task separate and tracked
build-portal() {
    export HISTFILE=$HOME/.build_portal_history
}

# run in one tmux tab to keep the task separate and tracked
git-portal() {
    export HISTFILE=$HOME/.git_portal_history
}

set-vi-mode() {
   set -o vi
   echo "vi mode enabled."
   echo "'/' to reverse search shell history, or:"
   echo 'bindkey "^R" history-incremental-search-backward'
   echo "then 'v' to edit."
}

unset-vi-mode() {
   set +o vi
   echo "vi mode disabled"
}

cdd () {
  echo "Use cd Ctrl-t instead"
}

# End of not-good-candidate functions


list-functions() { # and aliases, for selection
  zsh -c "source $INCLUDE/fn_core.zsh; \
          source $INCLUDE/fn_file.zsh; \
          source $INCLUDE/fn_shortcuts.zsh; \
          source $INCLUDE/fn_login.zsh; \
          print -l \${(ok)functions}"
  zsh -c "source $INCLUDE/aliases.zsh; alias | cut -d= -f1"
}

list-aliases() { # for definition
  zsh -c "source $INCLUDE/aliases.zsh; alias"
}

shell-customizations-inventory() {
  emulate -L zsh

  local include_dir=${INCLUDE:-}
  local repo_root=${DEVSETUP:-}
  if [[ -z $include_dir ]]; then
    if [[ -n $repo_root ]]; then
      include_dir="$repo_root/files/zsh"
    else
      include_dir=${(%):-%N}
      include_dir=${include_dir:A:h}
    fi
  fi

  if [[ -z $repo_root && -n $include_dir ]]; then
    repo_root=${include_dir:h:h}
  fi

  local INCLUDE=$include_dir
  local DEVSETUP=${repo_root:-$DEVSETUP}

  local print_section
  print_section() {
    print ""
    print -- "$1"
  }

  print -- "Personal zsh customizations inventory"
  print -- "Generated: $(command date -Iseconds 2>/dev/null || command date)"
  print -- "Repository root: ${repo_root:-unknown}"
  print -- "Include directory: $include_dir"

  setopt localoptions null_glob extendedglob

  print_section "--- Startup files"
  local -a startup_files
  startup_files=($include_dir/zshrc $include_dir/sources.zsh $include_dir/functions.zsh)
  local file
  for file in $startup_files; do
    [[ -r $file ]] && print -- " - $file"
  done

  local sources_file=$include_dir/sources.zsh
  if [[ -r $sources_file ]]; then
    print_section "--- Files sourced from sources.zsh"
    local line trimmed
    while IFS= read -r line; do
      trimmed=${line%%#*}
      trimmed=${trimmed##[[:space:]]#}
      trimmed=${trimmed%%[[:space:]]#}
      [[ -z $trimmed ]] && continue
      case $trimmed in
        source\ *)
          print -- " - ${trimmed#source }"
          ;;
        if\ \[\ -f\ *)
          print -- " - conditional: ${trimmed#* -f }"
          ;;
      esac
    done < "$sources_file"
  fi

  local variables_file=$include_dir/variables.zsh
  if [[ -r $variables_file ]]; then
    print_section "--- Environment defaults and exports"
    while IFS= read -r line; do
      [[ $line == \#* || -z ${line//[[:space:]]/} ]] && continue
      case $line in
        export\ *)
          print -- " - ${line#export }"
          ;;
        :\ \{*)
          print -- " - default: ${line#: }"
          ;;
      esac
    done < "$variables_file"
  fi

  local history_file=$include_dir/history.zsh
  if [[ -r $history_file ]]; then
    print_section "--- History settings"
    command grep -Ev '^[[:space:]]*(#|$)' "$history_file" | while IFS= read -r line; do
      print -- " - $line"
    done
  fi

  local alias_output
  if (( $+functions[list-aliases] )); then
    alias_output=$(list-aliases 2>/dev/null)
    if [[ -n $alias_output ]]; then
      print_section "--- Aliases"
      while IFS= read -r line; do
        [[ -z $line ]] && continue
        print -- " - $line"
      done <<< "$alias_output"
    fi
  fi

  local modules module module_name module_functions
  modules=($include_dir/fn_*.zsh(N))
  if (( ${#modules} )); then
    print_section "--- Function modules"
    for module in $modules; do
      module_name=${module:t}
      module_functions=$(command awk '
        /^[[:space:]]*#/ { next }
        match($0, /^[[:space:]]*function[[:space:]]+([[:alnum:]_-]+)/, m) { print m[1]; next }
        match($0, /^[[:space:]]*([[:alnum:]_-]+)[[:space:]]*\(\)[[:space:]]*\{/, m) { print m[1]; next }
      ' "$module")
      if [[ -n $module_functions ]]; then
        print -- " - $module_name"
        while IFS= read -r fn; do
          [[ -z $fn ]] && continue
          print -- "   - $fn"
        done <<< "$module_functions"
      else
        print -- " - $module_name (no function definitions detected)"
      fi
    done
  fi

  local additional
  additional=($include_dir/*.zsh(N))
  if (( ${#additional} )); then
    print_section "--- Additional zsh snippets"
    for file in $additional; do
      case ${file:t} in
        fn_*|functions.zsh|variables.zsh|aliases.zsh|history.zsh|sources.zsh|zshrc)
          continue
          ;;
      esac
      print -- " - $file"
    done
  fi
}

function start_long_running_process {
    local job_name=$1
    /path/to/your/script_$job_name.sh > ~/background_jobs/${job_name}_output.txt &
    echo $! > ~/background_jobs/${job_name}_pid.txt
}


# Problem: using Ctrl-R to search for a file open in vim does not work
# unless absolute filepaths are used.  Solution:
# Instead of holding many files in one vim buffer, open them as you go,
# Ctrl-Z.
#resume_job() {
rj() {
  local job_id
  job_id=$(jobs -l | fzf --height 40% --layout=reverse --prompt="Select job: " | awk '{print $2}')
  if [[ -n "$job_id" ]]; then
    fg %"$job_id"
  else
    echo "No job selected."
  fi
}

save () {
  revision="$(git log --oneline | head -n1)"

  echo "# Generated on $(date)"      >  stdout.log
  echo "# git revision: ${revision}" >> stdout.log
  echo "# run in $(pwd)"             >> stdout.log
  echo "# standard out of \"$@\""    >> stdout.log
  echo ""                            >> stdout.log

  echo "# Generated on $(date)"      >  stderr.log
  echo "# git revision: ${revision}" >> stderr.log
  echo "# run in $(pwd)"             >> stderr.log
  echo "# standard err of \"$@\""    >> stderr.log
  echo ""                            >> stderr.log

  "$@" > >(tee -a stdout.log) 2> >(tee -a stderr.log >&2)
}

#
#
# # # # # # #

















# # # # # # # # # # # # #
# Section: Finding special tags
#
#

ignored_dirs="_archived tmp"
#keywords_to_crawl="todo ##consider thought"
keywords_to_crawl="##starred ##todo"
# ##washere
# see: vim-usage for more of this pattern
# NOTE skip: not a good navi cheatsheet candidate, keep as function
#### keyword search
search_files() {
    local -a keywords=()
    local -a exclude_dirs=()
    local parsing_excludes=0
    local arg

    for arg in "$@"; do
        if [[ "$arg" == "--" ]]; then
            parsing_excludes=1
            continue
        fi

        if (( parsing_excludes )); then
            exclude_dirs+=("$arg")
        else
            keywords+=("$arg")
        fi
    done

    if (( ${#keywords[@]} == 0 )); then
        echo "search_files: at least one keyword is required" >&2
        return 1
    fi

    local reports_dir="$PERSONAL_DIR/reports"
    if command -v rg >/dev/null 2>&1; then
        local -a rg_args=(--no-heading --line-number --ignore-case)
        local dir
        local kw
        for dir in "${exclude_dirs[@]}"; do
            rg_args+=(--glob "!$dir")
        done

        for kw in "${keywords[@]}"; do
            rg_args+=(-e "$kw")
        done

        rg "${rg_args[@]}" "$reports_dir"
    else
        local -a grep_args=(-rniI --color=auto)
        local dir
        local kw
        for dir in "${exclude_dirs[@]}"; do
            grep_args+=("--exclude-dir=$dir")
        done

        for kw in "${keywords[@]}"; do
            grep_args+=(-e "$kw")
        done

        grep "${grep_args[@]}" "$reports_dir"
    fi
}

crawl_keywords() {
    local -a keywords=("$@")
    local -a exclude=( ${=ignored_dirs} )
    if (( ${#exclude[@]} )); then
        search_files "${keywords[@]}" -- "${exclude[@]}"
    else
        search_files "${keywords[@]}"
    fi
}

do_crawl() {
    crawl_keywords "$@"
}
#
#
# # # # # # # # 















# # # # # #  
