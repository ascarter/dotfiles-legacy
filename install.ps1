<#
.SYNOPSIS
    Dotfiles Install script for Windows 10
.DESCRIPTION
    Installs useful software and configure dotfiles configuration for current Windows user
#>
[cmdletbinding()]
param(
	[Parameter(HelpMessage = "Skip system configuration")]
	[switch]
	$NoSystem = $false,
	[Parameter(HelpMessage = "Skip user configuration")]
	[switch]
	$NoUser = $false
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

#region Setup

# Use TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Create config directory
$configPath = Join-Path -Path $env:USERPROFILE -ChildPath ".config"
if (!(Test-Path -Path $configPath)) { New-Item -Path $configPath -ItemType Directory -Force }

# Init package cache
$pkgCache = Join-Path -Path $configPath -ChildPath 'cache\dotfiles'
if (!(Test-Path -Path $pkgCache)) { New-Item -Path $pkgCache -ItemType Directory -Force }

# Dotfiles enlistment
$dotfiles = Join-Path -Path $configPath -ChildPath "dotfiles"

$gitUri = 'https://github.com/git-for-windows/git/releases/download/v2.24.1.windows.2/Git-2.24.1.2-64-bit.exe'

#endregion

#region Install methods

function Install-Git() {
	# Install git if missing
	$gitID = 'programs:Git version 2.24.1.2/2.24.1.2'
	if (!(Get-Package | Where-Object { $_.CanonicalID -eq $gitID })) {
		$target = Join-Path -Path $pkgCache -ChildPath (Split-Path $gitURI -Leaf)
		Write-Host "Installing Git $target"
		if (!(Test-Path $target)) {
			$wc = New-Object System.Net.WebClient
			$wc.DownloadFile($gitUri, $target)
		}
		Start-Process -FilePath $target -Wait -NoNewWindow
	}
}

function Install-Dotfiles() {
	# Clone dotfiles
	if (!(Test-Path -Path $dotfiles)) {
		Write-Host "Clone dotfiles (https)"
		git clone https://github.com/ascarter/dotfiles.git $dotfiles
	}
}

#endregion

#region Main

Write-Host "Starting dotfiles install"

try {
	# Bootstrap dotfiles repo
	Write-Host "Bootstrap dotfiles"
	Install-Git
	Install-Dotfiles

	# Run system configuration
	if (-not $NoSystem) {
		Write-Host "Configure Windows"
		$systemPS = Join-Path -Path $dotfiles -ChildPath 'install_system.ps1'
		Write-Host $systemPS
		Start-Process powershell.exe -ArgumentList $systemPS -Verb RunAs -Wait
	}

	# Run user configuration
	if (-not $NoUser) {
		Write-Host "Configure user environment"
		$userPS = Join-Path -Path $dotfiles -ChildPath 'install_user.ps1'
		Start-Process powershell.exe -ArgumentList $userPS -NoNewWindow -Wait
	}

	Write-Host "dotfiles are ready"
}
catch {
	Write-Warning "Exception:"
	Write-Warning "Exception Type:    $($_.Exception.GetType().FullName)"
	Write-Warning "Exception Message: $($_.Exception.Message)"
	Write-Warning "Exception Stack:   $($_.Exception.StackTrace)"
}

#endregion
