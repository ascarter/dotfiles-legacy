<#
.SYNOPSIS
    Dotfiles profile install script for Windows 10
.DESCRIPTION
	Set user profiles for current user
#>
[cmdletbinding()]
param(
    [Parameter(HelpMessage = "Force profile install")]
    [switch]
    $Force = $false
)

Set-StrictMode -Version Latest

$dotfiles = Join-Path -Path $env:USERPROFILE -ChildPath ".config\dotfiles"

# PowerShell profile
# Source dotfiles profile for active powershell profile
if (!(Test-Path $profile) -or $Force) {
    New-Item -Path $profile -ItemType File -Force
    Set-Content -Path $profile -Value ". Join-Path $env:USERPROFILE .config\dotfiles\profile.ps1"
}

# Windows terminal profile
$wintermSrc = Join-Path -Path $dotfiles -ChildPath windows_terminal_profiles.json
$wintermTarget = Join-Path -Path $env:LocalAppData -ChildPath Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\profiles.json
if (!(Test-Path -Path $wintermTarget) -or $Force) {
    Copy-Item -Path $wintermSrc -Destination $wintermTarget -Force
}

# Vim profile
$vimrc = Join-Path -Path $env:USERPROFILE -ChildPath _vimrc
if (!(Test-Path -Path $vimrc) -or $Force) {
    New-Item -Path $vimrc -ItemType File -Force
    Set-Content -Path $vimrc -Value "source $(Join-Path -Path $dotfiles -ChildPath vimrc)"
}
