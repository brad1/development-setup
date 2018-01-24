# git rebase master --preserve-merges
# git rebase -i HEAD~4 #for squashing

alias examples='open -a Finder ~/Examples'

alias install_homebrew='/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
alias install_rvm='\curl -sSL https://get.rvm.io | bash -s stable --ruby'

alias cd_devsetup='cd /opt/chef/cookbooks/development-setup'
alias cd_ib='cd ~/Projects/image_builder'
alias cd_projects='cd ~/Projects'
alias cd_vmass='cd ~/Projects/vmass'

alias cp_iso='cp $(find . -name VE\*iso) /media/sf_Desktop'

alias l='ls -lh'

alias readme='vim ~/readme'

alias vbox_basebox='VBoxManage startvm Centos6.9-basebox'
alias vbox_dev='VBoxManage startvm Centos6-2'
alias vbox_target_vecap='VBoxManage startvm Centos6-target-vecap'
alias vbox_target_vip='VBoxManage startvm Centos6-target'
alias vbox_target_tps='VBoxManage startvm Centos6-target-tps'

alias vim_cheatsheet='cat /opt/chef/cookbooks/development-setup/files/vim/cheatsheet'

alias vmass_clone='git clone git@gitlab.valcom.com:servers/vmass.git'


alias zsh_aliases='vim /opt/chef/cookbooks/development-setup/files/zsh/aliases.zsh'
