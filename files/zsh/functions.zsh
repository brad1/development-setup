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

# readme () {
#  vim readme     # no
#  vim **/readme  # maybe
#  vim ~/Projects/**/readme # better
#  vim ~/Documents/vim/raw/...  ~/Projects/**/readme # start with the global, than add others
#  ...
#}
