# TODO
# idea from a legit comment:
#   [alias]
#  hist = log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --decorate --date=short
#  quick-push = "!f() { git add . && git commit -m \"$1\" && git push; }; f"
#  grep-log = log -E -i --grep
#  grep-hist = log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --decorate --date=short -E -i --grep

# [new]
# Ctrl-S: freeze terminal output, Ctrl-Q: continue terminal output.
#alias asdfasdf='emacs $(git show --name-only --format=  bd61ad98)' # open all files from a commit
alias my-clear-screen='printf "\033c"' # found on stack overflow


# [commonly used]

# [vim]
alias my-vimf='vim $(fzf)'
alias my-vim-exe='vim $FN && chmod +x $FN'
alias my-vim-var='cd ~/Documents/txt/var; vimf; cd -'
alias my-open-modified='vim $(git status | grep modified | cut -f2 | cut -d' ' -f4)'

# [packages/installation]
alias my-download-remi='echo wget https://rpms.remirepo.net/enterprise/remi-release-7.rpm'
alias my-download-wifi-driver='git clone https://github.com/tomaspinho/rtl8821ce'

# [find/list/git]
alias my-ls-merges-last-10='git log --oneline | grep Merge | head -n10'
alias my-ls-changed-files='git diff --name-only HEAD HEAD~1'
alias my-find-largest='find . -type f | xargs du -sh  | sort -rn | head -n25'

# [run]
alias my-run-apacheds='/opt/ApacheDirectoryStudio/ApacheDirectoryStudio'


# [ssh]
alias my-ssh-fast='ssh brad@$FASTBUILDER'
alias my-ssh-build='ssh brad@$BUILD'
alias my-ssh-gitlab-web='ssh brad@gitlab.valcom.com'
alias my-ssh-gitlab-local='ssh -p 2222 root@localhost'

# [system]
alias my-osx_ram='sysctl -a | grep hw.memsize'
alias my-mem="cat /proc/meminfo | grep Total"
alias my-cpu="cat /proc/cpuinfo"
alias my-graphics="lspci -v|grep -i graphics"

alias my-sys-proc='ps aux | grep'

TEXT='~/Documents/txt'

# [works-in-progress]
alias my-ls-active="ls $TEXT/2_focus"
alias my-ls-standby="ls $TEXT/4_idle"
alias my-cd-txt="cd $TEXT;clear;ls"
alias my-wip-reading-list='vim ~/Documents/txt/topics/valcom/wip/topics/tasks/buffers/reading-list'
alias my-wip-build-system='vim ~/Documents/txt/topics/valcom/wip/topics/build'
alias my-wip-healthcheck='vim ~/Documents/txt/topics/valcom/wip/topics/healthcheck'
alias my-wip-bugs='vim ~/Documents/txt/topics/valcom/topics/tasks/buffers/bugs'
alias my-wip-one-on-one='vim ~/Documents/txt/topics/valcom/wip/topics/one-on-one'

# alias my-wip-vecap-upgrade='vim ~/Documents/txt/topics/valcom/wip/vecap-upgrade'

# [cheatsheets]
alias my-ch-gitlab='vim $DEVSETUP/files/cheatsheets/gitlab.txt'
alias my-ch-docker='vim $DEVSETUP/files/cheatsheets/docker.txt'
alias my-ch-python='vim $DEVSETUP/files/cheatsheets/python.txt'
alias my-ch-awk='vim $DEVSETUP/files/cheatsheets/awk.txt'
alias my-ch-syslog='vim $DEVSETUP/files/cheatsheets/syslog.txt'
alias my-ch-terminal='vim $DEVSETUP/files/cheatsheets/terminal.txt'
alias my-ch-sysadmin='vim $DEVSETUP/files/cheatsheets/sysadmin.txt'
alias my-ch-systemd='vim $DEVSETUP/files/cheatsheets/systemd.txt'
alias my-ch-ruby='vim $DEVSETUP/files/cheatsheets/ruby.txt'
alias my-ch-bundler='vim $DEVSETUP/files/cheatsheets/bundler.txt'
alias my-ch-virtualbox='vim $DEVSETUP/files/cheatsheets/virtualbox.txt'
alias my-ch-postgres='vim $DEVSETUP/files/cheatsheets/postgres'
alias my-ch-vim='vim $DEVSETUP/files/cheatsheets/vim'
alias my-ch-qwerty='cat $DEVSETUP/files/cheatsheets/qwerty'
alias my-ch-zsh='vim $DEVSETUP/files/zsh/cheatsheet'
alias my-ch-bash='vim $DEVSETUP/files/bash/cheatsheet'
alias my-ch-unix='vim $DEVSETUP/files/cheatsheets/bash_commands'
alias my-ch-rhel='vim $DEVSETUP/files/cheatsheets/linux'
alias my-ch-rpm='vim $DEVSETUP/files/cheatsheets/linux-rpm'
alias my-ch-network='vim $DEVSETUP/files/cheatsheets/network'
alias my-ch-tmux='vim $DEVSETUP/files/tmux/cheatsheet'
alias my-ch-ranger='echo S open shell in directory, c-h to show hidden files '
alias my-ch-sed='vi $DEVSETUP/files/cheatsheets/sed'
alias my-ch-php='vi $DEVSETUP/files/cheatsheets/php'
alias my-ch-sql='vi $DEVSETUP/files/cheatsheets/sql'
alias my-ch-git='vi $DEVSETUP/files/cheatsheets/git'
alias my-ch-markdown='vi $DEVSETUP/files/cheatsheets/markdown'
# rpm -ql postgresql95-9.5.10-1PGDG.rhel7.x86_64 | grep bin
# rsyslogd -N1 -f /etc/rsyslog.conf # valdaite rsyslog conf
#select * from information where label like 'ldap%';
#update information set value = 7 where label = 'loglevel';
# SELECT MAX(id) FROM information; # in postgres, should supposedly be in sync with:
# SELECT nextval('information_id_seq');
# SELECT setval('the_primary_key_sequence', (SELECT MAX(the_primary_key) FROM the_table)+1);
# That will set the sequence to the next available value that's higher than any existing primary key in the sequence.

