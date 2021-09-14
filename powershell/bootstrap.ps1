<#
.SYNOPSIS
    Bootstrap dotfiles installation
#>
[CmdletBinding()]
param(
    # Dotfiles path
    [string]$Path = (Split-Path (Split-Path $MyInvocation.MyCommand.Path)),

    # Replace existing configuration
    [switch]$Force = $false
)

if (-not (Get-Module Dotfiles)) { Import-Module (Join-Path -Path $Path -ChildPath PowerShell\Modules\Dotfiles) }
Install-Bootstrap -Path $Path -Force $Force -Verbose
