<#
.SYNOPSIS
    Windows configuration
.DESCRIPTION
    Configure Windows services. Requires administrator privileges.
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

#region Helpers

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
    else {
        Write-Host "$Name enabled"
    }

    if ((Get-Service -Name $Name).Status -ne 'Running') {
        Write-Host "Start $Name"
        Start-Service $Name
    }
    else {
        Write-Host "$Name started"
    }
}

#endregion

#region Install methods

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
}

function Install-Virtualization() {
    Enable-WindowsFeature Containers-DisposableClientVM
    Enable-WindowsFeature Microsoft-Hyper-V
    Enable-WindowsFeature VirtualMachinePlatform
    Enable-WindowsFeature Microsoft-Windows-Subsystem-Linux
}

#endregion

#region Main

Write-Host "dotfiles system configuration"

try {
    Install-SSH
    Install-Virtualization
}
catch {
    Write-Warning "Exception:"
    Write-Warning "Exception Type:    $($_.Exception.GetType().FullName)"
    Write-Warning "Exception Message: $($_.Exception.Message)"
    Write-Warning "Exception Stack:   $($_.Exception.StackTrace)"
}

Write-Host "dotfiles system configuration complete"

#endregion
