<#
.SYNOPSIS
    Uninstall script for Windows 10
.DESCRIPTION
    Remove dotfiles configuration for current Windows user
.PARAMETER Verbose
	Display diagnostic information
#>
[cmdletbinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Require administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Insufficient privileges"
}

# Remove user profile
if (!(Test-Path -Path $PROFILE.CurrentUserAllHosts)) { Remove-Item -Path $PROFILE.CurrentUserAllHosts }