# [plugin]
# Load plugins, some of these won't be compatible
alias my-zsh-plugin-zsh-autosuggestions='source ~/.oh-my-zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh'

# [cp]
alias my-cp_iso='cp $(find . -name VE\*iso) /media/sf_Desktop'

# [find]
alias my-find-list_files='find . -maxdepth 1 -type f'
alias my-find-swap_files='find ~/Documents/txt -iname ".*.swp"'
alias my-find-swap_files_remove='rm $(find-swap_files|xargs)'

# [vim]
alias my-vim-quick='vim ~/Documents/txt/quick.txt'
alias my-vim-clipboard='vim ~/Documents/txt/var/clipboard'
alias my-vim-journal='vim ~/Documents/txt/var/journal'
alias my-vim-one-on-one='vim ~/Documents/txt/var/one-on-one'
alias my-vim-status='vim ~/Documents/txt/var/status'
alias my-vim-document-me='vim ~/Documents/txt/var/document-me'
alias my-vim-improvements='vim ~/Documents/txt/var/improvements'
alias my-vim-problems='vim ~/Documents/txt/topics/tasks/buffers/volatile/problems'
alias my-vim-quick='vim ~/Documents/txt/topics/tasks/buffers/volatile/quick'
alias my-vim-reading-list='vim ~/Documents/txt/topics/tasks/buffers/volatile/reading-list'
alias my-vim-remember='vim ~/Documents/txt/topics/tasks/buffers/volatile/remember'
alias my-vim-scriptify='vim ~/Documents/txt/topics/tasks/buffers/volatile/scriptify'

alias my-vim-zshrc='vim ~/.zshrc'
alias my-vim-zsh-noscm='vim ~/.noscm.zsh'
alias my-vim-zsh-sources='vim $DEVSETUP/files/zsh/sources.zsh'
alias my-vim-zsh-controls='vim $DEVSETUP/files/zsh/functions.zsh'
alias my-vim-zsh-aliases='vim $DEVSETUP/files/zsh/aliases.zsh'
alias my-vim-zsh-aliases_work='vim ~/Projects/sandbox/zshrc'
alias my-vim-zsh-functions='vim $DEVSETUP/files/zsh/functions.zsh'

alias my-vim-known_hosts='vim ~/.ssh/known_hosts'

alias my-zsh-noscm='vim ~/.noscm.zsh'
alias my-zsh-sources='vim $DEVSETUP/files/zsh/sources.zsh'
alias my-zsh-controls='vim $DEVSETUP/files/zsh/functions.zsh'
alias my-zsh-aliases='vim $DEVSETUP/files/zsh/aliases.zsh'
alias my-zsh-aliases_work='vim ~/Projects/sandbox/zshrc'
alias my-zsh-functions='vim $DEVSETUP/files/zsh/functions.zsh'


# [locations]
alias my-cd-vim='cd ~/Documents/txt/links'
alias my-cd-downloads='cd ~/Downloads'
alias my-cd-devsetup='cd $DEVSETUP'
alias my-cd-ib='cd ~/Projects/image_builder'
alias my-cd-projects='cd ~/Projects'
alias my-cd-vmass='cd ~/Projects/vmass'
alias my-open-examples='open -a Finder ~/Examples || nautilus --browser ~/Examples'
alias my-open-tmp='open -a Finder /tmp || nautilus --browser /tmp'
alias my-open-dot='open -a Finder . || nautilus --browser .'
# alias my-cd-prototypes='~/Documents/txt/scratch/prototypes'
alias my-cd-journal='cd-txt && cd journal && ./today.sh && cd $(today)' # hack


# [vim]

