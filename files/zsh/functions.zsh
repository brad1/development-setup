# # # # # # #
# Local variables
#


fp_copied_paths=/var/brad/copied-paths.list

#
#
# # # # # # #

#
## expansion:
# dump grep result to csv so that I can math w/ excel
#

gcof() {
  git checkout $(git-branches-list | fzf)
}

gcobf() {
  git checkout -b $(git-branches-list | fzf)
}

bash-builtins() {
  man dirs
}

my-dirs() {
  dest="$(cat /var/brad/lists/dirs.list | fzf)"
  dest="${dest/#\~/$HOME}"
  cd "$dest"
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

git-diff-master-summarize() {
  git diff --stat master $(git branch --show-current)
}

git-diff-master() {
  git diff master $(git branch --show-current)
}

vim-files-changed-in-branch() {
  #                           #             #              # filter to avoid binaries
  git diff $(git branch --show-current) master --name-only | > /tmp/asdf
  vim $(cat /tmp/asdf | grep .\*.rb$ | fzf)
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
  df -h | grep fedora | awk '{ print "    " $0 }'
  echo '}'

  # network info:
  echo 'IP addresses:'
  echo '{'
  echo "wlo1 eno1" | xargs -n1 ip addr show | awk '/inet / {print "    " $2}'
  echo '}'
  echo

  # slow!
  # vagrant status >/tmp/vagrant-status 2>/dev/null && echo "vagrant: $(grep bootstrap /tmp/vagrant-status)"

  # better, still slow and too verbose
  # vagrant global-status

  #prompt-journal
  prompt-clipboard
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
  cd "$(fzf)"
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
  cat /var/brad/lists/commands-git.list|fzf > /var/brad/tmp/command
  command=$(cat /var/brad/tmp/command)
  $command
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

# aliases are weak!
a () {
  auto
}
