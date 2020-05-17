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
alias clear-screen='printf "\033c"' # found on stack overflow


# [commonly used]

# [vim]
alias vimf='vim $(fzf)'
alias vim-exe='vim $FN && chmod +x $FN'
alias vim-var='cd ~/Documents/txt/var; vimf; cd -'
alias open-modified='vim $(git status | grep modified | cut -f2 | cut -d' ' -f4)'

# [packages/installation]
alias download-remi='echo wget https://rpms.remirepo.net/enterprise/remi-release-7.rpm'
alias download-wifi-driver='git clone https://github.com/tomaspinho/rtl8821ce'

# [find/list/git]
alias ls-merges-last-10='git log --oneline | grep Merge | head -n10'
alias ls-changed-files='git diff --name-only HEAD HEAD~1'
alias find-largest='find . -type f | xargs du -sh  | sort -rn | head -n25'

# [run]
alias run-apacheds='/opt/ApacheDirectoryStudio/ApacheDirectoryStudio'


# [ssh]
alias ssh-fast='ssh brad@$FASTBUILDER'
alias ssh-build='ssh brad@$BUILD'
alias ssh-gitlab-web='ssh brad@gitlab.valcom.com'
alias ssh-gitlab-local='ssh -p 2222 root@localhost'

# [system]
alias osx_ram='sysctl -a | grep hw.memsize'
alias mem="cat /proc/meminfo | grep Total"
alias cpu="cat /proc/cpuinfo"
alias graphics="lspci -v|grep -i graphics"

alias sys-proc='ps aux | grep'

TEXT='~/Documents/txt'

# [works-in-progress]
alias ls-active="ls $TEXT/2_focus"
alias ls-standby="ls $TEXT/4_idle"
alias cd-txt="cd $TEXT;clear;ls"
alias wip-reading-list='vim ~/Documents/txt/topics/valcom/wip/topics/tasks/buffers/reading-list'
alias wip-build-system='vim ~/Documents/txt/topics/valcom/wip/topics/build'
alias wip-healthcheck='vim ~/Documents/txt/topics/valcom/wip/topics/healthcheck'
alias wip-bugs='vim ~/Documents/txt/topics/valcom/topics/tasks/buffers/bugs'
alias wip-one-on-one='vim ~/Documents/txt/topics/valcom/wip/topics/one-on-one'

# alias wip-vecap-upgrade='vim ~/Documents/txt/topics/valcom/wip/vecap-upgrade'

# [cheatsheets]
alias ch-gitlab='vim $DEVSETUP/files/cheatsheets/gitlab.txt'
alias ch-docker='vim $DEVSETUP/files/cheatsheets/docker.txt'
alias ch-python='vim $DEVSETUP/files/cheatsheets/python.txt'
alias ch-awk='vim $DEVSETUP/files/cheatsheets/awk.txt'
alias ch-syslog='vim $DEVSETUP/files/cheatsheets/syslog.txt'
alias ch-terminal='vim $DEVSETUP/files/cheatsheets/terminal.txt'
alias ch-sysadmin='vim $DEVSETUP/files/cheatsheets/sysadmin.txt'
alias ch-systemd='vim $DEVSETUP/files/cheatsheets/systemd.txt'
alias ch-ruby='vim $DEVSETUP/files/cheatsheets/ruby.txt'
alias ch-bundler='vim $DEVSETUP/files/cheatsheets/bundler.txt'
alias ch-virtualbox='vim $DEVSETUP/files/cheatsheets/virtualbox.txt'
alias ch-postgres='vim $DEVSETUP/files/cheatsheets/postgres'
alias ch-vim='vim $DEVSETUP/files/cheatsheets/vim'
alias ch-qwerty='cat $DEVSETUP/files/cheatsheets/qwerty'
alias ch-zsh='vim $DEVSETUP/files/zsh/cheatsheet'
alias ch-bash='vim $DEVSETUP/files/bash/cheatsheet'
alias ch-unix='vim $DEVSETUP/files/cheatsheets/bash_commands'
alias ch-rhel='vim $DEVSETUP/files/cheatsheets/linux'
alias ch-rpm='vim $DEVSETUP/files/cheatsheets/linux-rpm'
alias ch-network='vim $DEVSETUP/files/cheatsheets/network'
alias ch-tmux='vim $DEVSETUP/files/tmux/cheatsheet'
alias ch-ranger='echo S open shell in directory, c-h to show hidden files '
alias ch-sed='vi $DEVSETUP/files/cheatsheets/sed'
alias ch-php='vi $DEVSETUP/files/cheatsheets/php'
alias ch-sql='vi $DEVSETUP/files/cheatsheets/sql'
alias ch-git='vi $DEVSETUP/files/cheatsheets/git'
alias ch-markdown='vi $DEVSETUP/files/cheatsheets/markdown'
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
alias zsh-plugin-zsh-autosuggestions='source ~/.oh-my-zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh'

# [cp]
alias cp_iso='cp $(find . -name VE\*iso) /media/sf_Desktop'

# [find]
alias find-list_files='find . -maxdepth 1 -type f'
alias find-swap_files='find ~/Documents/txt -iname ".*.swp"'
alias find-swap_files_remove='rm $(find-swap_files|xargs)'

