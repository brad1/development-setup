INCLUDE=/opt/chef/cookbooks/development-setup/files/zsh

source $INCLUDE/aliases.zsh
source $INCLUDE/ruby.zsh
source $INCLUDE/variables.zsh
source $INCLUDE/functions.zsh
# source $INCLUDE/moveme.zsh # left over from before
# source $INCLUDE/numpad.zsh

WORK_ZSHRC=~/projects/sandbox/zshrc
if [ -f $WORK_ZSHRC ]; then
  source $WORK_ZSHRC
fi

# secure configuration
if [ -f ~/.noscm.zsh  ]; then
  source ~/.noscm.zsh
fi
