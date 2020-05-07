<#
.SYNOPSIS
    Dotfiles Install script for Windows 10
.DESCRIPTION
	Enable system services and set user profiles and configuration
#>
[cmdletbinding()]
param(
    [Parameter(HelpMessage = "Skip system configuration")]
    [switch]
    $NoSystem = $false
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Run as administrator
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $relaunchArgs = "& '" + $MyInvocation.MyCommand.Definition + "'"
    Start-Process powershell -Verb RunAs -ArgumentList $relaunchArgs
    Break
}

#region Setup

# Use TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Create config directory
$configPath = Join-Path -Path $env:USERPROFILE -ChildPath ".config"
if (!(Test-Path -Path $configPath)) { New-Item -Path $configPath -ItemType Directory -Force }

# Dotfiles enlistment
$dotfilesRepo = 'ascarter/dotfiles.git'
$dotfiles = Join-Path -Path $configPath -ChildPath "dotfiles"

# SSH key file
$sshKeyfile = Join-Path -Path $env:USERPROFILE -ChildPath .ssh\id_ed25519

# Git
$gitUri = 'https://github.com/git-for-windows/git/releases/download/v2.24.1.windows.2/Git-2.24.1.2-64-bit.exe'
$gitCmd = Join-Path -Path $env:ProgramFiles -ChildPath "Git\cmd\git.exe"

#endregion

#region Bootstrap

function Install-Git() {
    if (!(Test-Path -Path $gitCmd)) {
        try {
            $gitInstaller = Split-Path $gitURI -Leaf
            $target = Join-Path -Path $env:TEMP -ChildPath $gitInstaller
            Write-Host "Installing Git $gitInstaller"
            $wc = New-Object System.Net.WebClient
            $wc.DownloadFile($gitUri, $target)
            Start-Process -FilePath $target -Wait -NoNewWindow
        }
        finally {
            if (Test-Path $target) { Remove-Item -Path $target }
        }
    }

    # Set Git SSH client
    if ($null -eq [System.Environment]::GetEnvironmentVariable("GIT_SSH", "User")) {
        [System.Environment]::SetEnvironmentVariable("GIT_SSH", (Get-Command ssh.exe).Path, [System.EnvironmentVariableTarget]::User)
    }
}

function Install-SSHKeys() {
    # Create SSH key if not present
    if (!(Test-Path $sshKeyFile)) {
        Write-Host "Generating SSH user key"
        $githubEmail = Read-Host -Prompt "Enter GitHub email address"
        ssh-keygen -t ed25519 -C "$githubEmail"
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

function Install-Dotfiles() {
    # Clone dotfiles
    if (!(Test-Path -Path $dotfiles)) {
        Write-Host "Clone dotfiles"
        $repo = if (Test-Path -Path $sshKeyfile) { "git@github.com:$dotfilesRepo" } else { "https://github.com/$dotfilesRepo" }
        Start-Process -FilePath $gitCmd -ArgumentList "clone $repo $dotfiles" -Wait -NoNewWindow
    }
}

function Install-Profiles() {
    $setprofiles = Join-Path -Path $dotfiles -ChildPath setprofiles.ps1
    if (Test-Path -Path $setprofiles) { Start-Process -FilePath powershell -ArgumentList $setprofiles -Wait -NoNewWindow }
}

#endregion

#region System Configuration

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
    Install-Module -Name OpenSSHUtils -Scope AllUsers -Force

    Set-Service -Name ssh-agent -StartupType 'Automatic'
    Start-Service ssh-agent
    Set-Service -Name sshd -StartupType 'Automatic'
    Start-Service sshd

    # Configure default shell
    New-ItemProperty -Path HKLM:\SOFTWARE\OpenSSH -Name DefaultShell -Value $env:ProgramFiles\PowerShell\6\pwsh.exe
}

function Install-Virtualization() {
    Enable-WindowsOptionalFeature -Online -FeatureName Containers-DisposableClientVM -All
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -All
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -All
}

#endregion

Write-Output "Install dotfiles"

Install-Git
Install-SSHKeys
Install-Dotfiles
Install-Profiles

# Run system configuration
if (-not $NoSystem) {
    Install-SSH
    Install-Virtualization
}

Write-Output "Dotfiles install complete"
