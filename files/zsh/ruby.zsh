# Centos 6.9 vm
# source /usr/local/share/chruby/chruby.sh
# source /usr/local/share/chruby/auto.sh
# RUBIES+=(~/.gem/ruby/*)

# Mac
source "/usr/local/Cellar/chruby/0.3.9/share/chruby/auto.sh"
source "/usr/local/Cellar/chruby/0.3.9/share/chruby/chruby.sh"
RUBIES+=(~/.rvm/rubies/*)
# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
# export PATH="$PATH:$HOME/.rvm/bin"

#if [ -f /usr/local/share/chruby/chruby.sh ] ; then
#  source /usr/local/share/chruby/chruby.sh
#fi
#
#if [ -f /usr/local/share/chruby/auto.sh ] ; then
#  source /usr/local/share/chruby/auto.sh
#fi
