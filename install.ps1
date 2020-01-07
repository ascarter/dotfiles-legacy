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

function Install-SSH() {
	# Install OpenSSH
	# https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse
	Add-WindowsCapability -Online -Name OpenSSH.Client 
	Add-WindowsCapability -Online -Name OpenSSH.Server 

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

Write-Host "Starting dotfiles install"

# Enable PSRemoting
if (!(Test-WSMan)) { Enable-PSRemoting }

Install-SSH
Install-Chocolatey

# Install git if missing
if (!(Get-Command -Verb git.exe)) { choco install --confirm --limitoutput git --params "/SChannel" }

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

# Enable Hyper-V support
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All 

Write-Host "Installation finished"
exit 0
