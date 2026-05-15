# Project decisions

## zsh helpers remain modules
We considered turning `functions.zsh` and related files into oh-my-zsh custom plugins.
Keeping them as plain modules lets the scripts work without oh-my-zsh and reduces
maintenance. Therefore we deliberately keep the helper files as standalone modules
and do not plan to convert them into plugins.
