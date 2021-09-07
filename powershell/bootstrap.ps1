<#
.SYNOPSIS
    Bootstrap dotfiles installation
#>
[CmdletBinding()]
param(
    [string]$Path = (Split-Path (Split-Path $MyInvocation.MyCommand.Path))
)

if (-not (Get-Module Dotfiles)) { Import-Module (Join-Path -Path $Path -ChildPath PowerShell\Modules\Dotfiles) }
Install-Bootstrap -Path $Path -Verbose
