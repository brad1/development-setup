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


# run in one tmux tab to keep the task separate and tracked
# expand
build-portal() {
    export HISTFILE=$HOME/.build_portal_history
}

# run in one tmux tab to keep the task separate and tracked
# expand
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

list-functions() { # and aliases, for selection
  zsh -c 'source /opt/chef/cookbooks/development-setup/files/zsh/functions.zsh; print -l ${(ok)functions}'
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
# Section: File mgmt
#
#
#

paste-paths() {
  while read item; do
    cp -r "$item" .
  done <$fp_copied_paths
  rm $fp_copied_paths
}

list-copied-paths() {
  cat $fp_copied_paths 2>/dev/null
}

# could also just copy files to /tmp/tmp1/
# then re-copy to final destination, cleanup tmp1
copy-path() {
  path-of $1 >> $fp_copied_paths
}

# copy from commit
cfc () {    
  for item in $(git show --name-only --format= $1) ; do    
    copy-path $item
  done    
}

# favor ln -s /usr/bin/batcat ~/.local/bin/bat 
#bat() {
#  batcat
#}


# More commands
# echo '    pstree $(pgrep -f postinstall | head -n1)'
# echo '    compgen -c | fzf | xargs man'
#  cd $(ls | head -n1) ; vagrant destroy -f ; cd .. ; rm -rf $(ls | head -n1) # mass delete


#archive_file() {

# Section: editor shortcuts vim
#


# neat, but use :Tags from fzf.vim 

prompt-clipboard() {
  if ! [[ -e ~/Documents/txt/var/.clipboard.swp ]] ; then
    echo 'open clipboard? (y/n)'
     read var
     if [[ "$var" = "y" ]] ; then
       vim-clipboard
     fi
  fi
}

#
#
# # # # # # # # # # #




# # # # # # # # # # # #
# Section: Shortcuts
#
# (ohmyzsh maps all control keys by default)

# Keep Ctrl-K kill-line,
# double tap K to cd ..
bindkey -s '^K^K' 'cd ..^M'


# Allow:
# Ctrl-G --> command palette search --> LBUFFER --> ^X^E --> vi mode edit
eval "$(navi widget zsh)"

# search all custom navi cheatsheets
# NO EDIT :(
navi-custom() {
    local cheatsheet=$(ls /home/brad/.local/share/navi/cheats/custom/*.cheat | xargs -n 1 basename | sed 's/\.cheat$//' | fzf --prompt="Select Cheatsheet: ")
    [[ -z "$cheatsheet" ]] && return  # Exit if no selection

    #local cmd=$(navi --print --query "$cheatsheet ")
    navi --print --query "$cheatsheet "
    #LBUFFER+="$cmd"
    #zle redisplay
}
zle -N navi-custom

# search command palettes
# works, but would be better to --print to vi mode for easier editing
# - for now, ^x^e to edit the printed command
# see: vi mode
# NO EDIT :(
navi-palettes() {
    local cheatsheet=$(ls /home/brad/.local/share/navi/cheats/custom/collections*.cheat | xargs -n 1 basename | sed 's/\.cheat$//' | fzf --prompt="Select Cheatsheet: ")
    [[ -z "$cheatsheet" ]] && return  # Exit if no selection

    #local cmd=$(navi --print --query "$cheatsheet ")
    navi --print --query "$cheatsheet "
    #LBUFFER+="$cmd"
}

# Not quite there
# - open found command to vi mode
#navi-vim-widget() {
#    local cmd=$(navi --print | tail -n 1)
#    BUFFER="vim -c 'startinsert' -c \"normal! i$cmd\" scratchpad"
#    zle accept-line
#}
#zle -N navi-vim-widget
#bindkey '^g' navi-vim-widget

# show_on_login
a () {
  auto
}

b () {
  fzf_menu_exp
}

s () {
  echo "Use: sshf for valcom servers"
  echo "Use: ssh-gitlab-web for gitlab"
  #ssh brad@$(cat /var/brad/lists/servers.txt | fzf)'

}

# consider replacing with 'cdargs' or 'z' or 'autojump'
d () {
  dest="$(cat /var/brad/lists/dirs.list | fzf)"
  dest="${dest/#\~/$HOME}"
  cd "$dest"
}

gh () {
  $(cat /var/brad/lists/commands-git.list|fzf)
}


# consider replacing with 'autojump'
e () {
  file_path=$(cat /var/brad/lists/files-pinned.list|fzf)
  evaluated_path=$(echo "$file_path" | sed "s|~|$HOME|g")
  $EDITOR $evaluated_path
  echo $evaluated_path
}

c () {
  fn=$(cd /opt/chef/cookbooks/development-setup/files/cheatsheets/; ls | fzf)
  # Next: use bat or glow to view MDs
  # from cheatsheets.list ?
  # evaluated_path=$(echo "$file_path" | sed "s|~|$HOME|g")
  $EDITOR /opt/chef/cookbooks/development-setup/files/cheatsheets/$fn
}

cw () {
  fn=$(cd ~/Projects/cheatsheets/; ls | fzf)
  $EDITOR ~/Projects/cheatsheets/$fn
}


co () {
  pth=/var/brad/contexts
  fn=$(ls $pth|fzf)
  fp=$pth/$fn
  echo "Opening $fn, press enter within 2 seconds to cat instead."
  if read -t 2; then
    #cat "$fp"
    cat "$fp"
  else
    $EDITOR "$fp"
  fi
}


f () {
  list-functions|fzf > /var/brad/tmp/command
  eval $(cat /var/brad/tmp/command)
}

fzf_insert_function() {
  LBUFFER+=$( ( print -l ${(ok)functions} ; alias | cut -d= -f1 ) | fzf )
}
zle -N fzf_insert_function
# Control-F - Search all functions
#bindkey '^f' fzf_insert_function

v () {
  fn=$(ls /var/brad/filegroups/|fzf)
  $EDITOR $(cat /var/brad/filegroups/$fn)
}

ve () {
  fn=$(ls /var/brad/filegroups/ | fzf)
  for f in $(cat /var/brad/filegroups/$fn); do
    gnome-terminal --tab -- bash -c "$EDITOR $f; exec bash"
  done
}

vim_insert_function() {
  grep 'SELECTME' $(find /home/brad/.command_palettes/ -type f | fzf ) > /tmp/commandspals 
  cat /tmp/commandspals | fzf > /tmp/command
  #LBUFFER+=$( cat /tmp/command | awk -F '$' '{print $1}' )
  command=$( cat /tmp/command | awk -F '#' '{print $1}' )

  LBUFFER+="$command"
  return
}
# old
# favor navi collections_.*cheat
#zle -N  vim_insert_function 
#bindkey '^v'  vim_insert_function

# Alternative to fzf-history-widget
#fzf_insert_history() {
#  LBUFFER+=$(fc -l 1 | fzf | sed 's/^[ ]*[0-9]*[ ]*//')
#}
#zle -N fzf_insert_history
#bindkey '^r' fzf_insert_history
#

#
#
# # # # # # # # # # # #




# # # # # # # # # # # #
# Section: login splash and discoverability
#

# see section: Shortcuts and control keys
# see section: interactive selection

# Tab complete for palette discovery?

# # # # deprecated use navi

fzf-commands () {
  cat /var/brad/lists/commands-fzf.list|fzf > /var/brad/tmp/command
  command=$(cat /var/brad/tmp/command)
  $command
}

git-commands () {
  $(cat /var/brad/lists/commands-git.list|fzf)
}

zsh-commands () {
  cat /var/brad/lists/commands-zsh.list|fzf > /var/brad/tmp/command
  command=$(cat /var/brad/tmp/command)
  $command
}

auto () {
  cat /var/brad/lists/commands.list|fzf > /var/brad/tmp/command
  command=$(cat /var/brad/tmp/command)

shell_login_overview() {
  do_crawl $(echo $keywords_to_crawl)
}

shell-status() {
  echo "date-time: $(date "+%D - %H:%M:%S")"
  echo "user: $(whoami)"
  echo "pwd: $(pwd)"
  echo "subshells: $(pstree -ps $$)"

  # in zsh shell banner
  #g st 2>/dev/null | grep 'On branch' > /tmp/shell-status-git && echo "git: $(cat /tmp/shell-status-git)"

# pwdx or lsof -p or readlind -e /proc/PID/pwd
# to show all dirs in use


  #echo "shellopts: "
  #echo "{"
  #set -o|egrep -w "(vi|emacs)" | awk '{print "    " $0}'
  #echo "}"
  echo "jobs: "
  echo "{"
  jobs | awk '{print "    " $0}'
  echo "}"

  #echo
  #echo -n "other shells: "

  #pid="$(pgrep -x 'tmux: server')"
  #pstree -p "$pid"
  #pid="$(pgrep 'gnome-terminal')"
  #stree -p "$pid" | grep -Eo 'gnome-terminal-..[0-9]+\)' | xargs
  #cho


  echo "Disk usage:"
  echo '{'
  df -h 2>/dev/null | grep fedora | awk '{ print "    " $0 }'
  echo '}'

  # network info:
  echo 'IP addresses:'
  echo '{'
  echo "wlo1 eno1" | xargs -n1 ip addr show | awk '/inet / {print "    " $2}'
  echo '}'
  echo

  mkdir -p /var/brad/login-splash-jobs

  # tmux sessions
  echo 'Tmux sessions:'
  echo '{'
  tmux ls
  echo '}'
  echo

  echo "To change this, see run zsh-functions and see 'shell-status'"

  echo
  echo
  echo

  echo "Outstanding Solveables:"
  ls /var/brad/solveables/

  echo
  echo
  echo

  # don't run jobs at every new terminal
  return

  # slow!
  # vagrant status >/tmp/vagrant-status 2>/dev/null && echo "vagrant: $(grep bootstrap /tmp/vagrant-status)"

  # suppress job complete messages, does this belong here?
  # set +m

  # better, still slow and too verbose
  echo -n "Checking vagrant VMs...   "
  vagrant global-status --prune >$jobsd/vagrant-global-status-prune.log 2>&1 &

  echo -n "Timing search for TODOs...   "
  (
    date
    cd "$PRIMARY_PROJECT"
    grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox,\*venv,\*java,\*vendor,\*server_env,\*node_modules,\*dist,\*release} -r "TODO" .
    # TODO fix this if it gets too slow
    #grep -r "TODO" "$PRIMARY_PROJECT"
    date
  ) > $jobsd/grep-todo.log 2>&1 &

  # prompt-journal
  # prompt-clipboard

  echo "To change this, see run zsh-functions and see 'shell-status'"
}


summarize-cheatsheet() {
  cat "$DEVSETUP/files/cheatsheets/$1.txt" | grep context
}

cheatsheet() {
  fn="$DEVSETUP/files/cheatsheets/$2.txt"

  if [ "$1" = "edit" ] ; then
    vim "$fn"
    return
  fi

  if [ "$1" = "sum" ] ; then
    cat "$fn" | grep context
    return
  fi

  if [ "$1" = "print" ] ; then
    cat "$fn" | grep -A 15 "context.*$3"
    return
  fi

  echo "Usage: cheat-$2 <edit|sum|print>"

}

cheat-vim() {
  cheatsheet "$1" "vim" "$2"
}

cheat-awk() {
  cheatsheet "$1" "awk" "$2"
}


cheat-git() {
  cheatsheet "$1" "git" "$2"
}

cheat-postgres() {
  cheatsheet "$1" "postgres" "$2"
}

cheat-python() {
  cheatsheet "$1" "python" "$2"
}

cheat-sysadmin() {
  cheatsheet "$1" "sysadmin" "$2"
}

cheat-sed() {
  cheatsheet "$1" "sed" "$2"
}

cheat-bash() {
  cheatsheet "$1" "bash" "$2"
}


#splash_screen() {
shell-status2-2024() {
    # Clear the screen
    clear


    echo
    echo 'New commands to try:'
    echo '    https://github.com/twinnydotdev/twinny - local chat complete + voice'
    echo '    exa'
    echo '    vim-usage'
    echo '    last [reboot]'
    echo '    arc scratch.txt # arbitrary terminal captures in "reports" to keep clipboard clean'  
    echo '    rg -tsh -e "todo" -trb -e "function" -tjava -e "System.out.print" # file type filtering'
    echo '    vim-goto # hop to a pattern'
    echo '    rj # resume job fzf' 
    echo '    column # -x, -t, -s, ...' 
    echo 'Commands to remember:'
    echo '    find /path/to/files -type f -mtime +7 -delete'
    echo '    c -> chatgpt-general-document.txt # for shorthand, labeled instructions'
    echo '    pgrep -af postinstall'
    echo '    diff <(make -p) <(make -np)'
    echo '    man -k systemd' 
    echo '    find /path/to/search -group apache ! -perm /o+r'
    echo 'Things to add:'
    echo '    expanded history (Ctrl-R instead of "a" for tagged command search)'
    echo '    Ctrl-R:'
    echo '    - import sticking commands (for Ctrl-R) # over time these may become functions'
    echo '    - fzf in reverse search...'
    echo 'Glen initiatives:'
    echo '     6.2 - audio/image file reboot, delete legacy SQL, move C code and scripts/'
    echo '     Schedules export (Chad)' 
    echo 'My initiatives:'
    echo '     AutoUpdates - outline and labels for next meeting'
    echo '     smoke test expand PM events are next? control packets?' 
    echo '     PDP - friday kubernetes practice' 
    echo '     Stress.sql'
    echo '     tripwire'
    echo '     smoke test expand (note that selenium job VM pcrunner missing default provider)'
    echo 'Ubuntu:'
    echo '     https://ubuntu.com/core/docs/networkmanager/networkmanager-and-netplan'
    echo "We propose instead that one begins with a list of difficult design decisions or design decisions which are likely to change. Each module is then designed to hide such a decision from the others."
    echo "-  Parnas' 1972 paper 'On the Criteria To Be Used in Decomposing Systems into Modules'"
    echo
    echo
    echo '---- Pending action items: ----'
    echo

    # TODO test and expand
    shell_login_overview 
}
    

shell-status2() {
    clear

    # NExt - Control - ? workflow selection
    # List simple control kep mappings
    # bindkey | grep -E '"\^[^[]{1}'

    # not quite there, plus other utilities above aren't control keys
    #fn=/opt/chef/cookbooks/development-setup/files/zsh/functions.zsh
    #echo 'Custom control keys:'
    #grep '^bindkey' $fn | awk -F'#' '{if ($2) print $2, $3 }'
    
    echo 'Shortcuts:'
    echo '    b()   Ctrl-G (navi search)' 
    echo 'New commands to try (preview):'
    grep '^    ' /home/brad/.local/share/navi/cheats/custom/brad_try_next.cheat | head -n5
    echo '    ...'
    echo 'Commands to remember (preview):'
    grep '^    ' /home/brad/.local/share/navi/cheats/custom/brad_reminder.cheat | head -n5
    echo '    ...'
    echo 'Things to add:'
    echo '    expanded history (Ctrl-R instead of "a" for tagged command search)'
    echo '    Ctrl-R:'
    echo '    - import sticking commands (for Ctrl-R) # over time these may become functions'
    echo '    - fzf in reverse search...'
    echo 'My initiatives:'
    echo '     AutoUpdates - outline and labels for next meeting'
    echo '     Expand end to end tests'
    echo '     PDP - friday kubernetes practice' 
    echo '          left off on fastbuilder: microk8s kubectl logs -f kibana-kibana-7445df7ffb-kgqnc'
    echo '            http://192.168.46.156:5601/'
    echo '     Stress.sql'
    echo "We propose instead that one begins with a list of difficult design decisions or design decisions which are likely to change. Each module is then designed to hide such a decision from the others."
    echo "-  Parnas' 1972 paper 'On the Criteria To Be Used in Decomposing Systems into Modules'"
    echo
    echo
    echo '---- Pending action items: ----'
    echo

    # TODO test and expand
    shell_login_overview 

    # vagrant snapshot list already does this!
    # vagrant_snapshot_status /home/brad/Projects/sitemanager 

    #fzf_menu_exp
}

#
# end section login splash and discoverability
#
# # # # # # # # # # # #












# # # # # # # # # # # #
# Section: interactive selection
#
# principle: favor selection over definition
# also quicker and easier than:
# - clobbering an existing control key sequence
# - composing a long CKS like "^[Xdf...."

fzf_menu_exp() {

    MENU_ITEMS=(
        "function 'k' to list simple control keys" "k"
        "function 's' to connect to server" "s"
        "function 'h' to edit hostfile" "h"
        "function 'd' to open bookmarked dir" "d"
        "function 'f' for full function search" "f"
        "function 'navi-custom' for custom command search" "navi-custom"
        "function 'navi-palettes' for command palettes" "navi-palettes"
        "function 'e' to edit pinned file" "e"
        "function 'c' for cheatsheets" "c"
        "function 'cw' for work cheatsheets" "cw"
    )

# Generate a properly formatted list
MENU_LIST=""
for ((i = 1; i < ${#MENU_ITEMS[@]}; i+=2)); do
    MENU_LIST+="${MENU_ITEMS[i]}\n"
done


CHOICE=$(echo -e "$MENU_LIST" | fzf --prompt="Select an option: " --layout=reverse --height=50% --preview-window=wrap)

if [[ "Drop to Shell" == "$CHOICE" ]]; then
  return
fi

# Execute and quit
if [[ -n "$CHOICE" ]]; then
    for ((i = 1; i < ${#MENU_ITEMS[@]}; i+=2)); do
        if [[ "${MENU_ITEMS[i]}" == "$CHOICE" ]]; then
            ${MENU_ITEMS[i+1]}
            break
        fi
    done
fi

}

#
#
# # # # # # # # # # # #



















# # # # # # # ## # # # # #
# Section: deprecated control keys
#
#

#function goto_devsetup() {
# BUFFER="cd $DEVSETUP"$BUFFER
# zle end-of-line
# zle accept-line
#}
#zle -N goto_devsetup
#bindkey "^g" goto_devsetup
#function goto_home() {
# BUFFER="cd ~/"$BUFFER
# zle end-of-line
# zle accept-line
#}
#zle -N goto_home
#bindkey "^h" goto_home
#function up_widget() {
#	BUFFER="pushd . >/dev/null; cd .."
#	zle accept-line
#}
#zle -N up_widget
#bindkey "^k" up_widget
#function down_widget() {
#	BUFFER="popd > /dev/null"
#	zle accept-line
#}
#zle -N down_widget
#bindkey "^j" down_widget

#
#
# # # # # # # #
