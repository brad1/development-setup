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
      local cheatsheet=$(ls "$NAVI_CUSTOM_DIR"/*.cheat | xargs -n 1 basename | sed 's/\.cheat$//' | fzf --prompt="Select Cheatsheet: ")
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
      local cheatsheet=$(ls "$NAVI_CUSTOM_DIR"/collections*.cheat | xargs -n 1 basename | sed 's/\.cheat$//' | fzf --prompt="Select Cheatsheet: ")
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
  #ssh brad@$(cat "$PERSONAL_DIR/lists/servers.txt" | fzf)'

}

# consider replacing with 'cdargs' or 'z' or 'autojump'
d () {
  dest="$(cat "$PERSONAL_DIR/lists/dirs.list" | fzf)"
  dest="${dest/#\~/$HOME}"
  cd "$dest"
}

gh () {
  $(cat "$PERSONAL_DIR/lists/commands-git.list" | fzf)
}


# consider replacing with 'autojump'
e () {
  file_path=$(cat "$PERSONAL_DIR/lists/files-pinned.list" | fzf)
  evaluated_path=$(echo "$file_path" | sed "s|~|$HOME|g")
  $EDITOR $evaluated_path
  echo $evaluated_path
}

c () {
  fn=$(cd $DEVSETUP/files/cheatsheets/; ls | fzf)
  # Next: use bat or glow to view MDs
  # from cheatsheets.list ?
  # evaluated_path=$(echo "$file_path" | sed "s|~|$HOME|g")
  $EDITOR $DEVSETUP/files/cheatsheets/$fn
}

cw () {
  fn=$(cd ~/Projects/cheatsheets/; ls | fzf)
  $EDITOR ~/Projects/cheatsheets/$fn
}


co () {
  pth="$PERSONAL_DIR/contexts"
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
  list-functions|fzf > "$PERSONAL_DIR/tmp/command"
  eval $(cat "$PERSONAL_DIR/tmp/command")
}

fzf_insert_function() {
  LBUFFER+=$( ( print -l ${(ok)functions} ; alias | cut -d= -f1 ) | fzf )
}
zle -N fzf_insert_function
# Control-F - Search all functions
#bindkey '^f' fzf_insert_function

v () {
  fn=$(ls "$PERSONAL_DIR/filegroups/" | fzf)
  $EDITOR $(cat "$PERSONAL_DIR/filegroups/$fn")
}

ve () {
  fn=$(ls "$PERSONAL_DIR/filegroups/" | fzf)
  for f in $(cat "$PERSONAL_DIR/filegroups/$fn"); do
    gnome-terminal --tab -- bash -c "$EDITOR $f; exec bash"
  done
}

vim_insert_function() {
  grep 'SELECTME' $(find "$HOME/.command_palettes/" -type f | fzf ) > /tmp/commandspals
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
