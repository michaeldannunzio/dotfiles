#!/usr/bin/env bash
# Sets up the Linux side of the PC.
# Repo path: wsl/wsl-bootstrap.sh
#
# It installs Nix, then applies the SAME home-manager configuration your
# MacBook uses. Your shell, git, neovim, direnv, and aliases become
# identical on both machines.
#
# Run inside WSL:
#   bash wsl-bootstrap.sh

set -euo pipefail

NIX_CONFIG_REPO="${NIX_CONFIG_REPO:-git@github.com:CHANGE_ME/nix-config.git}"
NIX_CONFIG_DIR="${NIX_CONFIG_DIR:-$HOME/.config/nix-config}"
HM_TARGET="${HM_TARGET:-server}"

echo "==> 1. Enable systemd, which the Nix daemon needs"
if ! grep -q "systemd=true" /etc/wsl.conf 2>/dev/null; then
  sudo tee -a /etc/wsl.conf > /dev/null <<'WSLCONF'

[boot]
systemd=true
WSLCONF
  echo "    systemd enabled. Run 'wsl --shutdown' in PowerShell, reopen WSL,"
  echo "    then run this script again."
  exit 0
fi

echo "==> 2. Install Nix, if it is absent"
if ! command -v nix > /dev/null 2>&1; then
  curl -sSf -L https://install.lix.systems/lix | sh -s -- install
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

echo "==> 3. Clone the Nix configuration"
if [ ! -d "$NIX_CONFIG_DIR" ]; then
  git clone "$NIX_CONFIG_REPO" "$NIX_CONFIG_DIR"
fi

echo "==> 4. Apply home-manager"
cd "$NIX_CONFIG_DIR"
nix run home-manager/release-26.05 -- switch --flake ".#${HM_TARGET}"

echo ""
echo "Done. Two rules from here:"
echo "  1. Keep all code in \$HOME, never in /mnt/c. The 9p bridge is very slow."
echo "  2. Per project toolchains come from devshell-flake.nix, not global installs."
