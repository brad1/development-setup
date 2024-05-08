# Bookmarks:
# frequentuse, updatedaily

g='git'

# prompt for new journal entry?  automatic daily doesn't always make sense
alias help='clear; shell-status; cat $DEVSETUP/files/help.txt'

alias b-journal='browse-journal'

alias awkf='awk -F ":"' # custom field separator
alias awkf='awk "{print}"' # basically cat
alias awkf='awk "{print $0}"' # same

alias print-date="date +'%m-%d-%Y'"
alias edit-pending='vim /var/brad/pending.list'
alias canidothis='file="$(fzf)"; echo $file'

# sysadmin
alias genkey="openssh-keygen -t rsa -b 2048"
alias validate_saml_cert="xmlsec1 --verify --pubkey-cert-pem saml-idp-public-key --id-attr:ID urn:oasis:names:tc:SAML:2.0:assertion:Assertion saml.xml"

# check GPG packet on a bin file
# head -c 4 FILENAME | hexdump -C
# chat says: 00000000  85 1f 95 03                                       |....|
#            00000000  85 01 0C 03    # hex equivalent of below
# I saw:     00000000  205 001 \f 003 # octal
# gpg v3 indicated by last part

# [using] TODO: add to shell splash?
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

# [fzf]
# alias cdf='cd "$(find . -type d -name )"'
# needs to be a function
# alias cdf='cd "$(fzf)"'
# TODO:
# https://github.com/junegunn/fzf.vim#installation
# does this power control-P ?

alias queue='(cd ~/Documents/txt/queues && vimf)'
alias queues='queue'
alias q='queue'


# [subshells]
alias ss-q='(cd ~/Documents/txt/queues && zsh)'


# TODO:
# https://github.com/junegunn/fzf.vim#installation
# [edit]
alias -s {cs,ts,html,json,md}=$EDITOR
#alias vfzf='fzf > /tmp/.viminput'
alias getviminput='cat /tmp/.viminput'
alias vimf-changed='vim $(git status --short | awk "{print \$2}" | fzf)'
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
# TODO autoreload these
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
# for dir in $(find . -type d); do echo $(ls -p $dir | grep -v / | wc -l) $dir; done | sort -nr
alias find-largest-dir="for dir in \$(find . -type d); do echo \$(ls -p \$dir | grep -v / | wc -l) \$dir; done | sort -nr | head -n 1"
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
# alias find . -mtime +28 -type f -exec rm {} +
# alias st='shell-status'
alias st='shell-status2'
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

# [locations]
## instead, use pinned dirs
#alias cd-downloads='cd ~/Downloads'
#alias cd-documents='cd ~/Documents/'
#alias cd-txt='cd ~/Documents/txt/'
alias cd-devsetup='cd $DEVSETUP'
#alias cd-projects='cd ~/Projects'
#alias cd-vmass='cd ~/Projects/vmass'
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
alias git-count-file-changes="git log --pretty=format: --name-only -- . | sort | uniq -c | sort -nr" # replace . with a dir
alias git-cherrypick-branch="git log master..2694-django-allow-ha-vip --oneline | awk '{print $1}' | tac | xargs -I {} git cherry-pick {}"
alias gsno='git show --name-only'
alias git-not-staged='git status --short | awk "{print \$2}" | fzf'
alias gitf='git checkout $(git branch | fzf)'
# Note: these are obsolete and backwards
alias git-compare-files-with-master='git diff --name-only HEAD..origin/master'
alias git-compare-diffs-with-master='git diff HEAD..origin/master'
alias git-compare-commits-with-master='git log master... --oneline; git log master... --oneline|wc -l'
alias git-compare-commits-with-release='git log release... --oneline; git log release... --oneline|wc -l'
alias git-compare-master-inspect='git log master... --oneline | awk "{print \$1}" | xargs -n1 git show --name-only'
alias git-list-aliases='git config --global --list | grep alias'
alias git-list-branch-moves="echo use git-search-branch-moves"
alias git-search-branch-moves="git reflog | grep -o 'moving from.*' | head -n25 | fzf"
alias git-rebase-abort-force='rm -rf .git/rebase-apply'
alias git-folder-compare='git diff master..yourbranch path/to/folder'

alias git-ch='git cherry-pick'
alias git-cc='git cherry-pick --continue'
alias git-ca='git commit --amend'
alias git-sq='git commit -m squash'
alias git-recent-files='git diff --name-only HEAD~10..HEAD'
alias git-time-back='git log --grep Merge | grep Date -B5 | head -n200 | tail -n4'

# good for django migrations
alias git-files-changed-since='git log --after="March 25" --name-only  --pretty=format: -- server_api/api_root/database/migrations | sort | uniq'



# frequentuse
alias vopen='xdg-open $(vip)' # TODO extract IP regex
alias vssh='vagrant ssh bootstrap'

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

