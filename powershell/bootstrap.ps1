<#
.SYNOPSIS
    Bootstrap PSDotfiles installation
#>
[CmdletBinding()]
param(
    # PSDotfiles path
    [string]$Path = (Split-Path (Split-Path $MyInvocation.MyCommand.Path)),

    # Replace existing configuration
    [switch]$Force
)

if (-not (Get-Module PSDotfiles)) { Import-Module (Join-Path -Path $Path -ChildPath powershell\Modules\PSDotfiles) }
Install-Bootstrap -Path $Path -Force:$Force -Verbose
