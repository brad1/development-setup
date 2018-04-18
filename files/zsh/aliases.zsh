
# command > >(tee -a stdout.log) 2> >(tee -a stderr.log >&2)

# printenv

# git rebase master --preserve-merges
# git rebase -i HEAD~4 #for squashing
#git log --oneline --decorate \
#--graph --all
#git log --grep 'keyword'
#git log -S code_snippet # find commits that adds or removes the string
#git log --oneline -- Gemfile # only look at gemfile
#git blame file # shows file, with last commit hash for each line
#git commit --ammend --no-edit # roll a staged file into the previous commir

alias rvm_load='source /home/brad/.rvm/scripts/rvm; rvm use 2.4.3'

alias aliases='cat /opt/chef/cookbooks/development-setup/files/zsh/aliases.zsh; cat ~/Projects/sandbox/zshrc'

alias http_get_with_status='curl -Li localhost:5000 2> /dev/null | grep -i HTTP'

alias examples='open -a Finder ~/Examples'

alias install_homebrew='/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
alias install_rvm='\curl -sSL https://get.rvm.io | bash -s stable --ruby'

alias c="cut -d' ' -f"

alias cd_devsetup='cd /opt/chef/cookbooks/development-setup'
alias cd_ib='cd ~/Projects/image_builder'
alias cd_projects='cd ~/Projects'
alias cd_vmass='cd ~/Projects/vmass'

alias cp_iso='cp $(find . -name VE\*iso) /media/sf_Desktop'

alias ip='ifconfig|grep -i -m1 "inet addr" | cut -d' ' -f12 | cut -d: -f2'

alias l='ls -lh'

alias open_80='iptables -I INPUT 5 -i eth0 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT'

alias project_clean='git checkout .; git clean -f; make clean'

# This bugs out when using Ctrl-z
#alias readme='cd ~/Documents/vim; vim raw/$(date +%Y%m%d); cd -'

alias selinux_permissive='setenforce 0'

alias vagrant_deathstar='vagrant halt && vagrant destroy --force'

alias vbox_screenshot='echo VBoxManage controlvm name screenshotpng screenshot.jpg'
alias vbox_dev='VBoxManage startvm Centos6-2'

alias vbox_target_vecap='VBoxManage startvm Centos6-target-vecap'
alias vbox_target_6021='VBoxManage startvm target-VE6021'
alias vbox_target_6025='VBoxManage startvm Centos6-target'
alias vbox_target_tps='VBoxManage startvm Centos6-target-tps'
alias vbox_target_ccserver='VBoxManage startvm target-CCServer'

alias vbox_vmass_view_screenshot="scp $(type ssh_build | cut -d' ' -f7):~/screenshot.png . && open -a Finder ./screenshot.png"
alias vbox_vmass_gen_screenshot="VBoxManage controlvm vmass screenshotpng screenshot.png && sudo mv screenshot.png /home/brad && sudo chown brad /home/brad/screenshot.png"

alias bash_cheatsheet='cat /opt/chef/cookbooks/development-setup/files/bash/cheatsheet'

alias vmass_clone='git clone git@gitlab.valcom.com:servers/vmass.git'

alias zsh_aliases='vim /opt/chef/cookbooks/development-setup/files/zsh/aliases.zsh'
alias zsh_aliases_work='vim ~/Projects/sandbox/zshrc'
alias zsh_functions='vim /opt/chef/cookbooks/development-setup/files/zsh/functions.zsh'
