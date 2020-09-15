<#
.SYNOPSIS
    Windows system configuration
.DESCRIPTION
    Configure Windows features and install windows software packages
#>
[cmdletbinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Check running in Windows PowerShell not Powershell Core
if ($PSVersionTable.PSEdition -ne "Desktop") {
    $relaunchArgs = "& '" + $MyInvocation.MyCommand.Definition + "'"
    Start-Process powershell -ArgumentList $relaunchArgs -NoNewWindow
    Break
}

# Run as administrator
If (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $relaunchArgs = "& '" + $MyInvocation.MyCommand.Definition + "'"
    Start-Process powershell -Verb RunAs -ArgumentList $relaunchArgs
    Break
}

# Use TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#region Helpers

function Install-WindowsOptionalFeature([string]$FeatureName) {
    if ((Get-WindowsOptionalFeature -Online -FeatureName $FeatureName).State -eq "Disabled") {
        Write-Output "Enable $FeatureName"
        Enable-WindowsOptionalFeature -Online -FeatureName $FeatureName -All
    }
}

function Install-WindowsCapability([string]$Capability) {
    if ((Get-WindowsCapability -Online -Name "$Capability*").State -eq "NotPresent") {
        Write-Output "Add Windows Capability $Capability"
        Add-WindowsCapability -Online -Name $Capability
    }
}

#endregion

#region System Configuration

function Install-SSH() {
    # Install OpenSSH
    # https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse
    Install-WindowsCapability OpenSSH.Client
    Install-WindowsCapability OpenSSH.Server

    # Configure ssh server
    Set-Service -Name sshd -StartupType 'Automatic'
    Start-Service sshd

    # Configure ssh-agent
    Set-Service -Name ssh-agent -StartupType 'Automatic'
    Start-Service ssh-agent

    # Add firewall rule
    if (-not ((Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP").Enabled -eq $true)) {
        Write-Warning "Missing OpenSSH Server inbound firewall rule"
    }

    # Configure default shell
    Set-ItemProperty -Path HKLM:\SOFTWARE\OpenSSH -Name DefaultShell -Value $env:ProgramFiles\PowerShell\7\pwsh.exe
}

function Install-Virtualization() {
    Install-WindowsOptionalFeature Containers-DisposableClientVM
    Install-WindowsOptionalFeature Microsoft-Hyper-V
    Install-WindowsOptionalFeature VirtualMachinePlatform
    Install-WindowsOptionalFeature Microsoft-Windows-Subsystem-Linux
}

function Install-WindowsPackageManager() {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        # Download winget package
        try {
            $uri = 'https://github.com/microsoft/winget-cli/releases/download/v0.1.4331-preview/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.appxbundle'
            $bundle = Split-Path $gitURI -Leaf
            $target = Join-Path -Path $env:TEMP -ChildPath $bundle
            Write-Output "Installing Windows Package Manager $bundle"
            $wc = New-Object System.Net.WebClient
            $wc.DownloadFile($uri, $target)
            Start-Process -FilePath $target -Wait -NoNewWindow
        }
        finally {
            if (Test-Path $target) { Remove-Item -Path $target }
        }
    }
}

function Install-Packages() {
    # Install necessary base packages via Windows Package Manager
    $packages = @{
        git       = 'Git.Git'
        'git-lfs' = 'GitHub.GitLFS'
        gh        = 'GitHub.cli'
        pwsh      = 'Microsoft.PowerShell'
        code      = 'Microsoft.VisualStudioCode'
        wt        = 'Microsoft.WindowsTerminal'
        vim       = 'vim.vim'
        docker    = 'Docker.DockerDesktop'
    }
    $packages.GetEnumerator() | ForEach-Object {
        $app = $($_.key)
        $id = $($_.value)
        if (-not (Get-Command $app -ErrorAction SilentlyContinue)) {
            Write-Output "Install $id"
            winget install --id=$id --exact --interactive
        }
    }
}

Write-Output "Configure Windows 10"
Install-SSH
Install-Virtualization
Install-WindowsPackageManager
Install-Packages
Write-Output "Done."
