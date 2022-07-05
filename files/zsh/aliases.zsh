# Bookmarks:
# frequentuse, updatedaily


alias b-journal='browse-journal'


alias awkf='awk -F ":"' # custom field separator
alias awkf='awk "{print}"' # basically cat
alias awkf='awk "{print $0}"' # same

alias print-date="date +'%m-%d-%Y'"
alias list-aliases="cat /opt/chef/cookbooks/development-setup/files/zsh/aliases.zsh | grep -o \"^alias [^\-]*-.*=\" | cut -d' ' -f2 | cut -d'-' -f1 | sort | uniq | xargs"
alias edit-zshrc='$EDITOR ~/.zshrc'
alias edit-pending='vim /var/brad/pending.list'
alias canidothis='file="$(fzf)"; echo $file'
alias linkf='file="$(fzf)"; echo $file; ln -sf "$file"'

# [using]
#alias vsbc='vagrant ssh bootstrap --no-tty --command "make rspec" '
alias vsbc='vagrant ssh bootstrap --no-tty --command "make -C vipsched/ruby rspec" '
#alias vip='vagrant ssh bootstrap --no-tty --command "ip a"'
alias vip='vagrant ssh ubuntu --no-tty --command "ip a"'
alias vscp='vagrant scp ubuntu:~/file .'

#  Instead of this, I keep a permanent log of every shell command I ever typed and have a handy alias to keep through it.
# It also keeps track of the directory a command was run from, so I can limit my search. That way if I ever want to get back into a project I was working on long ago, I can just grep for commands run from that directory.
# Not only that, but I can use it to cd to directories quickly. So if I was working under a huge p 10 level deep directory path, I have a alias that will match a string and cd into the last matching path in the permanent history file.
# Not only that, but I can also search and then choose and rerun a command in the history, and also edit before rerunning it.
# Just put:
# export PROMPT_COMMAND='if [ "$(id -u)" -ne 0 ]; then echo "$(date "+%Y-%m-%d.%H:%M:%S") $(pwd) $(history 1)" >> "${HOME}/bash_logs_$(hostname)/bash-history-$(date "+%Y-%m-%d").log"; fi'
# in your ~/.bash_profile. You also may need to `mkdir "${HOME}/bash_logs_$(hostname)"`
# I took this command from a Hacker News thread of the past. I don't have a link to it any more.

alias rd='rdesktop -u user ipaddress'
alias stack='pstree -s $$'

# ps aux | grep -E 'ping|ha' | grep -v grep | awk '{ print $1 " " $2 " " substr($0, index($0,$11)) }'

alias catf='cat $(fzf)'
alias queue='(cd ~/Documents/txt/queues && vimf)'
alias queues='queue'
alias q='queue'


# [subshells]
alias ss-q='(cd ~/Documents/txt/queues && zsh)'

# [edit]
alias -s {cs,ts,html,json,md}=$EDITOR
#alias vfzf='fzf > /tmp/.viminput'
alias getviminput='cat /tmp/.viminput'
alias vimf='vim $(fzf)'
alias vim-work-zshrc='vim ~/Projects/sandbox/zshrc'
alias vim-exe='vim $FN && chmod +x $FN'
alias vim-var='cd ~/Documents/txt/var; vimf; cd -'
alias vim-queue='cd ~/Documents/txt/var; vim queue; cd -'
alias vimrc="vim $DEVSETUP/files/vim/vimrc"
alias vim-open-modified='vim $(git status | grep modified | cut -f2 | cut -d" " -f4)'
alias vim-tmp='vim ~/tmp/$(date "+%F-%T")'
alias vim-clipboard='vim ~/Documents/txt/var/clipboard'
alias vim-clipboard-2='vim ~/Documents/txt/clipboard/'
alias vim-one-on-one='vim ~/Documents/txt/var/one-on-one'
alias vim-status='vim ~/Documents/txt/var/status'
alias vim-known-hosts='vim ~/.ssh/known_hosts'
alias zsh-sources='vim $DEVSETUP/files/zsh/sources.zsh'
alias zsh-controls='vim $DEVSETUP/files/zsh/functions.zsh'
# TODO autoreload these
alias zsh-aliases='vim $DEVSETUP/files/zsh/aliases.zsh'
alias zsh-functions='vim $DEVSETUP/files/zsh/functions.zsh'
alias zsh-variables='vim $DEVSETUP/files/zsh/variables.zsh'
alias zshrc='vim $DEVSETUP/files/zsh/zshrc'
#alias zshrc='vim ~/.zshrc'

