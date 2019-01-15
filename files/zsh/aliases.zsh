# [new]
alias new_grep='ag -o "[0-9]+"' # fast
alias fzf_search='fzf' # fast fuzzy file search

# [system]
alias osx_ram='sysctl -a | grep hw.memsize'
alias mem="cat /proc/meminfo | grep Total"
alias cpu="cat /proc/cpuinfo"
alias graphics="lspci -v|grep -i graphics"

alias sys-proc='ps aux | grep'


# [works-in-progress]
alias wip-password='vim ~/Documents/vim/topics/valcom/wip/password'
alias wip-readme='vim ~/Documents/vim/topics/valcom/wip/readme'
alias wip-meeting='vim ~/Documents/vim/topics/valcom/wip/meeting'
alias wip-build='vim ~/Documents/vim/topics/valcom/wip/build'
alias wip-capybara='vim ~/Documents/vim/topics/valcom/wip/capybara'
alias wip-perfect-world='vim ~/Documents/vim/topics/valcom/wip/perfect-world'
alias wip-healthcheck='vim ~/Documents/vim/topics/valcom/wip/vmass-healthcheck'
alias wip-important='vim ~/Documents/vim/topics/valcom/wip/important'
alias wip-problems='vim ~/Documents/vim/topics/valcom/wip/problems'
alias wip-unknowns='vim ~/Documents/vim/topics/valcom/wip/vmass-unknowns'
alias wip-expected-packages='vim ~/Documents/vim/topics/valcom/wip/expected-packages'
alias wip-ha-manual='vim ~/Documents/vim/topics/valcom/wip/ha-manual'
alias wip-gitlab-manual='vim ~/Documents/vim/topics/valcom/wip/gitlab-manual'
alias wip-bugs='vim ~/Documents/vim/topics/valcom/wip/bugs'
alias wip-one-on-one='vim ~/Documents/vim/topics/valcom/wip/one-on-one'
alias wip-vagrant='vim ~/Documents/vim/topics/valcom/wip/vagrant'
alias wip-legacy-tests='vim ~/Documents/vim/topics/valcom/wip/legacy-tests'
alias wip-ha-test='vim ~/Documents/vim/topics/valcom/wip/ha-tests'

# alias wip-vecap-upgrade='vim ~/Documents/vim/topics/valcom/wip/vecap-upgrade'

# [cheatsheets]
alias ch-ruby='vim /opt/chef/cookbooks/development-setup/files/cheatsheets/ruby.txt'
alias ch-virtualbox='vim /opt/chef/cookbooks/development-setup/files/cheatsheets/virtualbox.txt'
alias ch-postgres='vim /opt/chef/cookbooks/development-setup/files/cheatsheets/postgres'
alias ch-vim='vim /opt/chef/cookbooks/development-setup/files/cheatsheets/vim'
alias ch-qwerty='vim /opt/chef/cookbooks/development-setup/files/cheatsheets/qwerty'
alias ch-zsh='vim /opt/chef/cookbooks/development-setup/files/zsh/cheatsheet'
alias ch-bash='vim /opt/chef/cookbooks/development-setup/files/bash/cheatsheet'
alias ch-unix='vim /opt/chef/cookbooks/development-setup/files/cheatsheets/bash_commands'
alias ch-rhel='vim /opt/chef/cookbooks/development-setup/files/cheatsheets/linux'
alias ch-network='vim /opt/chef/cookbooks/development-setup/files/cheatsheets/network'
alias ch-tmux='vim /opt/chef/cookbooks/development-setup/files/tmux/cheatsheet'
alias ch-ranger='echo S open shell in directory, c-h to show hidden files '
alias ch-sed='vi /opt/chef/cookbooks/development-setup/files/cheatsheets/sed'
alias ch-php='vi /opt/chef/cookbooks/development-setup/files/cheatsheets/php'
alias ch-sql='vi /opt/chef/cookbooks/development-setup/files/cheatsheets/sql'
alias ch-git='vi /opt/chef/cookbooks/development-setup/files/cheatsheets/git'
#select * from information where label like 'ldap%';
#update information set value = 7 where label = 'loglevel';
# SELECT MAX(id) FROM information; # in postgres, should supposedly be in sync with:
# SELECT nextval('information_id_seq');
# SELECT setval('the_primary_key_sequence', (SELECT MAX(the_primary_key) FROM the_table)+1);
# That will set the sequence to the next available value that's higher than any existing primary key in the sequence.
alias ch-markdown='vi /opt/chef/cookbooks/development-setup/files/cheatsheets/markdown'
# rpm -ql postgresql95-9.5.10-1PGDG.rhel7.x86_64 | grep bin
# rsyslogd -N1 -f /etc/rsyslog.conf # valdaite rsyslog conf

# [cp]
alias cp_iso='cp $(find . -name VE\*iso) /media/sf_Desktop'

# [find]
alias list_files='find . -maxdepth 1 -type f'
alias swap_files='find ~/Documents/vim -iname ".*.swp"'
alias swap_files_remove='rm $(swap_files|xargs)'

# [vim]
alias vim-bootstrap='vim ~/Documents/vim/bootstrap.txt'
alias vim-reading-list='vim ~/Documents/vim/reading-list.txt'
alias vim-clipboard='vim ~/Documents/vim/clipboard.txt'
alias vim-timesheet='vim ~/Documents/vim/topics/planning/timesheet.log'
alias vim-zshrc='vim ~/.zshrc'
alias vim-atoms='vim ~/Documents/vim/topics/planning/atoms'
alias vim-zsh-noscm='vim ~/.noscm.zsh'
alias vim-zsh-sources='vim /opt/chef/cookbooks/development-setup/files/zsh/sources.zsh'
alias vim-zsh-controls='vim /opt/chef/cookbooks/development-setup/files/zsh/functions.zsh'
#alias vim-oneonone='vim ~/Documents/vim/oneonone'
#alias vim-presentation='vim ~/Documents/vim/topics/valcom/vagrant-presentation'
#alias vim_timesheet_status='vim ~/Documents/vim/topics/planning/timesheet/status-update'

