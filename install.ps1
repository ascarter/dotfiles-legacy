<#
.SYNOPSIS
    dotfiles Install script for Windows 10/11
.DESCRIPTION
	Install user profile and configuration
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    # Dotfiles destination
    [string]$Path = (Join-Path -Path $env:USERPROFILE -ChildPath '.config\dotfiles'),

    # Replace existing configuration
    [switch]$Force

)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Use TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

switch ($PSVersionTable.PSEdition) {
    'Desktop' { Import-Module -Name Appx }
    Default { Import-Module -Name Appx -UseWindowsPowerShell }
}

Write-Output 'Installing prerequisites'

# Verify winget package manager
if (-not (Get-AppPackage -Name 'Microsoft.DesktopAppInstaller')) {
    Write-Error "winget required. See https://github.com/microsoft/winget-cli/" -ErrorAction Stop
}

# Install base packages via Windows Package Manager
$packages = @('Git.Git', 'Microsoft.PowerShell')
foreach ($p in $packages) {
    winget list --id $p --exact | Out-Null
    if (-not $?) {
        Write-Output "Installing $p"
        winget install --id $p --exact --interactive
    }
    else {
        Write-Verbose "$p installed"
    }
}

# Reload environment
$Env:Path = @([System.Environment]::GetEnvironmentVariable("Path","Machine"), [System.Environment]::GetEnvironmentVariable("Path","User")) -Join ";"

Write-Output 'Installing dotfiles'

# Clone dotfiles
if (-not (Test-Path -Path $Path)) {
    Write-Output 'Clone dotfiles'
    $dotfileParent = Split-Path -Path $Path
    if (-not (Test-Path -Path $dotfileParent)) {
        New-Item -Path $dotfileParent -ItemType Directory -Force
    }
    Start-Process -FilePath (Get-Command git.exe) -ArgumentList "clone https://github.com/ascarter/dotfiles.git $Path" -Wait -NoNewWindow
}
else {
    # Update dotfiles
    Start-Process -FilePath (Get-Command git.exe) -ArgumentList "pull" -Wait -NoNewWindow -WorkingDirectory $Path
    Write-Verbose 'dotfiles updated'
}

# Set DOTFILES environment variable
if ($null -eq [System.Environment]::GetEnvironmentVariable('DOTFILES', [System.EnvironmentVariableTarget]::User)) {
    Write-Output 'Set DOTFILES environment variable'
    [System.Environment]::SetEnvironmentVariable('DOTFILES', $Path, [System.EnvironmentVariableTarget]::User)
    Write-Output "DOTFILES=$([System.Environment]::GetEnvironmentVariable('DOTFILES', [System.EnvironmentVariableTarget]::User))"
}
else {
    Write-Verbose 'dotfiles env set'
}

Write-Output 'Bootstrap dotfiles'

if (-not (Get-Module PSDotfiles)) { Import-Module (Join-Path -Path $Path -ChildPath powershell\Modules\PSDotfiles) }
Install-Bootstrap -Path $Path -Force:$Force -Verbose

$bootstrapScript = Join-Path -Path $Path -ChildPath powershell\bootstrap.ps1
Start-Process pwsh -ArgumentList "-NoProfile -File $bootstrapScript -Path $Path -Verbose" -Wait -NoNewWindow

Write-Output 'dotfiles install complete'
Write-Output 'Reload session to apply configuration'
