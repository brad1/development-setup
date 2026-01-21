export EDITOR=vim
export HISTFILE=~/.zsh_history
export HISTFILESIZE=1000000
export HISTSIZE=10
export SAVEHIST=100000

# export EXTERNAL_DRIVE=/run/media/brad/63c96aca-03db-4d1e-9baa-3f950b3d8897/

# path to this repository
: ${DEVSETUP:=/opt/chef/cookbooks/development-setup}
# Alternatively:
# : ${DEVSETUP:=${${(%):-%x}:a:h:h:h}}
#
# ${(%):-%x} is a zsh parameter expansion that yields the path of the current sourced file (analogous to a “current script path”).
# :a turns that path into an absolute path.
# :h repeatedly takes the directory (head) of the path. With :h:h:h, it goes up three levels.
#
export DEVSETUP
: ${INCLUDE:=$DEVSETUP/files/zsh}
export INCLUDE
export PATH=$DEVSETUP/files/bin:$PATH
export PATH=~/.local/bin:$PATH # for tmuxp, etc from pip
export PATH=$HOME/.cargo/bin:$PATH

# Personal files and scratch space
: ${PERSONAL_DIR:=$HOME/.personal}
export PERSONAL_DIR

# Location for custom navi cheat sheets
: ${NAVI_CUSTOM_DIR:=$HOME/.local/share/navi/cheats/custom}
export NAVI_CUSTOM_DIR

export WORK_ZSHRC=~/Projects/sandbox/zshrc
export TMPDIR=/tmp

# Optional: run slow login jobs when launching the splash screen.
# Set to 1 to enable background checks like vagrant status.
: ${SHELL_STATUS_JOBS_ENABLED:=0}
export SHELL_STATUS_JOBS_ENABLED

# TODO: refactor to a list file or symlinks (persistance) w/ function to modify
export ACTIVE_PROJECTS="~/Projects/vmass ~/Projects/_1_builds/vmass-integration-test"
export ARCHIVE=~/Documents/txt/archive

export RSPEC_SEEDS="38588,54199,7108"

export FZF_CTRL_T_COMMAND='fd --type f --hidden --exclude vendor --exclude venv --exclude server_env'
