# Bookmarks:
# frequentuse, updatedaily
#
# Many of these aliases are now superseded by functions or plugins.
# The oh-my-zsh `git` plugin offers shortcuts such as `gst` for `git status`.
# You can also store command snippets in `navi` cheat sheets, e.g.:
#   `navi --query "rsync"`
# Alias definitions have moved to navi (see former_aliases.cheat)



# prompt for new journal entry?  automatic daily doesn't always make sense
#alias help='clear; shell-status; cat $DEVSETUP/files/help.txt'




# sysadmin

# check GPG packet on a bin file
# head -c 4 FILENAME | hexdump -C
# chat says: 00000000  85 1f 95 03                                       |....|
#            00000000  85 01 0C 03    # hex equivalent of below
# I saw:     00000000  205 001 \f 003 # octal
# gpg v3 indicated by last part

# [using] TODO: add to shell splash?

#  Instead of this, I keep a permanent log of every shell command I ever typed and have a handy alias to keep through it.
# It also keeps track of the directory a command was run from, so I can limit my search. That way if I ever want to get back into a project I was working on long ago, I can just grep for commands run from that directory.
# Not only that, but I can use it to cd to directories quickly. So if I was working under a huge p 10 level deep directory path, I have a alias that will match a string and cd into the last matching path in the permanent history file.
# Not only that, but I can also search and then choose and rerun a command in the history, and also edit before rerunning it.
# Just put:
# export PROMPT_COMMAND='if [ "$(id -u)" -ne 0 ]; then echo "$(date "+%Y-%m-%d.%H:%M:%S") $(pwd) $(history 1)" >> "${HOME}/bash_logs_$(hostname)/bash-history-$(date "+%Y-%m-%d").log"; fi'
# in your ~/.bash_profile. You also may need to `mkdir "${HOME}/bash_logs_$(hostname)"`
# I took this command from a Hacker News thread of the past. I don't have a link to it any more.


# ps aux | grep -E 'ping|ha' | grep -v grep | awk '{ print $1 " " $2 " " substr($0, index($0,$11)) }'

# [fzf]
# alias cdf='cd "$(find . -type d -name )"'
# needs to be a function
# alias cdf='cd "$(fzf)"'
# TODO:
# https://github.com/junegunn/fzf.vim#installation
# does this power control-P ?



# [subshells]


# TODO:
# https://github.com/junegunn/fzf.vim#installation
# [edit]
#alias vfzf='fzf > /tmp/.viminput'
# TODO autoreload these
#alias zshrc='vim ~/.zshrc'

# [administration]

# [packages/installation]

# [find/list/git]
# for dir in $(find . -type d); do echo $(ls -p $dir | grep -v / | wc -l) $dir; done | sort -nr
#alias find-checksum="find . -type f | xargs md5sum | awk '{print $2 " " $1}' | sort | awk '{print $2 " " $1 }'"


# [run]

# [network]

# [system]

# [vagrant]

# [shell]
# alias find . -mtime +28 -type f -exec rm {} +
# alias st='shell-status'
#alias j='jobs'
#alias fff='echo make a function: <command> >/dev/null 2>&1 &' # maybe nohup?
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
# Ctrl-S: freeze terminal output, Ctrl-Q: continue terminal output.
# For suffix aliases, you can bulk them
# alias -s {ape,avi,flv,m4a,mkv,mov,mp3,mp4,mpeg,mpg,ogg,ogm,wav,webm}=mpv
# alternate: echo 'employee_id=1234' | grep -oP 'employee_id=\K([0-9]+)'

# [pseudocode]

# [locations]
## instead, use pinned dirs
#alias cd-downloads='cd ~/Downloads'
#alias cd-documents='cd ~/Documents/'
#alias cd-txt='cd ~/Documents/txt/'
#alias cd-projects='cd ~/Projects'
#alias cd-vmass='cd ~/Projects/vmass'
# TODO use functions for feature detection

# [http]

# [git]
# > git config --global alias.co checkout # adds alias.  do these have any auto-complete?
# https://git-scm.com/book/en/v2/Git-Basics-Git-Aliases
# Note that g r<tab> already give you git autocomplete and already lists aliases
# there has to be a way to do this will shell functions or something!
# Note: these are obsolete and backwards


# good for django migrations



# frequentuse

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

