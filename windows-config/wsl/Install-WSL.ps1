<#
.SYNOPSIS
  Installs WSL2 and the Linux distribution that will hold your dev environment.
.DESCRIPTION
  Repo path: wsl\Install-WSL.ps1

  Run in an elevated PowerShell window. A restart is needed after the
  first install.
#>

[CmdletBinding()]
param(
    [string]$Distro
)

wsl --install --no-distribution
wsl --set-default-version 2
wsl --update

if (-not $Distro) {
    Write-Host ""
    Write-Host "Available distributions:"
    wsl --list --online
    Write-Host ""
    Write-Host "Pick one, then run:  .\Install-WSL.ps1 -Distro <Name>"
    Write-Host "Use the exact Name column value. Fedora names include a version number."
    return
}

wsl --install -d $Distro

Write-Host ""
Write-Host "Now open the distribution once to create your user, then run:"
Write-Host "  wsl -d $Distro -- bash /mnt/c/path/to/windows-config/wsl/wsl-bootstrap.sh"
