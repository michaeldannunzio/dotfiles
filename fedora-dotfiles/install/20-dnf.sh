#!/usr/bin/env bash
# Install DNF packages. Names that do not exist are skipped and logged.
set -uo pipefail
. "$(dirname "$0")/../lib/common.sh"

exists_in_repo() {
  dnf -q repoquery --qf '%{name}' "$1" 2>/dev/null | grep -q .
}

install_list() {
  local label="$1" file="$2"
  local found=() pkg
  info "Checking $label"
  while read -r pkg; do
    [ -z "$pkg" ] && continue
    if exists_in_repo "$pkg"; then
      found+=("$pkg")
    else
      note_missing dnf "$pkg" "no such package in enabled repos"
    fi
  done < <(read_list "$file")

  if [ "${#found[@]}" -gt 0 ]; then
    info "Installing ${#found[@]} packages from $label"
    sudo dnf install -y "${found[@]}" && ok "$label done" || fail "$label had errors"
  else
    warn "$label: nothing to install"
  fi
}

info "Refreshing metadata"
sudo dnf -y makecache

info "Core development group"
sudo dnf -y group install development-tools 2>/dev/null \
  || sudo dnf -y groupinstall "Development Tools" 2>/dev/null \
  || warn "development-tools group not installed"

install_list "packages/dnf.txt" "$DOTFILES_ROOT/packages/dnf.txt"
install_list "packages/dnf-rpmfusion.txt" "$DOTFILES_ROOT/packages/dnf-rpmfusion.txt"

info "COPR packages"
read_list "$DOTFILES_ROOT/packages/copr.txt" | while read -r _owner pkgs; do
  for p in $pkgs; do
    sudo dnf install -y "$p" && ok "$p" || note_missing copr "$p" "install failed"
  done
done

info "Vendor repo packages"
for p in code google-chrome-stable; do
  if exists_in_repo "$p"; then
    sudo dnf install -y "$p" && ok "$p" || note_missing dnf "$p" "install failed"
  else
    note_missing dnf "$p" "vendor repo not reachable"
  fi
done

ok "DNF stage finished"
