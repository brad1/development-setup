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


fp_copied_paths=/var/brad/copied-paths.list
jobsd=/var/brad/login-splash-jobs
zsh_functions_debug=0

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
  zsh -c 'source /opt/chef/cookbooks/development-setup/files/zsh/fn_core.zsh; \
          source /opt/chef/cookbooks/development-setup/files/zsh/fn_file.zsh; \
          source /opt/chef/cookbooks/development-setup/files/zsh/fn_shortcuts.zsh; \
          source /opt/chef/cookbooks/development-setup/files/zsh/fn_login.zsh; \
          print -l ${(ok)functions}'
  zsh -c 'source /opt/chef/cookbooks/development-setup/files/zsh/aliases.zsh; alias | cut -d= -f1'
}

list-aliases() { # for definition 
  zsh -c 'source /opt/chef/cookbooks/development-setup/files/zsh/aliases.zsh; alias'
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
    keyword=$1
    shift  # Remove the first argument and shift the rest to the left
    exclude_dirs=""
    for dir in "$@"; do
        exclude_dirs="$exclude_dirs --exclude-dir=$dir"
    done
    # zsh does not split strings by default
    grep -rniI --color $(echo $exclude_dirs) "$keyword" /var/brad/reports
}

crawl_keywords() {
    local kw="$1"
    search_files "$kw" $(echo $ignored_dirs)
}

do_crawl() {
    for kw in $@; do
        crawl_keywords $kw
    done
}
#
#
# # # # # # # # 















# # # # # #  
