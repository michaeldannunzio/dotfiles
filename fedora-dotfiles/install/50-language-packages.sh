#!/usr/bin/env bash
# Packages installed through language package managers.
set -uo pipefail
. "$(dirname "$0")/../lib/common.sh"

export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"

info "cargo crates"
if have cargo; then
  while read -r crate; do
    [ -z "$crate" ] && continue
    cargo install --locked "$crate" && ok "$crate" || note_missing cargo "$crate" "install failed"
  done < <(read_list "$DOTFILES_ROOT/packages/cargo.txt")
else
  warn "cargo not found; skipping crates"
fi

info "global npm packages"
if have npm; then
  npm config set prefix "$HOME/.npm-global"
  while read -r pkg; do
    [ -z "$pkg" ] && continue
    npm install -g "$pkg" && ok "$pkg" || note_missing npm "$pkg" "install failed"
  done < <(read_list "$DOTFILES_ROOT/packages/npm.txt")
else
  warn "npm not found; skipping"
fi

info "pipx tools"
if have pipx; then
  pipx ensurepath >/dev/null 2>&1 || true
  while read -r pkg; do
    [ -z "$pkg" ] && continue
    pipx install "$pkg" && ok "$pkg" || note_missing pipx "$pkg" "install failed"
  done < <(read_list "$DOTFILES_ROOT/packages/pipx.txt")
else
  warn "pipx not found; skipping"
fi

info "go tools"
if have go; then
  while read -r mod; do
    [ -z "$mod" ] && continue
    go install "$mod" && ok "$mod" || note_missing go "$mod" "install failed"
  done < <(read_list "$DOTFILES_ROOT/packages/go.txt")
else
  warn "go not found; skipping"
fi

ok "Language package stage finished"
