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

# Remove user profile
if (Test-Path -Path $PROFILE) { Remove-Item -Path $PROFILE }

