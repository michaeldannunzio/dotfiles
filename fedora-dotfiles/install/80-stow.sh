#!/usr/bin/env bash
# Link the dotfiles into $HOME with GNU Stow.
# Each folder under stow/ is one package. Add a folder, run this again.
set -uo pipefail
. "$(dirname "$0")/../lib/common.sh"

have stow || { fail "GNU Stow is not installed. Run: sudo dnf install stow"; exit 1; }

cd "$DOTFILES_ROOT/stow" || exit 1

BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

for pkg in */; do
  pkg="${pkg%/}"
  [ -d "$pkg" ] || continue

  # Move any real file that would block the symlink into a backup folder.
  while read -r rel; do
    target="$HOME/$rel"

    # Skip anything that already resolves into this repo. Stow folds whole
    # directories into one symlink, so $HOME/.config/nvim/init.lua can already
    # be a repo file reached through a symlinked parent. Moving it would delete
    # the real dotfile.
    resolved="$(readlink -f "$target" 2>/dev/null || true)"
    case "$resolved" in
      "$DOTFILES_ROOT"/*) continue ;;
    esac

    if [ -e "$target" ] && [ ! -L "$target" ]; then
      mkdir -p "$BACKUP/$(dirname "$rel")"
      mv "$target" "$BACKUP/$rel"
      warn "backed up $rel"
    fi
  done < <(cd "$pkg" && find . -type f | sed 's|^\./||')

  if stow --target="$HOME" --restow "$pkg"; then
    ok "linked $pkg"
  else
    fail "stow failed for $pkg"
  fi
done

[ -d "$BACKUP" ] && info "Replaced files are in $BACKUP"
ok "Stow stage finished"
