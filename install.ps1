<#
.SYNOPSIS
    Install script for Windows 10
.DESCRIPTION
    Configure dotfiles configuration for current Windows user
.PARAMETER Verbose
	Display diagnostic information
#>
[cmdletbinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Use TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Require administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
	Write-Error "Insufficient privileges"
}

function Enable-WindowsCapability([string]$Name) {
	if ((Get-WindowsCapability -Online -Name $Name).State -eq "Disabled") {
		Write-Host "Adding Windows capability $Name"
		Add-WindowsCapability -Online -Name $Name
	}
 else {
		Write-Host "$Name enabled"
	}
}

function Enable-WindowsFeature([string]$Name) {
	if ((Get-WindowsOptionalFeature -Online -FeatureName $Name).State -eq "Disabled") {
		Write-Host "Enabling $Name"
		Enable-WindowsOptionalFeature -Online -FeatureName $Name -All
	}
 else {
		Write-Host "$Name enabled"
	}
}

function Enable-Service([string]$Name) {
	if ((Get-Service -Name $Name).StartType -ne 'Automatic') {
		Write-Host "Set $Name to startup automatic"
		Set-Service -Name $Name -StartupType 'Automatic'
	}

	if ((Get-Service -Name $Name).Status -ne 'Running') {
		Write-Host "Start $Name"
		Start-Service $Name
	}
}

function Install-SSH() {
	# Install OpenSSH
	# https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse
	Enable-WindowsCapability OpenSSH.Client
	Enable-WindowsCapability OpenSSH.Server

	# Add firewall rule
	if (!((Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP").Enabled -eq $true)) {
		Write-Warning "Missing OpenSSH Server inbound firewall rule"
	}

	# Install OpenSSHUtils
	Install-Module -Name OpenSSHUtils -Scope AllUsers -Force

	Enable-Service ssh-agent
	Enable-Service sshd

	# Create SSH key if not present
	$sshKeyfile = Join-Path -Path $env:USERPROFILE -ChildPath '.ssh\id_rsa'
	if (!(Test-Path $sshKeyFile)) {
		Write-Host "Generating SSH user key"
		$githubEmail = Read-Host -Prompt "Enter GitHub email address"
		ssh-keygen -t rsa -b 4096 -C "$githubEmail"
		ssh-add $sshKeyFile

		# Copy SSH public key to clipboard
		$sshPublicKeyFile = $sshKeyFile + '.pub'
		if ($PSVersionTable.PSVersion.Major -lt 6) {
			Get-Content -Path $sshPublicKeyFile | Set-Clipboard
		}
		else {
			Invoke-WinCommand -ScriptBlock { Get-Content -Path $sshPublicKeyFile | Set-Clipboard }
		}
		Write-Host "ssh public key copied to clipboard."
		Write-Host "Add key to GitHub account"
		Start-Process "https://github.com/settings/ssh/new"
		Write-Host "After adding to GitHub, Press any key to continue..."
		[void][System.Console]::ReadKey($true)
	}
}

function Install-Chocolatey() {
	if (($null -eq $env:ChocolateyInstall) -or !(Test-Path -Path $env:ChocolateyInstall)) {
		Write-Host "Installing Chocolatey"
		Set-ExecutionPolicy AllSigned -Scope Process -Force
		Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression
	}
}

function Install-WSLDistros() {
	# Ubuntu 18.04
	$ubuntuPath = Join-Path -Path $env:LOCALAPPDATA -ChildPath "Microsoft\WindowsApps\ubuntu1804.exe"
	if (!(Test-Path -Path $ubuntuPath)) {
		Write-Host "Installing Ubuntu 18.04"
		$ubuntuAppx = New-TemporaryFile
		Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1804 -OutFile $ubuntuAppx -UseBasicParsing
		Add-AppxPackage $ubuntuAppx
		Remove-Item -Path $ubuntuAppx
	}
}

Write-Host "Starting dotfiles install"

# Setup PowerShellGet
if (!(Get-Module -Name PowerShellGet -All)) {
	Install-Module -Name PowerShellGet -Scope CurrentUser -Force -AllowClobber
}

# Enable Windows PowerShell compatibility if PowerShell 6
if ($PSVersionTable.PSVersion.Major -eq 6) {
	Install-Module -Name WindowsCompatibility -Scope CurrentUser
}

Install-SSH
Install-Chocolatey

# Install git if missing
if (!(Get-Command -Verb git.exe)) {
	choco install --confirm --limitoutput git --params "/SChannel"

	# Add git to the path since the current shell won't see it
	$env:Path += ";" + $(Join-Path -Path $env:ProgramFiles -ChildPath "Git\cmd")
}

# Install posh-git
if (!(Get-Module -Name posh-git -All)) {
	Install-Module -Name posh-git -Scope CurrentUser -AllowPrerelease -Force
}

# Create config directory
$configPath = Join-Path -Path $env:USERPROFILE -ChildPath ".config"
if (!(Test-Path -Path $configPath)) {
	Write-Host "Creating $configPath"
	New-Item -Path $configPath -ItemType Directory
}

# Clone dotfiles
$dotfiles = Join-Path -Path $configPath -ChildPath "dotfiles"
if (!(Test-Path -Path $dotfiles)) {
	Write-Host "Clone dotfiles"
	git clone git@github.com:ascarter/dotfiles.git $dotfiles
}

# Link profile for PowerShell Core
if ($PSVersionTable.PSEdition -eq 'Core') {
	$profilePath = $profile.CurrentUserAllHosts
}
else {
	$profilePath = pwsh -Command { $profile.CurrentUserAllHosts }
}
if (!(Test-Path -Path $profilePath)) {
	Write-Host "Linking profile"
	New-Item -ItemType SymbolicLink -Path $profilePath -Target $target
}

# Configure Vim
$vimrc = Join-Path -Path $env:USERPROFILE -ChildPath "_vimrc"
if (!(Test-Path -Path $vimrc)) {
	Write-Host "Linking vimrc"
	$target = Join-Path -Path $dotfiles -ChildPath 'vimrc'
	New-Item -ItemType SymbolicLink -Path $vimrc -Target $target
}

# Install chocolatey software
choco install --confirm --limitoutput --no-progress (Join-Path -Path $dotfiles -ChildPath "choco.config")

# Install Linux distros
Install-WSLDistros

# Enable Windows Sandbox
Enable-WindowsFeature Containers-DisposableClientVM

# Enable Hyper-V support
Enable-WindowsFeature Microsoft-Hyper-V -All

Write-Host "Installation finished"