# [administration]
alias dfh='df -h'

# [packages/installation]
alias download-remi='echo curl -LO https://rpms.remirepo.net/enterprise/remi-release-7.rpm'
alias download-wifi-driver='git clone https://github.com/tomaspinho/rtl8821ce'
alias install-homebrew='/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
alias install-rvm='\curl -sSL https://get.rvm.io | bash -s stable --ruby'

# [find/list/git]
alias ls-merges-last-10='git log --oneline | grep Merge | head -n10'
alias ls-changed-files='git diff --name-only HEAD HEAD~1'
alias find-largest='find . -type f | xargs du -sh  | sort -rn | head -n25'
alias find-list-files='find . -maxdepth 1 -type f'
alias find-swap-files='find ~/Documents/txt -iname ".*.swp"'
alias find-swap-files_remove='rm $(find-swap_files|xargs)'
alias find-root-remove='find . -user root -exec rm -rf {} +'
#alias find-checksum="find . -type f | xargs md5sum | awk '{print $2 " " $1}' | sort | awk '{print $2 " " $1 }'"


# [run]
alias run-apacheds='/opt/ApacheDirectoryStudio/ApacheDirectoryStudio'
alias run-chef="bash --login -c 'rvm use 2.4.0; chef-solo -c $DEVSETUP/solo.rb'"

# [network]
alias ping-8='ping -c 3 8.8.8.8'

# [system]
alias cat-meminfo="cat /proc/meminfo | grep Total"
alias cat-cpuinfo="cat /proc/cpuinfo"
alias lspci-graphics="lspci -v|grep -i graphics"
alias lspci-network="lspci -v|grep -i net"
alias laptop-model="dmidecode | grep -A 9 'System Information' "

# [vagrant]
alias vgs="vagrant global-status"
alias vs="vagrant status"
alias vssh="vagrant ssh"
alias vup="vagrant up"
alias vd="vagrant destroy"
alias vsus="vagrant suspend"

# [shell]
alias st='shell-status'
alias r='ranger'
alias j='jobs'
alias disable-touchpad='org.gnome.desktop.peripherals.touchpad send-events disabled'
alias enable-touchpad='org.gnome.desktop.peripherals.touchpad send-events enabled'
alias whereami='pstree -s $$'
alias hist='history'
alias hist-all='cat ~/.history.d/**/*'
alias ff='echo make a function: <command> >/dev/null 2>&1 &' # maybe nohup?
# related, see: xargs -P 10 -r -n 1 wget -nv # (xargs start commands in parallel)
# maybe related: https://github.com/alexanderepstein/Bash-Snippets
# https://www.ostechnix.com/list-useful-bash-keyboard-shortcuts/ # add to terminal splash
# cool!:
#   mkdir /path/to/exampledir
#   cd !$
# Ctrl-Z, followed by `bg`, puts a process in the background
# https://linuxacademy.com/blog/linux/tutorial-the-best-tips-tricks-for-bash-explained/
# log iterations:
#   [ -z "$n" ] && n=0 || ((n=n+1)); echo hello >> "h.log.$n";
alias mount-iso-home-DVD.iso='mount -t iso9660 -o loop /home/brad/DVD.iso /mnt/iso/'
alias getent-group-wheel='getent group wheel'
alias printenv-default='printenv' # print environment variables # or, env?
alias clear-screen='printf "\033c"' # found on stack overflow
# Ctrl-S: freeze terminal output, Ctrl-Q: continue terminal output.
alias rvm-load='source /home/brad/.rvm/scripts/rvm; rvm use 2.4.3'
alias date-today='date +%Y%m%d'
alias cat-zsh-aliases-magic='print -rl -- ${(k)aliases} ${(k)functions} ${(k)parameters}'
alias cat-zsh-aliases='cat $DEVSETUP/files/zsh/aliases.zsh | grep -o "^alias.*=" | sed "s/^alias\(.*\)=/\1/"'
# For suffix aliases, you can bulk them
# alias -s {ape,avi,flv,m4a,mkv,mov,mp3,mp4,mpeg,mpg,ogg,ogm,wav,webm}=mpv
# alternate: echo 'employee_id=1234' | grep -oP 'employee_id=\K([0-9]+)'