# [vim]
alias vim-quick='vim ~/Documents/txt/quick.txt'
alias vim-clipboard='vim ~/Documents/txt/var/clipboard'
alias vim-journal='vim ~/Documents/txt/var/journal'
alias vim-one-on-one='vim ~/Documents/txt/var/one-on-one'
alias vim-status='vim ~/Documents/txt/var/status'
alias vim-document-me='vim ~/Documents/txt/var/document-me'
alias vim-improvements='vim ~/Documents/txt/var/improvements'
alias vim-problems='vim ~/Documents/txt/topics/tasks/buffers/volatile/problems'
alias vim-quick='vim ~/Documents/txt/topics/tasks/buffers/volatile/quick'
alias vim-reading-list='vim ~/Documents/txt/topics/tasks/buffers/volatile/reading-list'
alias vim-remember='vim ~/Documents/txt/topics/tasks/buffers/volatile/remember'
alias vim-scriptify='vim ~/Documents/txt/topics/tasks/buffers/volatile/scriptify'

alias vim-zshrc='vim ~/.zshrc'
alias vim-zsh-noscm='vim ~/.noscm.zsh'
alias vim-zsh-sources='vim $DEVSETUP/files/zsh/sources.zsh'
alias vim-zsh-controls='vim $DEVSETUP/files/zsh/functions.zsh'
alias vim-zsh-aliases='vim $DEVSETUP/files/zsh/aliases.zsh'
alias vim-zsh-aliases_work='vim ~/Projects/sandbox/zshrc'
alias vim-zsh-functions='vim $DEVSETUP/files/zsh/functions.zsh'

alias vim-known_hosts='vim ~/.ssh/known_hosts'

alias zsh-noscm='vim ~/.noscm.zsh'
alias zsh-sources='vim $DEVSETUP/files/zsh/sources.zsh'
alias zsh-controls='vim $DEVSETUP/files/zsh/functions.zsh'
alias zsh-aliases='vim $DEVSETUP/files/zsh/aliases.zsh'
alias zsh-aliases_work='vim ~/Projects/sandbox/zshrc'
alias zsh-functions='vim $DEVSETUP/files/zsh/functions.zsh'


# [locations]
alias cd-vim='cd ~/Documents/txt/links'
alias cd-downloads='cd ~/Downloads'
alias cd-devsetup='cd $DEVSETUP'
alias cd-ib='cd ~/Projects/image_builder'
alias cd-projects='cd ~/Projects'
alias cd-vmass='cd ~/Projects/vmass'
alias open-examples='open -a Finder ~/Examples || nautilus --browser ~/Examples'
alias open-tmp='open -a Finder /tmp || nautilus --browser /tmp'
alias open-dot='open -a Finder . || nautilus --browser .'
# alias cd-prototypes='~/Documents/txt/scratch/prototypes'
alias cd-journal='cd-txt && cd journal && ./today.sh && cd $(today)' # hack


# [vim]

# This bugs out when using Ctrl-z
#alias readme='cd ~/Documents/txt; vim raw/$(date +%Y%m%d); cd -'
alias today='date +%Y%m%d'


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


# [vagrant]
alias vg-ssh-dev='vagrant ssh development'
alias vg-up-dev='vagrant up development'
alias vg-suspend-dev='vagrant suspend development'
alias vg-halt-dev='vagrant halt development'
alias vg-resume-dev='vagrant resume development'
alias vg-ssh-rel='vagrant ssh release'
alias vg-up-rel='vagrant up release'
alias vg-suspend-rel='vagrant suspend release'
alias vg-halt-rel='vagrant halt release'
alias vg-resume-rel='vagrant resume release'
alias vg-box-upgrade='vagrant box remove vmass; vagrant up development'

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
alias git-ch='git cherry-pick'
alias git-cc='git cherry-pick --continue'
alias git-ca='git commit --amend'
alias git-recent-files='git diff --name-only HEAD~10..HEAD'
alias git-time_back='git log --grep Merge | grep Date -B5 | head -n200 | tail -n4'
alias git-importfrombranch='git checkout release -- path/to/file'
alias git-deepclean='git clean -fdx'
alias git-update='git checkout master && git pull'

# [docker]
alias docker-build='sudo docker build . | tee /tmp/docker-build-out'
alias docker-run-bash='cat /tmp/docker-build-out | tail -n1 | awk "{print $3}" > /tmp/last-container && sudo docker run -it "$(cat /tmp/last-container)" /bin/bash'


#alias git-clean='echo WIP: git clean -xdf --exclude=".vagrant*" --exclude="node_modules"'
#alias git-clean='git clean -xf --exclude=".vagrant"'
#alias git-clean='git clean -xdn --exclude=".vagrant*" --exclude="node_modules"'
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

alias git-project-clean='git checkout .; git clean -fd'
# alias project-clean='git checkout .; git clean -fd; make clean'


# [shell]
alias ls-ps='ps | grep -Ev "grep|ps|zsh"'
alias tmp='vim ~/tmp/$(date "+%F-%T")'
alias c="cut -d' ' -f"
alias l='ls -lh'
alias selinux-permissive='setenforce 0'
alias mount-iso='mount -t iso9660 -o loop /home/brad/DVD.iso /mnt/iso/'
alias group-list='getent group wheel'
alias grep-extended='grep -Eo [0-9]+'
# printenv # print environment variables
# env
#
# command > >(tee -a stdout.log) 2> >(tee -a stderr.log >&2)
#alias save='command > >(tee -a stdout.log) 2> >(tee -a stderr.log >&2)'

# [other]
alias run_chef="bash --login -c 'rvm use 2.4.0; chef-solo -c $DEVSETUP/solo.rb'"
