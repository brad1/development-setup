RHEL_CHRUBY=/usr/local/share/chruby/
MAC_CHRUBY=/usr/local/Cellar/chruby/0.3.9/share/chruby/

# if it exists, source it
[ -f $MAC_CHRUBY/chruby.sh ]  && source $MAC_CHRUBY/chruby.sh
[ -f $MAC_CHRUBY/auto.sh ]    && source $MAC_CHRUBY/auto.sh
[ -f $RHEL_CHRUBY/chruby.sh ] && source $RHEL_CHRUBY/chruby.sh
[ -f $RHEL_CHRUBY/auto.sh ]   && source $RHEL_CHRUBY/auto.sh

[ -d ~/.rvm/rubies ] && RUBIES+=(~/.rvm/rubies/*)
[ -d ~/.gem/ruby ]   && RUBIES+=(~/.gem/ruby/*)

[ -d ~/.rvm/bin ] && export PATH="$PATH:$HOME/.rvm/bin"
