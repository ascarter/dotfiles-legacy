<#
.SYNOPSIS
    Uninstall script for Windows
.DESCRIPTION
    Remove dotfiles configuration for current Windows user
#>
[CmdletBinding(SupportsShouldProcess)]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Remove user profile
if (Test-Path -Path $PROFILE.CurrentUserAllHosts) {
    Remove-Item -Path $PROFILE.CurrentUserAllHosts -Force
}

# Remove vimrc
$vimrc = Join-Path -Path $env:USERPROFILE -ChildPath _vimrc
if (Test-Path -Path $vimrc) { Remove-Item -Path $vimrc -Force }

# Remove gitconfig
$gitconfig = Join-Path -Path $env:USERPROFILE -ChildPath .gitconfig
if (Test-Path -Path $gitconfig) { Remove-Item -Path $gitconfig -Force }

# Remove dotfiles
if (Test-Path $Env:DOTFILES) { Remove-Item -Path $Env:DOTFILES -Recurse -Force}

# Unset DOTFILES environment variable
[System.Environment]::SetEnvironmentVariable("DOTFILES", $null, [System.EnvironmentVariableTarget]::User)

Write-Output "dotfiles uninstalled"
