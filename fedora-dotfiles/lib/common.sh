#!/usr/bin/env bash
# Shared helpers for every install script.

DOTFILES_ROOT="${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/fedora-dotfiles"
MISSING_LOG="$STATE_DIR/missing-packages.log"
mkdir -p "$STATE_DIR"

RED=$'\033[31m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; BLUE=$'\033[34m'; OFF=$'\033[0m'

info()  { printf '%s==>%s %s\n' "$BLUE"   "$OFF" "$*"; }
ok()    { printf '%s  ok%s %s\n' "$GREEN"  "$OFF" "$*"; }
warn()  { printf '%s  !!%s %s\n' "$YELLOW" "$OFF" "$*"; }
fail()  { printf '%s  xx%s %s\n' "$RED"    "$OFF" "$*"; }

note_missing() {
  # $1 = manager, $2 = package name, $3 = reason
  printf '%s\t%s\t%s\n' "$1" "$2" "${3:-not found}" >> "$MISSING_LOG"
  warn "skipped $2 ($1): ${3:-not found}"
}

have() { command -v "$1" >/dev/null 2>&1; }

# Read a manifest file. Drops comments, blank lines and trailing spaces.
read_list() {
  local file="$1"
  [ -f "$file" ] || return 0
  sed -e 's/#.*//' -e 's/[[:space:]]*$//' "$file" | grep -v '^$'
}

# Ask once for sudo so later steps do not stop and wait.
prime_sudo() {
  if ! sudo -n true 2>/dev/null; then
    info "Administrator rights are needed for package installs."
    sudo -v || { fail "sudo failed"; exit 1; }
  fi
  # Keep the sudo ticket alive while the script runs.
  ( while true; do sudo -n true; sleep 60; kill -0 "$$" 2>/dev/null || exit; done ) 2>/dev/null &
}

fedora_version() { rpm -E %fedora; }
