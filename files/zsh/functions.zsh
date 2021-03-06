shell-status() {
  echo "date-time: $(date "+%D - %H:%M:%S")"
  echo "user: $(whoami)"
  echo "pwd: $(pwd)"
  echo "subshells:"
  pstree -ps $$
  g st 2>/dev/null | grep 'On branch' > /tmp/shell-status-git && echo "git: $(cat /tmp/shell-status-git)"
  echo "jobs: "
  echo "------------------"
  jobs
  echo "------------------"
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

cheatsheet-python() {
  fn="$DEVSETUP/files/cheatsheets/python.txt"

  if [ "$1" = "edit" ] ; then
    vim "$fn"
    return
  fi

  if [ "$1" = "sum" ] ; then
    cat "$fn" | grep context
    return
  fi

  echo "Usage: cheat-python <edit|sum>"

}

cdf() {
  cd "$(find . -iname "$1" | head -n1)"
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
