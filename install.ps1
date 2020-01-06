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

# Require administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
	Write-Error "Insufficient privileges"
}        

function Enable-WindowsCapability([string]$Name) {
	if ((Get-WindowsCapability -Online -Name $Name).State -eq "Disabled") { 
		Write-Host "Adding $Name"
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

function Install-Features() {
	if (!(Test-WSMan)) {
		Write-Host "Enable PSRemoting"
		Enable-PSRemoting
	}
	else {
		Write-Host "PSRemoting enabled"
	}

	Enable-WindowsFeature Microsoft-Hyper-V
}

function Install-SSH() {
	# Install OpenSSH
	# https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse
	Enable-WindowsCapability('OpenSSH.Client')
	Enable-WindowsCapability('OpenSSH.Server')

	# Configure SSH server
	Start-Service sshd	
	Set-Service -Name sshd -StartupType 'Automatic'
	
	# Add firewall rule
	if (!((Get-NetFirewallRule -Name "sshd").Enabled -eq $true)) {
		Write-Host "Add sshd firewall rule"
		#New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
	}

	# Install OpenSSHUtils
	# Install-Module -Force OpenSSHUtils -Scope AllUsers

	# Configure SSH Agent
	Start-Service ssh-agent
	Set-Service -Name ssh-agent -StartupType 'Automatic'

	# Create SSH key if not present
	$sshKeyfile = Join-Path -Path $env:USERPROFILE -ChildPath '.ssh\id_rsa'
	if (!(Test-Path $sshKeyFile)) {
		Write-Host "Generating SSH user key"
		$githubEmail = Read-Host -Prompt "Enter GitHub email address"
		ssh-keygen -t rsa -b 4096 -C "$githubEmail" -f $sshKeyFile
		ssh-add $sshKeyFile
	}
}

function Install-WSL() {
	# Enable WSL
	Enable-WindowsFeature Microsoft-Windows-Subsystem-Linux
	Enable-WindowsFeature VirtualMachinePlatform

	# Set WSL 2 as default version
	# wsl --set-default-version 2

	# Install Ubuntu 18.04
	$ubuntuPath = Join-Path -Path $env:LOCALAPPDATA -ChildPath "Microsoft\WindowsApps\ubuntu1804.exe"
	if (!(Test-Path -Path $ubuntuPath)) {
		$ubuntuAppx = New-TemporaryFile
		Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1804 -OutFile $ubuntuAppx -UseBasicParsing
		Add-AppxPackage $ubuntuAppx
		Remove-Item -Path $ubuntuAppx
	}
 else {
		Write-Host "Ubuntu 18.04 installed"
	}
}

function Install-Chocolatey() {
	if (!(Test-Path -Path $env:ChocolateyInstall)) {
		Write-Inforation "Installing Chocolatey..."
		Set-ExecutionPolicy AllSigned -Scope Process -Force
		Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression       
	}
	else {
		Write-Host "Chocolatey version $(choco -v)"
	}

	# Install software
	choco install --confirm --limitoutput --no-progress git --params "/SChannel"
	choco install --confirm --limitoutput --no-progress 7zip vim vscode microsoft-windows-terminal powershell-core
}

function Install-Dotfiles() {
	$configPath = Join-Path -Path $env:USERPROFILE -ChildPath ".config"
	if (!(Test-Path -Path $configPath)) {
		New-Item -Path $configPath -ItemType Directory
	}
    
	$dotfiles = Join-Path -Path $configPath -ChildPath "dotfiles"
	if (!(Test-Path -Path $dotfiles)) {
		Write-Host "Clone dotfiles"
		git clone https://github.com/ascarter/dotfiles $dotfiles
	}
 else {
		Write-Host "dotfiles present"
	}
}

function Install-ConfigurationFiles() {
	# Link profile
	if (!(Test-Path -Path $PROFILE.CurrentUserAllHosts)) {
		Write-Host "Linking profile"
		$target = Join-Path -Path $dotfiles -ChildPath 'profile.ps1'
		New-Item -ItemType SymbolicLink -Path $PROFILE.CurrentUserAllHosts -Target $target
	}
}

function Install-DotnetCore() {
	$dotnetPath = Join-Path -Path $env:LOCALAPPDATA -ChildPath "Microsoft\dotnet"
	if (!(Test-Path -Path $dotnetPath)) {
		Write-Host "Installing Dotnet Core"
		[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
		&([scriptblock]::Create((Invoke-WebRequest -UseBasicParsing 'https://dot.net/v1/dotnet-install.ps1'))) -Channel Current
	}
 else {
		Write-Host "dotnet $(dotnet --version)"
	}
}

function Install-Modules() {
	if (!(Get-Module -Name posh-git)) {
		Write-Host "Installing posh-git"
		Install-Module -Name posh-git -Scope CurrentUser -AllowPrerelease -Force			
	}
 else {
		Write-Host "posh-git installed"
	}
}


$steps = (
	"Features",
	"SSH",
	"Chocolatey",
	"Dotfiles",
	"ConfigurationFiles",
	"DotnetCore",
	"WSL",
	"Modules"
)

Write-Host "Installing dotfiles"
foreach ($fn in $steps) {
	Write-Host "Install $fn"
	Invoke-Expression "Install-$fn"
}

Write-Host "Installation finished"
exit 0
