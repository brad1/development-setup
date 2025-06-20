export EDITOR=vim
export HISTFILE=~/.zsh_history
export HISTFILESIZE=1000000
export HISTSIZE=10
export SAVEHIST=100000

# export EXTERNAL_DRIVE=/run/media/brad/63c96aca-03db-4d1e-9baa-3f950b3d8897/

# path to this repository
: ${DEVSETUP:=/opt/chef/cookbooks/development-setup}
export DEVSETUP
: ${INCLUDE:=$DEVSETUP/files/zsh}
export INCLUDE
export PATH=$DEVSETUP/files/bin:$PATH
export PATH=~/.local/bin:$PATH # for tmuxp, etc from pip
export PATH=$HOME/.cargo/bin:$PATH

export WORK_ZSHRC=~/Projects/sandbox/zshrc
export TMPDIR=/tmp

# TODO: refactor to a list file or symlinks (persistance) w/ function to modify
export ACTIVE_PROJECTS="~/Projects/vmass ~/Projects/_1_builds/vmass-integration-test"
export ARCHIVE=~/Documents/txt/archive
