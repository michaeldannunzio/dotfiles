# PowerShell 7 profile.
# Repo path: dotfiles\Microsoft.PowerShell_profile.ps1
# Linked to: %USERPROFILE%\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
#
# This mirrors the zsh setup on the Mac, so the muscle memory carries over.

# --- prompt ---
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

# --- history and completion ---
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# --- aliases that match the Mac ---
Set-Alias g git

function ll { Get-ChildItem -Force @args }
function la { Get-ChildItem -Force -Hidden @args }
function .. { Set-Location .. }
function ... { Set-Location ..\.. }

function gs { git status -sb @args }
function gl { git log --oneline --graph --decorate -20 @args }

# --- jump into WSL ---
function dev {
    # Opens the WSL home directory, never /mnt/c.
    wsl.exe --cd '~'
}

# --- winget helpers ---
function wupdate { winget upgrade --all --include-unknown }
function wapply {
    param([string]$Path = "$env:USERPROFILE\src\windows-config\configuration.dsc.yaml")
    winget configure -f $Path --accept-configuration-agreements
}

# --- environment ---
$env:EDITOR = 'code --wait'

# Git for Windows ships an ssh.exe. Use the Windows OpenSSH one instead,
# so the agent service and the keys agree.
$env:GIT_SSH = "$env:SystemRoot\System32\OpenSSH\ssh.exe"