# [pseudocode]
alias psuedocode-gitlab='vim $DEVSETUP/files/pseudocode/gitlab.txt'

# [cheatsheets]
alias cheatsheet-make='vim $DEVSETUP/files/cheatsheets/make.txt'
#alias cheatsheet-python='vim $DEVSETUP/files/cheatsheets/python.txt'
alias cheatsheet-django='vim $DEVSETUP/files/cheatsheets/django.txt'
alias cheatsheet-vmware='vim $DEVSETUP/files/cheatsheets/vmware.txt'
alias cheatsheet-ansible='vim $DEVSETUP/files/cheatsheets/ansible.txt'
alias cheatsheet-ucarp='vim $DEVSETUP/files/cheatsheets/ucarp.txt'
alias cheatsheet-rspec='vim $DEVSETUP/files/cheatsheets/rspec.txt'
alias cheatsheet-vagrant='vim $DEVSETUP/files/cheatsheets/vagrant.txt'
alias cheatsheet-uefi='vim $DEVSETUP/files/cheatsheets/uefi.txt'
alias cheatsheet-gitlab='vim $DEVSETUP/files/cheatsheets/gitlab.txt'
alias cheatsheet-docker='vim $DEVSETUP/files/cheatsheets/docker.txt'
#alias cheatsheet-python='vim $DEVSETUP/files/cheatsheets/python.txt'
alias cheatsheet-awk='vim $DEVSETUP/files/cheatsheets/awk.txt'
alias cheatsheet-syslog='vim $DEVSETUP/files/cheatsheets/syslog.txt'
alias cheatsheet-terminal='vim $DEVSETUP/files/cheatsheets/terminal.txt'
#alias cheatsheet-sysadmin='vim $DEVSETUP/files/cheatsheets/sysadmin.txt'
alias cheatsheet-systemd='vim $DEVSETUP/files/cheatsheets/systemd.txt'
alias cheatsheet-ruby='vim $DEVSETUP/files/cheatsheets/ruby.txt'
alias cheatsheet-bundler='vim $DEVSETUP/files/cheatsheets/bundler.txt'
alias cheatsheet-virtualbox='vim $DEVSETUP/files/cheatsheets/virtualbox.txt'
alias cheatsheet-postgres='vim $DEVSETUP/files/cheatsheets/postgres'
alias cheatsheet-vim='vim $DEVSETUP/files/cheatsheets/vim'
alias cheatsheet-qwerty='cat $DEVSETUP/files/cheatsheets/qwerty'
alias cheatsheet-zsh='vim $DEVSETUP/files/zsh/cheatsheet'
alias cheatsheet-bash='vim $DEVSETUP/files/bash/cheatsheet'
alias cheatsheet-unix='vim $DEVSETUP/files/cheatsheets/bash_commands'
alias cheatsheet-rhel='vim $DEVSETUP/files/cheatsheets/linux'
alias cheatsheet-rpm='vim $DEVSETUP/files/cheatsheets/linux-rpm'
alias cheatsheet-network='vim $DEVSETUP/files/cheatsheets/network'
alias cheatsheet-tmux='vim $DEVSETUP/files/tmux/cheatsheet'
alias cheatsheet-ranger='echo S open shell in directory, c-h to show hidden files '
alias cheatsheet-sed='vi $DEVSETUP/files/cheatsheets/sed.txt'
alias cheatsheet-php='vi $DEVSETUP/files/cheatsheets/php'
alias cheatsheet-sql='vi $DEVSETUP/files/cheatsheets/sql'
alias cheatsheet-git='vi $DEVSETUP/files/cheatsheets/git'
alias cheatsheet-markdown='vi $DEVSETUP/files/cheatsheets/markdown'

