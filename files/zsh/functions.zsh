# Aggregated zsh helper functions
# Original functions have been split into separate modules prefixed with fn_
# Auto generated by repository cleanup

_dir=${(%):-%N}
_dir=${_dir:A:h}
source $_dir/fn_core.zsh
source $_dir/fn_file.zsh
source $_dir/fn_shortcuts.zsh
source $_dir/fn_login.zsh
source $_dir/fn_git.zsh
