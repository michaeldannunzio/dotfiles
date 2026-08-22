# Interactive zsh configuration.

# --- history ---------------------------------------------------------------
HISTFILE="$XDG_STATE_HOME/zsh/history"
mkdir -p "${HISTFILE:h}"
HISTSIZE=50000
SAVEHIST=50000
setopt append_history share_history hist_ignore_all_dups hist_ignore_space
setopt hist_reduce_blanks extended_history

# --- behaviour -------------------------------------------------------------
setopt auto_cd correct interactive_comments no_beep
setopt glob_dots extended_glob

# --- completion ------------------------------------------------------------
autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# --- key bindings ----------------------------------------------------------
bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# --- plugins (installed by dnf) --------------------------------------------
for plugin in \
  /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
do
  [ -r "$plugin" ] && source "$plugin"
done

# --- aliases ---------------------------------------------------------------
command -v eza >/dev/null && {
  alias ls='eza --group-directories-first'
  alias ll='eza -lh --group-directories-first --git'
  alias la='eza -lah --group-directories-first --git'
  alias lt='eza --tree --level=2'
} || {
  alias ll='ls -lh'
  alias la='ls -lah'
}
command -v bat >/dev/null && alias cat='bat --paging=never'
command -v fd  >/dev/null || alias fd='fdfind'
command -v trash >/dev/null && alias rm='trash'

alias g='git'
alias gs='git status -sb'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate -20'
alias ..='cd ..'
alias ...='cd ../..'
alias dnfs='dnf search'
alias dnfi='sudo dnf install'
alias dots='cd ~/.dotfiles'
alias reload='exec zsh'

# --- tools -----------------------------------------------------------------
command -v zoxide   >/dev/null && eval "$(zoxide init zsh)"
command -v starship >/dev/null && eval "$(starship init zsh)"
command -v fnm      >/dev/null && eval "$(fnm env --use-on-cd --shell zsh)"

if command -v fzf >/dev/null; then
  source <(fzf --zsh) 2>/dev/null || true
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
fi

# --- local overrides, never committed --------------------------------------
[ -r "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
