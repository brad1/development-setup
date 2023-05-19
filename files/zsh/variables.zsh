export EDITOR=vim
export HISTFILE=~/.zsh_history
export HISTSIZE=1000
export SAVEHIST=100000

# export EXTERNAL_DRIVE=/run/media/brad/63c96aca-03db-4d1e-9baa-3f950b3d8897/

export DEVSETUP=/opt/chef/cookbooks/development-setup
export PATH=$DEVSETUP/files/bin:$PATH
export PATH=~/.local/bin:$PATH # for tmuxp, etc from pip

export WORK_ZSHRC=~/Projects/sandbox/zshrc
export TMPDIR=/tmp

# TODO: refactor to a list file or symlinks (persistance) w/ function to modify
export ACTIVE_PROJECTS="~/Projects/vmass ~/Projects/_1_builds/vmass-integration-test"
export ARCHIVE=~/Documents/txt/archive

#no longer required
#export docker_job_image='vmass7.1'
