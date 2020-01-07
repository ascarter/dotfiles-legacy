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
}

function Enable-WindowsFeature([string]$Name) {
	if ((Get-WindowsOptionalFeature -Online -FeatureName $Name).State -eq "Disabled") {
		Write-Host "Enabling $Name"
		Enable-WindowsOptionalFeature -Online -FeatureName $Name -All
	}
}

function Enable-DeveloperMode() {
	$regPath = 'HLKM:\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock'
	if (!((Get-ItemProperty -Path $regPath).AllowDevelopmentWithoutDevLicense -eq 1)) {
		Set-ItemProperty -Path $regPath -Name AllowDevelopmentWithoutDevLicense -Value 1 -PropertyType DWORD -Force
	}
	if (!((Get-ItemProperty -Path $regPath).AllowAllTrustedApps -eq 1)) {
		Set-ItemProperty -Path $regPath -Name AllowAllTrustedApps -Value 1 -PropertyType DWORD -Force
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
	Install-Module -Force OpenSSHUtils -Scope AllUsers

	# Configure SSH Agent
	Set-Service -Name ssh-agent -StartupType 'Automatic'
	Start-Service ssh-agent

	# Configure SSH server
	Set-Service -Name sshd -StartupType 'Automatic'
	Start-Service sshd

	# Create SSH key if not present
	$sshKeyfile = Join-Path -Path $env:USERPROFILE -ChildPath '.ssh\id_rsa'
	if (!(Test-Path $sshKeyFile)) {
		Write-Host "Generating SSH user key"
		$githubEmail = Read-Host -Prompt "Enter GitHub email address"
		ssh-keygen -t rsa -b 4096 -C "$githubEmail"
		ssh-add $sshKeyFile
	}
}

function Install-Chocolatey() {
	if (($env:ChocolateyInstall -eq $null) -or !(Test-Path -Path $env:ChocolateyInstall)) {
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

# if (!(Test-WSMan)) { Enable-PSRemoting }
Enable-DeveloperMode
Install-SSH
Install-Chocolatey

# Install git if missing
if (!(Get-Command -Verb git.exe)) {
	choco install --confirm --limitoutput git --params "/SChannel"

	# Add git to the path since the current shell won't see it
	$env:Path += ";" + $(Join-Path -Path $env:ProgramFiles -ChildPath "Git\cmd")
}

# Setup PowerShellGet
Install-Module -Name PowerShellGet -Force

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
	git clone https://github.com/ascarter/dotfiles $dotfiles
}

# Link profile
if (!(Test-Path -Path $PROFILE.CurrentUserAllHosts)) {
	Write-Host "Linking profile"
	$target = Join-Path -Path $dotfiles -ChildPath 'profile.ps1'
	New-Item -ItemType SymbolicLink -Path $PROFILE.CurrentUserAllHosts -Target $target
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
exit 0