# This bugs out when using Ctrl-z
#alias my-readme='cd ~/Documents/txt; vim raw/$(date +%Y%m%d); cd -'
alias my-today='date +%Y%m%d'


# [virtualbox]
# VBoxManage startvm vagrant --type headless
alias my-vbox_screenshot='echo VBoxManage controlvm name screenshotpng screenshot.jpg'
alias my-vbox_dev='VBoxManage startvm Centos6-2'
alias my-vbox_target_vecap='VBoxManage startvm Centos6-target-vecap'
alias my-vbox_target_6021='VBoxManage startvm target-VE6021'
alias my-vbox_target_6025='VBoxManage startvm Centos6-target'
alias my-vbox_target_tps='VBoxManage startvm Centos6-target-tps'
alias my-vbox_target_ccserver='VBoxManage startvm target-CCServer'
alias my-vbox_vmass_view_screenshot="scp $(type ssh_build | cut -d' ' -f7):~/screenshot.png ~/.state/vmass_vagrant.png && open -a Finder ~/.state/vmass_vagrant.png"
alias my-vbox_vmass_gen_screenshot="VBoxManage controlvm vmass screenshotpng screenshot.png && sudo mv screenshot.png /home/brad && sudo chown brad /home/brad/screenshot.png"
alias my-vbox_screenshot_to_text='VBoxManage controlvm vmass screenshotpng screenshot.png && convert -colorspace gray -fill white -resize 600% -sharpen 0x2 screenshot.png screenshot.jpg && tesseract screenshot.jpg ocr && cat ocr.txt'


# [vagrant]
alias my-vg-ssh-dev='vagrant ssh development'
alias my-vg-up-dev='vagrant up development'
alias my-vg-suspend-dev='vagrant suspend development'
alias my-vg-halt-dev='vagrant halt development'
alias my-vg-resume-dev='vagrant resume development'
alias my-vg-ssh-rel='vagrant ssh release'
alias my-vg-up-rel='vagrant up release'
alias my-vg-suspend-rel='vagrant suspend release'
alias my-vg-halt-rel='vagrant halt release'
alias my-vg-resume-rel='vagrant resume release'
alias my-vg-box-upgrade='vagrant box remove vmass; vagrant up development'

# [ruby]
alias my-rvm_load='source /home/brad/.rvm/scripts/rvm; rvm use 2.4.3'
alias my-install_rvm='\curl -sSL https://get.rvm.io | bash -s stable --ruby'


# [http]
alias my-http_get_with_status='curl -Li localhost:5000 2> /dev/null | grep -i HTTP'
alias my-ip='ifconfig|grep -i -m1 "inet addr" | cut -d' ' -f12 | cut -d: -f2'
alias my-open_80='iptables -I INPUT 5 -i eth0 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT'


# [install]
alias my-install_homebrew='/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'

# [git]
alias my-git-ch='git cherry-pick'
alias my-git-cc='git cherry-pick --continue'
alias my-git-ca='git commit --amend'
alias my-git-recent-files='git diff --name-only HEAD~10..HEAD'
alias my-git-time_back='git log --grep Merge | grep Date -B5 | head -n200 | tail -n4'
alias my-git-importfrombranch='git checkout release -- path/to/file'
alias my-git-deepclean='git clean -fdx'
alias my-git-update='git checkout master && git pull'

# [docker]
alias my-docker-build='sudo docker build . | tee /tmp/docker-build-out'
alias my-docker-run-bash='cat /tmp/docker-build-out | tail -n1 | awk "{print $3}" > /tmp/last-container && sudo docker run -it "$(cat /tmp/last-container)" /bin/bash'


#alias my-git-clean='echo WIP: git clean -xdf --exclude=".vagrant*" --exclude="node_modules"'
#alias my-git-clean='git clean -xf --exclude=".vagrant"'
#alias my-git-clean='git clean -xdn --exclude=".vagrant*" --exclude="node_modules"'
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

alias my-git-project-clean='git checkout .; git clean -fd'
# alias my-project-clean='git checkout .; git clean -fd; make clean'


# [shell]
alias my-ls-ps='ps | grep -Ev "grep|ps|zsh"'
alias my-tmp='vim ~/tmp/$(date "+%F-%T")'
alias my-c="cut -d' ' -f"
alias my-l='ls -lh'
alias my-selinux-permissive='setenforce 0'
alias my-mount-iso='mount -t iso9660 -o loop /home/brad/DVD.iso /mnt/iso/'
alias my-group-list='getent group wheel'
alias my-grep-extended='grep -Eo [0-9]+'
# printenv # print environment variables
# env
#
# command > >(tee -a stdout.log) 2> >(tee -a stderr.log >&2)
#alias my-save='command > >(tee -a stdout.log) 2> >(tee -a stderr.log >&2)'

# [other]
alias my-run_chef="bash --login -c 'rvm use 2.4.0; chef-solo -c $DEVSETUP/solo.rb'"
