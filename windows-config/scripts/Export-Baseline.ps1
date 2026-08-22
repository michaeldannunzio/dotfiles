<#
.SYNOPSIS
  Records the current state of the machine before you change it.
.DESCRIPTION
  Repo path: scripts\Export-Baseline.ps1

  Run this first, and run it again after each change. Compare the two
  files to find the exact registry key or package that changed.
  This is the Windows version of the "defaults read" diff on macOS.
#>

param(
    [string]$OutDir = "$env:USERPROFILE\baseline"
)

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$stamp = Get-Date -Format 'yyyy-MM-dd_HHmmss'

Write-Host "Writing baseline to $OutDir"

# Installed desktop apps
winget export --output "$OutDir\winget-$stamp.json" --include-versions

# Store apps
Get-AppxPackage |
    Select-Object Name, PackageFullName |
    Sort-Object Name |
    Out-File "$OutDir\appx-$stamp.txt"

# Explorer and taskbar settings live here
reg export "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    "$OutDir\explorer-advanced-$stamp.reg" /y | Out-Null

# Startup entries
Get-CimInstance Win32_StartupCommand |
    Select-Object Name, Command, Location |
    Out-File "$OutDir\startup-$stamp.txt"

Write-Host "Done. Compare two runs with:"
Write-Host "  Compare-Object (Get-Content fileA) (Get-Content fileB)"
