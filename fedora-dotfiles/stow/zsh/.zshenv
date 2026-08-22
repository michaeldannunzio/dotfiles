# Loaded for every zsh, including non-interactive ones. Keep it to PATH only.
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

path_add() { case ":$PATH:" in *":$1:"*) ;; *) [ -d "$1" ] && PATH="$1:$PATH" ;; esac; }

path_add "$HOME/.local/bin"
path_add "$HOME/bin"
path_add "$HOME/.cargo/bin"
path_add "$HOME/.npm-global/bin"
path_add "$HOME/go/bin"
path_add "$HOME/.deno/bin"
export PATH
