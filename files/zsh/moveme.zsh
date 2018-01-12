HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=100000
setopt appendhistory autocd beep extendedglob nomatch notify
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Use ctrl-r for search with vi bindings
bindkey -v
bindkey '\e[3~' delete-char
bindkey '^R' history-incremental-search-backward


# timestamp, working directory, newline to prompt.
# move me to dev-setup/../custom.zsh
NEWLINE=$'\n'
export PS1="[%* - %D] %d %% ${NEWLINE}> "


# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
if [ -n "$BASH_VERSION" ] || [ -n "$ZSH_VERSION" ]; then
#	source /usr/local/share/chruby/chruby.sh
#	source /usr/local/share/chruby/auto.sh
  source "/usr/local/Cellar/chruby/0.3.9/share/chruby/auto.sh"
  source "/usr/local/Cellar/chruby/0.3.9/share/chruby/chruby.sh"
  RUBIES+=(~/.rvm/rubies/*)
fi

function cls() {
  clear; ls -lh
}
