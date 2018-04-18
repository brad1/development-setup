readme () {
  cd ~/Documents/vim/raw
  list=$(ls | grep -v collapse)
  terminal_height=$(tput lines)
  file_length=$(cat $(echo $list | tail -1) | wc -l)
  if [[ "$file_length" -gt "$terminal_height" ]]; then
    echo $(date +%Y%m%d) >> $(date +%Y%m%d)
  fi
  vim $(ls | grep -v collapse | xargs)
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

# readme () {
#  vim readme     # no
#  vim **/readme  # maybe
#  vim ~/Projects/**/readme # better
#  vim ~/Documents/vim/raw/...  ~/Projects/**/readme # start with the global, than add others
#  ...
#}
