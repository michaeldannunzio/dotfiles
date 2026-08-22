<#
.SYNOPSIS
  Links the files in dotfiles\ to the places Windows expects them.
.DESCRIPTION
  Repo path: scripts\Link-Dotfiles.ps1

  Symbolic links need Developer Mode. The DSC configuration turns it on.
  Run configuration.dsc.yaml first.

  Use -WhatIf to see the plan without changing anything.
#>

[CmdletBinding(SupportsShouldProcess)]
param()

$repo = Split-Path -Parent $PSScriptRoot
$src  = Join-Path $repo 'dotfiles'

# Windows Terminal stores its settings in one of two places.
$wtStore    = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$wtUnpacked = "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
$wtTarget   = if (Test-Path (Split-Path $wtStore)) { $wtStore } else { $wtUnpacked }

$links = @(
    @{ Source = "$src\Microsoft.PowerShell_profile.ps1"
       Target = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" }

    @{ Source = "$src\windows-terminal-settings.json"
       Target = $wtTarget }

    @{ Source = "$src\gitconfig"
       Target = "$env:USERPROFILE\.gitconfig" }

    @{ Source = "$src\ssh-config"
       Target = "$env:USERPROFILE\.ssh\config" }
)

foreach ($link in $links) {
    if (-not (Test-Path $link.Source)) {
        Write-Warning "Missing source: $($link.Source)"
        continue
    }

    $parent = Split-Path -Parent $link.Target
    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }

    if (Test-Path $link.Target) {
        $item = Get-Item $link.Target -Force
        if ($item.LinkType -eq 'SymbolicLink') {
            Write-Host "Already linked: $($link.Target)"
            continue
        }
        $backup = "$($link.Target).bak"
        if ($PSCmdlet.ShouldProcess($link.Target, "Back up to $backup")) {
            Move-Item $link.Target $backup -Force
            Write-Host "Backed up to $backup"
        }
    }

    if ($PSCmdlet.ShouldProcess($link.Target, "Link to $($link.Source)")) {
        New-Item -ItemType SymbolicLink -Path $link.Target -Target $link.Source -Force | Out-Null
        Write-Host "Linked: $($link.Target)"
    }
}

Write-Host ""
Write-Host "Private keys are NOT linked. They stay in ~/.ssh and out of this repo."
