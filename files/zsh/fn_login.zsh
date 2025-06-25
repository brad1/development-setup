# Section: login splash and discoverability
#

# see section: Shortcuts and control keys
# see section: interactive selection

# Tab complete for palette discovery?

# # # # deprecated use navi

fzf-commands () {
  cat "$PERSONAL_DIR/lists/commands-fzf.list" | fzf > "$PERSONAL_DIR/tmp/command"
  command=$(cat "$PERSONAL_DIR/tmp/command")
  $command
}

git-commands () {
  $(cat "$PERSONAL_DIR/lists/commands-git.list" | fzf)
}

zsh-commands () {
  cat "$PERSONAL_DIR/lists/commands-zsh.list" | fzf > "$PERSONAL_DIR/tmp/command"
  command=$(cat "$PERSONAL_DIR/tmp/command")
  $command
}

auto () {
  cat "$PERSONAL_DIR/lists/commands.list" | fzf > "$PERSONAL_DIR/tmp/command"
  command=$(cat "$PERSONAL_DIR/tmp/command")
}

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

  mkdir -p "$PERSONAL_DIR/login-splash-jobs"

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
  ls "$PERSONAL_DIR/solveables/"

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
    grep '^    ' "$NAVI_CUSTOM_DIR/brad_try_next.cheat" | head -n5
    echo '    ...'
    echo 'Commands to remember (preview):'
    grep '^    ' "$NAVI_CUSTOM_DIR/brad_reminder.cheat" | head -n5
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
    # vagrant_snapshot_status "$HOME/Projects/sitemanager"

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
