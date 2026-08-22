<#
.SYNOPSIS
  One entry point for a fresh Windows install.
.DESCRIPTION
  Repo path: bootstrap.ps1

  Runs the stages in the only order that works. Each stage is safe to
  repeat. Read each script before you run it.

  Stage 1 must run in Windows PowerShell 5.1 (powershell.exe).
  Stages 2 to 5 run in PowerShell 7 (pwsh.exe).
#>

[CmdletBinding()]
param(
    [ValidateSet('Baseline','Debloat','Configure','Dotfiles','WSL')]
    [string]$Stage
)

$repo = $PSScriptRoot

switch ($Stage) {

    'Baseline' {
        & "$repo\scripts\Export-Baseline.ps1"
    }

    'Debloat' {
        Write-Host "Use powershell.exe 5.1 for this stage."
        & "$repo\debloat\Debloat.ps1"
    }

    'Configure' {
        # The DSC modules the configuration file depends on.
        Install-Module -Name Microsoft.WinGet.DSC -Force -Scope CurrentUser -AllowPrerelease
        Install-Module -Name PSDscResources -Force -Scope CurrentUser

        winget configure validate -f "$repo\configuration.dsc.yaml"
        winget configure show     -f "$repo\configuration.dsc.yaml"
        winget configure          -f "$repo\configuration.dsc.yaml" --accept-configuration-agreements
    }

    'Dotfiles' {
        & "$repo\scripts\Link-Dotfiles.ps1"
    }

    'WSL' {
        & "$repo\wsl\Install-WSL.ps1"
    }

    default {
        Write-Host @"
Run the stages in this order:

  .\bootstrap.ps1 -Stage Baseline     record the machine before you touch it
  .\bootstrap.ps1 -Stage Debloat      remove the apps (powershell.exe 5.1)
  .\bootstrap.ps1 -Stage Configure    install apps and apply Windows settings
  .\bootstrap.ps1 -Stage Dotfiles     link the config files
  .\bootstrap.ps1 -Stage WSL          install WSL2, then run wsl-bootstrap.sh

Run Baseline again after each stage, and compare, to see what changed.
"@
    }
}
