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

