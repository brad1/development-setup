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
	BUFFER="pushd .; cd .."
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
