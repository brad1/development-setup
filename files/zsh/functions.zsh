# # # # # # #
# Local variables
#


fp_copied_paths=/var/brad/copied-paths.list
jobsd=/var/brad/login-splash-jobs

#
#
# # # # # # #

#
## expansion:
# dump grep result to csv so that I can math w/ excel
#

# <context>-<object>-<verb>
# shell-vbox-list
procs-vbox-list() {
  echo "try: ps aux | grep -i vboxman"
}

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


#### keyword search
#
#
#

ignored_dirs="_archived tmp"
#keywords_to_crawl="todo ##consider thought"
keywords_to_crawl="##starred"

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

shell_login_overview() {
  do_crawl $(echo $keywords_to_crawl)
}

##################


debug=0  # set to 1 for debugging output

cdd () {
    if (( $debug )); then
        echo "Searching for directory '$1'..."
    fi
    target=$(timeout 2 find . -type d \( -name ".git" -o -name "release" \) -prune -o -name $1 -print -quit 2> /dev/null)
    if [[ -z $target ]]
    then
        echo "Directory '$1' not found or operation timed out."
    else
        cd $target
        if (( $debug )); then
            echo "Changed directory to '$target'."
        fi
    fi
}

archive() {
  # consider prompting for archive reason, tack onto beginning of file
  mv "$1" "$ARCHIVE"
}

gcof() {
  git checkout $(git-branches-list | fzf)
}

gcobf() {
  git checkout -b $(git-branches-list | fzf)
}

bash-builtins() {
  man dirs
}

cp-from-downloads() {
  cp ~/Downloads/vmass*$1*bin ~/Projects/vmass
}

browse-journal() {
  (
    cd ~/Documents/txt/archive/journal
    ranger
  )
}

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

path-of() {
  echo `pwd`/$1
}

make-list-targets() {
  make -pRrq -f Makefile | awk -F: '/^[a-zA-Z0-9][^$#\/\t=]*:([^=]|$)/ {print $1}' | sort | uniq
}

git-backup-branch() {
  git checkout -b $(git branch --show-current)-backup_$(date +'%m-%d-%Y')
}

git-diff-main-summarize() {
  git diff --stat main $(git branch --show-current)
}

git-diff-main() {
  git diff main $(git branch --show-current)
}

git-diff-master-summarize() {
  git diff --stat master $(git branch --show-current)
}

git-diff-master() {
  git diff master $(git branch --show-current)
}

vim-files-changed-in-branch() {
  git diff $(git branch --show-current) master --name-only > /tmp/asdf
  vim $(cat /tmp/asdf | fzf)
}

vim-files-modified () {
  vim "$(git status --short | awk "{print \$2}" | fzf)"
}

git-branch() {
  git checkout -b "$1"
  echo "$1" >> /var/brad/lists/branches.list
}

git-branches-list() {
  cat /var/brad/lists/branches.list
}

git-branches-edit() {
  vim /var/brad/lists/branches.list
}

