INCLUDE=/opt/chef/cookbooks/development-setup/files/zsh
ZSH_THEME="powerlevel9k/powerlevel9k"

source $INCLUDE/aliases.zsh
source $INCLUDE/ruby.zsh
source $INCLUDE/variables.zsh
source $INCLUDE/functions.zsh
source $INCLUDE/history.zsh
# source $INCLUDE/moveme.zsh # left over from before
# source $INCLUDE/numpad.zsh

WORK_ZSHRC=~/Projects/sandbox/zshrc
if [ -f $WORK_ZSHRC ]; then
  source $WORK_ZSHRC
fi

# secure configuration
if [ -f ~/.noscm.zsh  ]; then
  source ~/.noscm.zsh
fi