# [locations]
alias c='cd'
alias cd-downloads='cd ~/Downloads'
alias cd-documents='cd ~/Documents/'
alias cd-txt='cd ~/Documents/txt/'
alias cd-devsetup='cd $DEVSETUP'
alias cd-projects='cd ~/Projects'
alias cd-vmass='cd ~/Projects/vmass'
# TODO use functions for feature detection
alias open-examples='open -a Finder ~/Examples || nautilus --browser ~/Examples'
alias open-tmp='open -a Finder /tmp || nautilus --browser /tmp'
alias open-dot='open -a Finder . || nautilus --browser .'

# [http]
alias curl-get-with-status='curl -Li localhost:5000 2> /dev/null | grep -i HTTP'
alias ifconfig-my-ip='ifconfig|grep -i -m1 "inet addr" | cut -d' ' -f12 | cut -d: -f2'
alias iptables-open-80='iptables -I INPUT 5 -i eth0 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT'

# [git]
# > git config --global alias.co checkout # adds alias.  do these have any auto-complete?
# https://git-scm.com/book/en/v2/Git-Basics-Git-Aliases
# Note that g r<tab> already give you git autocomplete and already lists aliases
# there has to be a way to do this will shell functions or something!
alias gitf='git checkout $(git branch | fzf)'
alias git-compare-master='git log master... --oneline; git log master... --oneline|wc -l'
alias git-compare-master-inspect='git log master... --oneline | awk "{print \$1}" | xargs -n1 git show --name-only'
alias git-list-aliases='git config --global --list | grep alias'
alias git-list-branch-moves="git reflog | grep -o 'moving from.*' | head -n25"
alias git-rebase-abort-force='rm -rf .git/rebase-apply'
alias git-folder-compare='git diff master..yourbranch path/to/folder'

alias git-ch='git cherry-pick'
alias git-cc='git cherry-pick --continue'
alias git-ca='git commit --amend'
alias git-sq='git commit -m squash'
alias git-recent-files='git diff --name-only HEAD~10..HEAD'
alias git-time-back='git log --grep Merge | grep Date -B5 | head -n200 | tail -n4'



# frequentuse
alias dfh='df -h'
alias vopen='xdg-open $(vip)' # TODO extract IP regex
alias vssh='vagrant ssh bootstrap'

# updatedaily
# see unsorted and unknowns under each of these
# need a way to "summarize", ie cat CS pipe grep context
# maybe functions:
# cheatsheet-python edit    <-- vim
# cheatsheet-python summary <-- grep context
#alias cheatsheet-python='vim $DEVSETUP/files/cheatsheets/python.txt' # + django
alias cheatsheet-ansible='vim $DEVSETUP/files/cheatsheets/ansible.txt'
#alias cheatsheet-sysadmin='vim $DEVSETUP/files/cheatsheets/sysadmin.txt'
alias cheatsheet-vim='vim $DEVSETUP/files/cheatsheets/vim.txt'
#alias cheatsheet-bash='vim $DEVSETUP/files/bash/cheatsheet'
alias cheatsheet-bash='vim $DEVSETUP/files/cheatsheets/bash.txt'
#alias cheatsheet-tmux='vim $DEVSETUP/files/tmux/cheatsheet'
# redirect and tail to watch other windows!
# remember to use a circular workflow with open tmux windows: edit --> test --> build --> deploy --> clipboard etc
alias cheatsheet-tmux='vim $DEVSETUP/files/cheatsheets/tmux.txt'
#alias cheatsheet-ranger='echo S open shell in directory, c-h to show hidden files '
alias cheatsheet-sed='vi $DEVSETUP/files/cheatsheets/sed.txt' # include regexes
alias cheatsheet-git='vi $DEVSETUP/files/cheatsheets/git.txt'

# TODO add clean() reset()
alias cheatsheet-selenium='vi $DEVSETUP/files/cheatsheets/selenium.txt'



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