# subshell variable data
# (stickied snippets)
sub-var() {
  mkdir -p /var/brad
  lastpwd="$(pwd)"
  cd /var/brad
  /usr/bin/zsh
  cd $lastpwd
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

#prompt-journal() {
#  datestr="$(date +'%m-%d-%Y')"
#  jpath="/home/brad/Documents/txt/archive/journal/$datestr"
#  if ! [[ -e "$jpath" ]] ; then
#    echo 'no journal entry... make one? (y/n)'
#    read var
#    if [[ "$var" = "y" ]] ; then
#      open-journal
#    fi
#  else
#    # print out the last thing I was doing
#    cat "$jpath/start" | tail -n15
#  fi
#}

#open-journal() {
#  datestr="$(date +'%m-%d-%Y')"
#  jpath="/home/brad/Documents/txt/archive/journal/$datestr"
#  mkdir -p $jpath
#  vim "$jpath/start"
#}

prompt-clipboard() {
  if ! [[ -e ~/Documents/txt/var/.clipboard.swp ]] ; then
    echo 'open clipboard? (y/n)'
     read var
     if [[ "$var" = "y" ]] ; then
       vim-clipboard
     fi
  fi
}

function start_long_running_process {
    local job_name=$1
    /path/to/your/script_$job_name.sh > ~/background_jobs/${job_name}_output.txt &
    echo $! > ~/background_jobs/${job_name}_pid.txt
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

reload-aliases() {
  source "$DEVSETUP/files/zsh/aliases.zsh"
}

reload-functions() {
  source "$DEVSETUP/files/zsh/functions.zsh"
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

# TODO factor these out

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

cdf() {
  cd "$(find . -type d | fzf)"
}

find-with() {
  # better way!
  find . -iname "*$1*" -not -path "./.git/*" -not -path "./release/*"
}

am_I_in_ranger() {
  ps aux | grep "$PPID" | grep -qa ranger && echo "You are in ranger" || echo "not in ranger"
}

# temporary one-off
lnb() {
  #files="$(find `pwd`/vipsched -type f -name \*cap\* | grep -v capybara | grep -v capabilities | grep -v vendor)"
  #files="$(ag -l ':class_name')"
  files="$(find `pwd`/vipsched -type f -name \*ldap\* | grep -v capybara | grep -v capabilities | grep -v vendor)"
  mkdir -p ldap_links
  for f in $(echo $files | xargs); do ln -sf "$f" ldap_links; done
}

# related: find `pwd`/vipsched -name \*cap\* | grep -v capybara | grep -v capabilities | grep -v vendor
lna() {
  ln -sf `pwd`/$1 links
}

lsg() {
  ls -lah | grep "$1"
}

ln-first() {
  ln -sf $(find . -name "$1" | head -n1)
}

grebase () {
  git rebase -i HEAD~$1
}

grebase-master () {
  branch=$(git rev-parse --abbrev-ref HEAD)
  git stash
  git checkout master
  git pull
  git checkout $branch
  git rebase master
}

git-append () {
  git commit --amend --no-edit
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

function goto_devsetup() {
 BUFFER="cd $DEVSETUP"$BUFFER
 zle end-of-line
 zle accept-line
}
zle -N goto_devsetup
bindkey "^g" goto_devsetup
function goto_home() {
 BUFFER="cd ~/"$BUFFER
 zle end-of-line
 zle accept-line
}
zle -N goto_home
bindkey "^h" goto_home
function up_widget() {
	BUFFER="pushd . >/dev/null; cd .."
	zle accept-line
}
zle -N up_widget
bindkey "^k" up_widget
function down_widget() {
	BUFFER="popd > /dev/null"
	zle accept-line
}
zle -N down_widget
bindkey "^j" down_widget


# consider a new pattern:
# thread readme # opens file
# thread readme a new comment # appends to file
# thread read...  # with autocomplete
readme () {
  cd ~/Documents/vim
  vim raw/log
}

#readme () {
#  cd ~/Documents/vim/raw
#  list=$(ls | grep -v collapse)
#  terminal_height=$(tput lines)
#  file_length=$(cat $(echo $list | tail -1) | wc -l)
#  if [[ "$file_length" -gt "$terminal_height" ]]; then
#    echo $(date +%Y%m%d) >> $(date +%Y%m%d)
#  fi
#  vim $(ls | grep -v collapse | xargs)
#}

# readme () {
#  vim readme     # no
#  vim **/readme  # maybe
#  vim ~/Projects/**/readme # better
#  vim ~/Documents/vim/raw/...  ~/Projects/**/readme # start with the global, than add others
#  ...
#}

# Use vimf instead
# vimm () {
#  vim $(find . -name \*$1\*)
#}
#
#
function cd-vmass () {
  cd ~/Projects/vmass
}

function cd-recent () {
  cd "$(dirs|xargs -n1|fzf|sed 's/~/\/home\/brad/')"
}

function copy-artifacts () {
  cp ~/Downloads/artifacts* .
}

function du-ch () {
  du -ch * | sort -h
}

function vimf () {
  vim $(fzf)
}

function rmf () {
  rm $(fzf)
}

function catf () {
  cat $(fzf)
}

function linkf () {
  ln -sf $(fzf)
}


# # # menu

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
  $command
}

# Main menu

#shell-status2() {
shell-status2-bak() {
  echo "press 'a' for a command menu"
  echo "press 's' to connect to a server"
  echo "press 'd' to select a bookmarked directory" # consider using ranger bookmarks going forward
  echo "press 'f' to edit these lists"
  echo
  echo "press 'gh' for git commands"
  echo "press 'h' to edit hostfile"
  echo
  echo "press 'j' "
  echo "press 'k' ..."
  echo "press 'l' ..."
  echo
  echo "press 'e' to edit a pinned file"
  echo "press 'c' to cheatsheets"
  echo "press 'o' for open-interpreter"
  echo
  echo "press 'co' contexts"
}

#splash_screen() {
shell-status2() {
    # Clear the screen
    clear

    # Set some formatting
    local line="+------------------------+------------------------+"
    local format="| %-22s | %-22s |"

    # Print the layout using formatted printf statements
    echo $line
    printf "$format\n" "'a' command menu" "'gh' git commands"
    printf "$format\n" "'s' connect to server" "'h' edit hostfile"
    printf "$format\n" "'d' bookmarked dir" "'j' ..."
    printf "$format\n" "'f' edit lists" "'k' ..."
    echo $line
    printf "$format\n" "'e' edit pinned file" "'l' ..."
    printf "$format\n" "'c' cheatsheets" "'o' open-interpreter"
    printf "$format\n" "'co' contexts" "'cw' work cheatsheets"
    echo $line

    echo
    echo 'New commands to try:'
    echo '    exa'
    echo '    vim-usage'
    echo '    cdf (or cd Ctrl+t)'
    echo '    last [reboot]'
    echo '    arc scratch.txt' 
    echo '    rg -tsh -e "todo" -trb -e "function" -tjava -e "System.out.print"'
    echo 'Commands to remember:'
    echo '    c -> chatgpt-general-document.txt'
    echo '    pgrep -af postinstall'
    echo '    pstree $(pgrep -f postinstall | head -n1)'
    echo '    compgen -c | fzf | xargs man'
    echo '    diff <(make -p) <(make -np)'
    echo '    man -k systemd' 
    echo '    find /path/to/search -group apache ! -perm /o+r'
    echo 'Things to add:'
    echo '    expanded history (Ctrl-R instead of "a" for tagged command search)'
    echo '    cw (cheatsheet for work, not in github)'
    echo '    Ctrl-R:'
    echo '    - import sticking commands (for Ctrl-R)'
    echo '    - fzf in reverse search...'
    echo 'Glen initiatives:'
    echo '     TPS boot menu + EFI'
    echo '     6.1 - audio/image file reboot, delete legacy SQL'
    echo '     SiteManager - strip, restructure, LFS' 
    echo '     Schedules export (Chad)' 
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


#archive_file() {
arc() {
    local source_file="$1"
    if [[ ! -f "$source_file" ]]; then
        echo "Error: $source_file does not exist or is not a regular file."
        return 1
    fi
    
    local timestamp="$(date +%Y%m%d%H%M)"
    local renamed_filename="${source_file}-archived-${timestamp}.txt"
    
    mv "$source_file" "$renamed_filename"
    touch "$source_file"
    
    echo "File archived as ${renamed_filename}"
}



vim-usage() {
  # TODO inspired by make usage
  # grep ~/.vimrc for ## and display results
  grep '##' ~/.vimrc
}


# aliases are weak!
a () {
  auto
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

f () {
   $EDITOR /var/brad/lists/$(ls /var/brad/lists|fzf)
}

# already used by git
#g () {
#   $view /var/brad/running-lists/$(ls /var/brad/running-lists|fzf)
#}

gh () {
  $(cat /var/brad/lists/commands-git.list|fzf)
}

h () {
  # Move to 'j', fix the full filepath displaying
  # view $(echo /var/brad/running-lists/*.list|fzf)
  sudo vim /etc/hosts
}

# consider replacing with 'autojump'
e () {
  file_path=$(cat /var/brad/lists/files-pinned.list|fzf)
  evaluated_path=$(echo "$file_path" | sed "s|~|$HOME|g")
  $EDITOR $evaluated_path
}

c () {
  fn=$(cd /opt/chef/cookbooks/development-setup/files/cheatsheets/; ls | fzf)
  # from cheatsheets.list ?
  # evaluated_path=$(echo "$file_path" | sed "s|~|$HOME|g")
  $EDITOR /opt/chef/cookbooks/development-setup/files/cheatsheets/$fn
}

cw () {
  fn=$(cd ~/Projects/cheatsheets/; ls | fzf)
  $EDITOR ~/Projects/cheatsheets/$fn
}

o () {
  oi_dir="/home/brad/Projects/_projects-research/open_interpreter"
  gnome-terminal --tab -- bash -c "cd '$oi_dir' && . ./init.sh; exec bash"

}

p () {
   echo "python3 manage.py showmigrations"
   echo "python3 manage.py migrate database 0040_file_name_handling"
   echo "ln -sf /opt/vmass/server_api"
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