#alias vim_known_hosts='vim ~/.ssh/known_hosts'

# [locations]
alias cd_vim='cd ~/Documents/vim/links'
alias cd_downloads='cd ~/Downloads'
alias cd_devsetup='cd /opt/chef/cookbooks/development-setup'
alias cd_ib='cd ~/Projects/image_builder'
alias cd_projects='cd ~/Projects'
alias cd_prototypes='~/Documents/vim/scratch/prototypes'
alias cd_vmass='cd ~/Projects/vmass'
alias examples='open -a Finder ~/Examples'


# [vim]

alias aliases='cat /opt/chef/cookbooks/development-setup/files/zsh/aliases.zsh; cat ~/Projects/sandbox/zshrc'
# This bugs out when using Ctrl-z
#alias readme='cd ~/Documents/vim; vim raw/$(date +%Y%m%d); cd -'
alias zsh_aliases='vim /opt/chef/cookbooks/development-setup/files/zsh/aliases.zsh'
alias zsh_aliases_work='vim ~/Projects/sandbox/zshrc'
alias zsh_functions='vim /opt/chef/cookbooks/development-setup/files/zsh/functions.zsh'


# [virtualbox]
# VBoxManage startvm vagrant --type headless
alias vbox_screenshot='echo VBoxManage controlvm name screenshotpng screenshot.jpg'
alias vbox_dev='VBoxManage startvm Centos6-2'
alias vbox_target_vecap='VBoxManage startvm Centos6-target-vecap'
alias vbox_target_6021='VBoxManage startvm target-VE6021'
alias vbox_target_6025='VBoxManage startvm Centos6-target'
alias vbox_target_tps='VBoxManage startvm Centos6-target-tps'
alias vbox_target_ccserver='VBoxManage startvm target-CCServer'
alias vbox_vmass_view_screenshot="scp $(type ssh_build | cut -d' ' -f7):~/screenshot.png ~/.state/vmass_vagrant.png && open -a Finder ~/.state/vmass_vagrant.png"
alias vbox_vmass_gen_screenshot="VBoxManage controlvm vmass screenshotpng screenshot.png && sudo mv screenshot.png /home/brad && sudo chown brad /home/brad/screenshot.png"
alias vbox_screenshot_to_text='VBoxManage controlvm vmass screenshotpng screenshot.png && convert -colorspace gray -fill white -resize 600% -sharpen 0x2 screenshot.png screenshot.jpg && tesseract screenshot.jpg ocr && cat ocr.txt'

alias vagrant_box_download='vagrant box remove vmass; vagrant up'

# [ruby]
alias rvm_load='source /home/brad/.rvm/scripts/rvm; rvm use 2.4.3'
alias install_rvm='\curl -sSL https://get.rvm.io | bash -s stable --ruby'


# [http]
alias http_get_with_status='curl -Li localhost:5000 2> /dev/null | grep -i HTTP'
alias ip='ifconfig|grep -i -m1 "inet addr" | cut -d' ' -f12 | cut -d: -f2'
alias open_80='iptables -I INPUT 5 -i eth0 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT'


# [install]
alias install_homebrew='/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'

# [git]
alias git_time_back='git log --grep Merge | grep Date -B5 | head -n200 | tail -n4'
alias git_clean='echo WIP: git clean -xdf --exclude=".vagrant*" --exclude="node_modules"'
#alias git_clean='git clean -xf --exclude=".vagrant"'
#alias git_clean='git clean -xdn --exclude=".vagrant*" --exclude="node_modules"'
alias git_importfrombranch='git checkout release -- path/to/file'
alias git_realclean='git clean -fdx'
#
#   git rebase master --preserve-merges
#   git rebase -i HEAD~4 #for squashing
#
#   git log --oneline --decorate --graph --all
#   git log --grep 'keyword'
#   git log -S code_snippet # find commits that adds or removes the string
#   git log --oneline -- Gemfile # only look at gemfile
#
#   git blame file # shows file, with last commit hash for each line
#   git commit --ammend --no-edit # roll a staged file into the previous commit
#
#   # checkout last version of a file before it was deleted.
#   git checkout $(git rev-list -n 1 HEAD -- "$file")~1 -- "$file"
#
#   # what files changed in my branch?
#   git diff --name-only SHA1 SHA2
#

alias project_clean='git checkout .; git clean -f; make clean'


# [shell]
alias tmp='vim ~/tmp/$(date "+%F-%T")'
alias c="cut -d' ' -f"
alias l='ls -lh'
alias selinux_permissive='setenforce 0'
alias mount_iso='mount -t iso9660 -o loop /home/brad/DVD.iso /mnt/iso/'
alias group_list='getent group wheel'
alias grep_extended='grep -Eo [0-9]+'
# printenv # print environment variables
# env
#
# command > >(tee -a stdout.log) 2> >(tee -a stderr.log >&2)
#alias save='command > >(tee -a stdout.log) 2> >(tee -a stderr.log >&2)'

# [other]
alias run_chef="bash --login -c 'rvm use 2.4.0; chef-solo -c /opt/chef/cookbooks/development-setup/solo.rb'"
