<#
.SYNOPSIS
    Dotfiles Install script for Windows 10
.DESCRIPTION
	Install user profile and configuration
#>
[cmdletbinding()]
param(
    # Dotfiles destination
    [string]$Path = (Join-Path -Path $env:USERPROFILE -ChildPath ".config\dotfiles")
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Use TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

switch ($PSVersionTable.PSEdition) {
    'Desktop' { Import-Module -Name Appx  }
    Default { Import-Module -Name Appx -UseWindowsPowershell }
}

function Install-Winget {
    <#
    .SYNOPSIS
    Install winget package manager
    #>
    $winget = Get-AppPackage -Name 'Microsoft.DesktopAppInstaller'
    if (-not $winget) {
        # Prerequisites
        Add-AppxPackage -Path 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx'

        # Get latest AppInstaller release
        $releasesUri = 'https://api.github.com/repos/microsoft/winget-cli/releases/latest'
        $releases = Invoke-RestMethod -Uri $releasesUri
        $latestRelease = $releases.assets | Where-Object { $_.browser_download_url.EndsWith('msixbundle') } | Select-Object -First 1
        Write-Output "Installing winget $($latestRelease.browser_download_url)"
        Add-AppxPackage -Path $latestRelease.browser_download_url
    } else {
        Write-Verbose "winget installed"
    }
}

function Install-Packages {
    <#
    .SYNOPSIS
    Install base packages via Windows Package Manager
    #>
    $packages = @('Git.Git', 'Microsoft.PowerShell')
    foreach ($p in $packages) {
        winget list --id $p --exact | Out-Null
        if (-not $?) {
            Write-Output "Installing $p"
            winget install --id $p --exact --interactive
        } else {
            Write-Verbose "$p installed"
        }
    }
}

function Install-Dotfiles {
    param(
        # Dotfiles path
        [string]$Path
    )

    # Clone dotfiles
    if (-not (Test-Path -Path $Path)) {
        Write-Output "Clone dotfiles"
        $dotfileParent = Split-Path -Path $Path
        if (-not (Test-Path -Path $dotfileParent)) {
            New-Item -Path $dotfileParent -ItemType Directory -Force
        }
        Start-Process -FilePath (Get-Command git.exe) -ArgumentList "clone https://github.com/ascarter/dotfiles.git $Path" -Wait -NoNewWindow
    } else {
        Write-Verbose "dotfiles installed"
    }

    # Set DOTFILES environment variable
    if ($null -eq [System.Environment]::GetEnvironmentVariable("DOTFILES", [System.EnvironmentVariableTarget]::User)) {
        Write-Output "Set DOTFILES environment variable"
        [System.Environment]::SetEnvironmentVariable("DOTFILES", $Path, [System.EnvironmentVariableTarget]::User)
    } else {
        Write-Verbose "dotfiles env set"
    }
}

Write-Output "Installing prerequisites"
Install-Winget
Install-Packages

Write-Output "Installing dotfiles"
Install-Dotfiles -Path $Path

Write-Output "Bootstrap dotfiles"
$boostrapScript = Join-Path -Path $Path -ChildPath Powershell\bootstrap.ps1
Start-Process pwsh -ArgumentList "-NoProfile -File $boostrapScript -Path $Path -Verbose" -Wait -NoNewWindow

Write-Output "dotfiles install complete"
Write-Output "Reload session to apply configuration"
