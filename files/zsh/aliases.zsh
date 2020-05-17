# [edit]
alias my-vimf='vim $(fzf)'
alias my-vim-exe='vim $FN && chmod +x $FN'
alias my-vim-var='cd ~/Documents/txt/var; vimf; cd -'
alias my-open-modified='vim $(git status | grep modified | cut -f2 | cut -d' ' -f4)'
alias my-tmp='vim ~/tmp/$(date "+%F-%T")'
alias my-vim-clipboard='vim ~/Documents/txt/var/clipboard'
alias my-vim-one-on-one='vim ~/Documents/txt/var/one-on-one'
alias my-vim-status='vim ~/Documents/txt/var/status'
alias my-vim-known-hosts='vim ~/.ssh/known_hosts'
# alias my-vim-zsh-noscm='vim ~/.noscm.zsh' # replaced with ~/.env.<company-name>
alias my-zsh-sources='vim $DEVSETUP/files/zsh/sources.zsh'
alias my-zsh-controls='vim $DEVSETUP/files/zsh/functions.zsh'
alias my-zsh-aliases='vim $DEVSETUP/files/zsh/aliases.zsh'
alias my-zsh-functions='vim $DEVSETUP/files/zsh/functions.zsh'

# [packages/installation]
alias my-download-remi='echo wget https://rpms.remirepo.net/enterprise/remi-release-7.rpm'
alias my-download-wifi-driver='git clone https://github.com/tomaspinho/rtl8821ce'
alias my-install-homebrew='/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
alias my-install-rvm='\curl -sSL https://get.rvm.io | bash -s stable --ruby'

# [find/list/git]
alias my-ls-merges-last-10='git log --oneline | grep Merge | head -n10'
alias my-ls-changed-files='git diff --name-only HEAD HEAD~1'
alias my-find-largest='find . -type f | xargs du -sh  | sort -rn | head -n25'
alias my-find-list-files='find . -maxdepth 1 -type f'
alias my-find-swap-files='find ~/Documents/txt -iname ".*.swp"'
alias my-find-swap-files_remove='rm $(find-swap_files|xargs)'

# [run]
alias my-run-apacheds='/opt/ApacheDirectoryStudio/ApacheDirectoryStudio'
alias my-run-chef="bash --login -c 'rvm use 2.4.0; chef-solo -c $DEVSETUP/solo.rb'"

# [ssh]
alias my-ssh-fast='ssh brad@$FASTBUILDER'
alias my-ssh-build='ssh brad@$BUILD'
alias my-ssh-gitlab-web='ssh brad@gitlab.valcom.com'
alias my-ssh-gitlab-local='ssh -p 2222 root@localhost'

# [system]
alias my-mem="cat /proc/meminfo | grep Total"
alias my-cpu="cat /proc/cpuinfo"
alias my-graphics="lspci -v|grep -i graphics"
alias my-network="lspci -v|grep -i net"

# [shell]
alias my-mount-iso='mount -t iso9660 -o loop /home/brad/DVD.iso /mnt/iso/'
alias my-group-list='getent group wheel'
alias my-printenv='printenv' # print environment variables # or, env?
alias my-clear-screen='printf "\033c"' # found on stack overflow
# Ctrl-S: freeze terminal output, Ctrl-Q: continue terminal output.
alias my-rvm-load='source /home/brad/.rvm/scripts/rvm; rvm use 2.4.3'
alias my-today='date +%Y%m%d'

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

# [locations]
alias my-cd-downloads='cd ~/Downloads'
alias my-cd-devsetup='cd $DEVSETUP'
alias my-cd-projects='cd ~/Projects'
alias my-cd-vmass='cd ~/Projects/vmass'
alias my-open-examples='open -a Finder ~/Examples || nautilus --browser ~/Examples'
alias my-open-tmp='open -a Finder /tmp || nautilus --browser /tmp'
alias my-open-dot='open -a Finder . || nautilus --browser .'

# [http]
alias my-http-get-with-status='curl -Li localhost:5000 2> /dev/null | grep -i HTTP'
alias my-ip='ifconfig|grep -i -m1 "inet addr" | cut -d' ' -f12 | cut -d: -f2'
alias my-open-80='iptables -I INPUT 5 -i eth0 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT'

# [git]
alias my-git-ch='git cherry-pick'
alias my-git-cc='git cherry-pick --continue'
alias my-git-ca='git commit --amend'
alias my-git-recent-files='git diff --name-only HEAD~10..HEAD'
alias my-git-time-back='git log --grep Merge | grep Date -B5 | head -n200 | tail -n4'
#
# [virtualbox]
# VBoxManage startvm vagrant --type headless
# alias my-vbox-screenshot='echo VBoxManage controlvm name screenshotpng screenshot.jpg'

# [vagrant]
# do better than this
# alias my-vg-ssh-dev='vagrant ssh development'

# [docker]
# noise
# alias my-docker-build='sudo docker build . | tee /tmp/docker-build-out'
# alias my-docker-run-bash='cat /tmp/docker-build-out | tail -n1 | awk "{print $3}" > /tmp/last-container && sudo docker run -it "$(cat /tmp/last-container)" /bin/bash'

# [git]
#alias asdfasdf='emacs $(git show --name-only --format=  bd61ad98)' # open all files from a commit
# WIP
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
# TODO
# idea from a legit comment:
#   [alias]
#  hist = log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --decorate --date=short
#  quick-push = "!f() { git add . && git commit -m \"$1\" && git push; }; f"
#  grep-log = log -E -i --grep
#  grep-hist = log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --decorate --date=short -E -i --grep

# This bugs out when using Ctrl-z
#alias my-readme='cd ~/Documents/txt; vim raw/$(date +%Y%m%d); cd -'

# [works-in-progress]
# replaced by txt/var

# [stale]
# keep for reference
# alias my-selinux-permissive='setenforce 0'
# alias my-grep-extended='grep -Eo [0-9]+'
# alias my-l='ls -lh'
# alias my-c="cut -d' ' -f"
# alias my-ls-ps='ps | grep -Ev "grep|ps|zsh"'
# command > >(tee -a stdout.log) 2> >(tee -a stderr.log >&2)
#alias my-save='command > >(tee -a stdout.log) 2> >(tee -a stderr.log >&2)'
#alias my-zsh-plugin-zsh-autosuggestions='source ~/.oh-my-zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh'
# alias my-project-clean='git checkout .; git clean -fd; make clean'
# alias my-git-deepclean='git clean -fdx'
# alias my-git-importfrombranch='git checkout release -- path/to/file'
# alias my-git-update='git checkout master && git pull'
# alias my-osx-ram='sysctl -a | grep hw.memsize'
#alias my-vbox-screenshot-to-text='VBoxManage controlvm vmass screenshotpng screenshot.png && convert -colorspace gray -fill white -resize 600% -sharpen 0x2 screenshot.png screenshot.jpg && tesseract screenshot.jpg ocr && cat ocr.txt'
