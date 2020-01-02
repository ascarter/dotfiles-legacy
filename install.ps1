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
$ProgressPreference = "SilentlyContinue"

# Require administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
	Write-Error "Insufficient privileges"
}        

function Install-SSH([string]$SSHKeyFile) {
	# Install OpenSSH
	# https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse
	Add-WindowsCapability -Online -Name OpenSSH.Client
	Add-WindowsCapability -Online -Name OpenSSH.Server

	# Add firewall rule
	New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22

	# Install OpenSSHUtils
	Install-Module -Force OpenSSHUtils -Scope AllUsers

	# Configure SSH Agent
	Set-Service -Name ssh-agent -StartupType 'Automatic'
	Start-Service ssh-agent

	# Configure SSH server
	Set-Service -Name sshd -StartupType 'Automatic'
	Start-Service sshd
		
	# Create SSH key if not present
	if (!(Test-Path $SSHKeyFile)) {
		$githubEmail = Read-Host -Prompt "Enter GitHub email address"
		ssh-keygen -t rsa -b 4096 -C "$githubEmail" -f $SSHKeyFile
		ssh-add $SSHKeyFile
	}
}

function Install-WSL() {
	# Enable WSL
	Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
	Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform

	# Set WSL 2 as default version
	wsl --set-default-version 2

	# Install Ubuntu 18.04
	$ubuntuAppx = New-TemporaryFile
	Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1804 -OutFile $ubuntuAppx -UseBasicParsing
	Add-AppxPackage $ubuntuAppx
	Remove-Item -Path $ubuntuAppx
}


function Install-Chocolatey() {
	if (!(Test-Path -Path $env:ChocolateyInstall)) {
		Write-Inforation "Installing Chocolatey..."
		Set-ExecutionPolicy AllSigned -Scope Process -Force
		Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression       
	}
	else {
		Write-Information "Chocolatey version $(choco -v)"
	}
}


Write-Information "Enable PSRemoting"
Enable-PSRemoting

Write-Information "Enable Hyper-V"
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All		

Write-Information "Configure SSH"
Install-SSH((Join-Path -Path $env:USERPROFILE -ChildPath '.ssh\id_rsa'))

Write-Information "Install Chocolatey"
Install-Chocolatey

# Clone dotfiles
Write-Information "Clone dotfiles"
choco install git --params "/SChannel"
$configPath = Join-Path -Path $env:USERPROFILE -ChildPath ".config"
if (!(Test-Path -Path $configPath)) {
	New-Item -Path $configPath -ItemType Directory
}
$dotfiles = Join-Path -Path $configPath -ChildPath "dotfiles"
if (!(Test-Path -Path $dotfiles)) {
	git clone https://github.com/ascarter/dotfiles $dotfiles
}

# Link user profile
Write-Information "Link configuration files"
if (!(Test-Path -Path $PROFILE.CurrentUserAllHosts)) {
	$target = Join-Path -Path $dotfiles -ChildPath 'profile.ps1'
	New-Item -ItemType SymbolicLink -Path $PROFILE.CurrentUserAllHosts -Target $target
}

Write-Information "Install posh-git"
Install-Module -Name posh-git -Scope CurrentUser -AllowPrerelease -Force		

# Install software
$packages = (
	'7zip',
	'vim',
	'vscode',
	'microsoft-windows-terminal',
	'powershell-core'
)

foreach ($p in $packages) { choco install $p }

Write-Information "Install .NET Core"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
&([scriptblock]::Create((Invoke-WebRequest -UseBasicParsing 'https://dot.net/v1/dotnet-install.ps1'))) -Channel Current

Write-Information "Enable WSL"
Install-WSL

Write-Information "Installation finished"
exit 0
