INCLUDE=/opt/chef/cookbooks/development-setup/files/zsh

source $INCLUDE/aliases.zsh
source $INCLUDE/ruby.zsh
source $INCLUDE/variables.zsh
# keep: user prefers sourcing the aggregate functions.zsh file
source $INCLUDE/functions.zsh
source $INCLUDE/history.zsh
# source $INCLUDE/moveme.zsh # left over from before
# source $INCLUDE/numpad.zsh


if [ -f $WORK_ZSHRC ]; then
  source $WORK_ZSHRC
fi

# secure configuration
if [ -f ~/.noscm.zsh  ]; then
  source ~/.noscm.zsh
fi
