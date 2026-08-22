<#
.SYNOPSIS
  Repeats the debloat you already did, so a future reinstall is one command.
.DESCRIPTION
  Repo path: debloat\Debloat.ps1

  Run this in Windows PowerShell 5.1 (powershell.exe), not PowerShell 7.
  App removal and restore points need modules that PowerShell 7 does not have.

  Do not start this from Windows Terminal if you plan to remove Windows Terminal.

.NOTES
  Edit $AppsToRemove to match the choices you made the first time.
  Get the exact names from  Get-AppxPackage | Select-Object Name
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [switch]$SkipRestorePoint
)

# ---------------------------------------------------------------
# 1. Restore point
# ---------------------------------------------------------------
if (-not $SkipRestorePoint) {
    Enable-ComputerRestore -Drive "C:\"
    Checkpoint-Computer -Description "Pre-debloat" -RestorePointType "MODIFY_SETTINGS"
}

# ---------------------------------------------------------------
# 2. Store apps to remove
#    Keep Microsoft Store, Windows Terminal, and Edge.
#    The Store lets you reinstall, and winget needs the Store framework.
# ---------------------------------------------------------------
$AppsToRemove = @(
    'Microsoft.BingNews'
    'Microsoft.BingWeather'
    'Microsoft.GamingApp'
    'Microsoft.GetHelp'
    'Microsoft.Getstarted'
    'Microsoft.MicrosoftOfficeHub'
    'Microsoft.MicrosoftSolitaireCollection'
    'Microsoft.People'
    'Microsoft.Todos'
    'Microsoft.WindowsFeedbackHub'
    'Microsoft.WindowsMaps'
    'Microsoft.ZuneMusic'
    'Microsoft.ZuneVideo'
    'MicrosoftTeams'
    'Clipchamp.Clipchamp'
)

foreach ($app in $AppsToRemove) {
    if ($PSCmdlet.ShouldProcess($app, 'Remove for all users')) {
        Get-AppxPackage -AllUsers "*$app*" |
            Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue

        # Stop the app returning for new user accounts.
        Get-AppxProvisionedPackage -Online |
            Where-Object DisplayName -like "*$app*" |
            Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue

        Write-Host "Removed: $app"
    }
}

# ---------------------------------------------------------------
# 3. Interactive option
#    If you would rather pick from a wizard again, run this instead:
#      & ([scriptblock]::Create((irm "https://debloat.raphi.re/")))
#    Reference: https://github.com/Raphire/Win11Debloat
# ---------------------------------------------------------------

Write-Host ""
Write-Host "Debloat complete. Next: winget configure -f configuration.dsc.yaml"
