# [Fri Jan 12 11:43:35 2018]
# source custom zsh, not including oh-my-zsh.

INCLUDE=/opt/chef/cookbooks/development-setup/files/zsh

source $INCLUDE/aliases.zsh
source $INCLUDE/ruby.zsh
source $INCLUDE/variables.zsh
# source $INCLUDE/moveme.zsh # left over from before
# source $INCLUDE/numpad.zsh

WORK_ZSHRC=~/projects/sandbox/zshrc
if [ -f $WORK_ZSHRC ]; then
  source $WORK_ZSHRC
fi

