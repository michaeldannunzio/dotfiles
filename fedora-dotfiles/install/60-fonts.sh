#!/usr/bin/env bash
# Nerd Fonts. Fedora ships plain Fira Code and JetBrains Mono, but the Nerd Font
# patched builds carry the icon glyphs that starship, eza and neovim expect.
set -uo pipefail
. "$(dirname "$0")/../lib/common.sh"

FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

FONTS="FiraCode JetBrainsMono NerdFontsSymbolsOnly"
BASE="https://github.com/ryanoasis/nerd-fonts/releases/latest/download"

for f in $FONTS; do
  if [ -d "$FONT_DIR/$f" ]; then
    ok "$f already installed"
    continue
  fi
  tmp="$(mktemp -d)"
  if curl -fL -o "$tmp/$f.zip" "$BASE/$f.zip"; then
    mkdir -p "$FONT_DIR/$f"
    unzip -oq "$tmp/$f.zip" -d "$FONT_DIR/$f" && ok "$f installed"
  else
    note_missing font "$f" "download failed"
  fi
  rm -rf "$tmp"
done

fc-cache -f >/dev/null 2>&1 && ok "font cache rebuilt"
