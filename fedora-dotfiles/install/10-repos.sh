#!/usr/bin/env bash
# Enable third-party repositories.
# Each block is independent. Comment out anything you do not want.
set -uo pipefail
. "$(dirname "$0")/../lib/common.sh"

FV="$(fedora_version)"

info "RPM Fusion (free and nonfree)"
if ! rpm -q rpmfusion-free-release >/dev/null 2>&1; then
  sudo dnf install -y \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FV}.noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FV}.noarch.rpm" \
    && ok "RPM Fusion enabled" || warn "RPM Fusion failed"
else
  ok "RPM Fusion already present"
fi

info "Flathub"
if have flatpak; then
  sudo flatpak remote-add --if-not-exists flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo && ok "Flathub enabled"
else
  sudo dnf install -y flatpak && sudo flatpak remote-add --if-not-exists flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo
fi

info "Visual Studio Code (Microsoft)"
if [ ! -f /etc/yum.repos.d/vscode.repo ]; then
  sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
  printf '%s\n' \
    '[code]' \
    'name=Visual Studio Code' \
    'baseurl=https://packages.microsoft.com/yumrepos/vscode' \
    'enabled=1' \
    'autorefresh=1' \
    'gpgcheck=1' \
    'gpgkey=https://packages.microsoft.com/keys/microsoft.asc' \
    | sudo tee /etc/yum.repos.d/vscode.repo >/dev/null
  ok "VS Code repo added"
else
  ok "VS Code repo already present"
fi

info "Google Chrome"
if [ ! -f /etc/yum.repos.d/google-chrome.repo ]; then
  printf '%s\n' \
    '[google-chrome]' \
    'name=google-chrome' \
    'baseurl=https://dl.google.com/linux/chrome/rpm/stable/x86_64' \
    'enabled=1' \
    'gpgcheck=1' \
    'gpgkey=https://dl.google.com/linux/linux_signing_key.pub' \
    | sudo tee /etc/yum.repos.d/google-chrome.repo >/dev/null
  ok "Chrome repo added"
else
  ok "Chrome repo already present"
fi

info "Docker CE (optional; podman is already in packages/dnf.txt)"
if [ "${INSTALL_DOCKER:-0}" = "1" ] && [ ! -f /etc/yum.repos.d/docker-ce.repo ]; then
  sudo dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo \
    || sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
  ok "Docker repo added. Set INSTALL_DOCKER=1 and add docker-ce to packages/dnf.txt to use it."
fi

info "COPR repos from packages/copr.txt"
read_list "$DOTFILES_ROOT/packages/copr.txt" | while read -r owner_project _rest; do
  [ -z "$owner_project" ] && continue
  sudo dnf -y copr enable "$owner_project" </dev/null \
    && ok "copr $owner_project" || warn "copr $owner_project failed"
done

ok "Repository setup finished"
