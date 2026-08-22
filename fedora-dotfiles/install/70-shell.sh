#!/usr/bin/env bash
# Make zsh the login shell.
set -uo pipefail
. "$(dirname "$0")/../lib/common.sh"

ZSH_PATH="$(command -v zsh || true)"
if [ -z "$ZSH_PATH" ]; then
  warn "zsh is not installed; skipping"
  exit 0
fi

grep -qx "$ZSH_PATH" /etc/shells || echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null

if [ "$SHELL" = "$ZSH_PATH" ]; then
  ok "zsh is already the login shell"
else
  if sudo chsh -s "$ZSH_PATH" "$USER"; then
    ok "login shell set to zsh. Log out and back in to apply it."
  else
    warn "could not change the login shell. Run: chsh -s $ZSH_PATH"
  fi
fi
