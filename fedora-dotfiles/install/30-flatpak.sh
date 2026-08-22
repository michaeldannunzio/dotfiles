#!/usr/bin/env bash
# Install Flatpak applications. IDs that Flathub does not know are skipped.
set -uo pipefail
. "$(dirname "$0")/../lib/common.sh"

have flatpak || { warn "flatpak is not installed; skipping"; exit 0; }

while read -r app; do
  [ -z "$app" ] && continue
  if flatpak remote-info flathub "$app" >/dev/null 2>&1; then
    flatpak install -y --noninteractive flathub "$app" \
      && ok "$app" || note_missing flatpak "$app" "install failed"
  else
    note_missing flatpak "$app" "not on Flathub under this ID"
  fi
done < <(read_list "$DOTFILES_ROOT/packages/flatpak.txt")

ok "Flatpak stage finished"
