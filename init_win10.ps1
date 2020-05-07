<#
.SYNOPSIS
    Windows software install
.DESCRIPTION
    Install windows software packages
#>
[cmdletbinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# TODO: Check that running in powershell *not* powershell core
if ($PSVersionTable.PSEdition -ne "Desktop") {
    $relaunchArgs = "& '" + $MyInvocation.MyCommand.Definition + "'"
    Start-Process powershell -ArgumentList $relaunchArgs -NoNewWindow
    Break
}

# Run as administrator
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $relaunchArgs = "& '" + $MyInvocation.MyCommand.Definition + "'"
    Start-Process powershell -Verb RunAs -ArgumentList $relaunchArgs
    Break
}

# Use TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Dotfiles enlistment
$dotfiles = Join-Path -Path $env:USERPROFILE -ChildPath .config\dotfiles

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
    New-ItemProperty -Path HKLM:\SOFTWARE\OpenSSH -Name DefaultShell -Value $env:ProgramFiles\PowerShell\7\pwsh.exe
}

function Install-Virtualization() {
    Enable-WindowsOptionalFeature -Online -FeatureName Containers-DisposableClientVM -All
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -All
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -All
}

function Install-Packages() {
    # Read package catalog
    $activity = "Install packages"
    $pspackages = Join-Path -Path $dotfiles -ChildPath win10_packages.json
    Write-Progress -Activity $activity -CurrentOperation "Reading $pspackages" -Id 1
    $packages = Get-Content -Path $pspackages | ConvertFrom-Json
    $installed = Get-Package -ProviderName msi, programs

    $idx = 0
    foreach ($p in $packages) {
        $idx++
        $useSudo = if (Get-Member -Name sudo -InputObject $p) { $p.sudo } else { $false }
        $args = if (Get-Member -Name args -InputObject $p) { $p.args } else { " " }
        $completed = [math]::Round((($idx - 1) / $packages.Count) * 100)

        if ($installed | Where-Object { $_.CanonicalID -eq $p.id }) {
            Write-Progress -Activity $activity -CurrentOperation "$($p.id) installed" -Id 1 -Status "$completed% complete" -PercentComplete $completed
            Write-Host "$($p.id) installed"
            continue
        }

        try {
            # Download file
            Write-Progress -Activity $activity -CurrentOperation "Downloading $($p.url)" -Id 1 -Status "$($p.id)" -PercentComplete $completed
            $target = Join-Path -Path $env:TEMP -ChildPath (Split-Path -Path $p.url -Leaf)
            $wc = New-Object System.Net.WebClient
            $wc.DownloadFile($p.url, $target)

            # Execute installer
            Write-Progress -Activity $activity -CurrentOperation "Installing $(Split-Path -Path $target -Leaf)" -Id 1 -Status "$($p.id)" -PercentComplete $completed
            $verb = if ($useSudo) { 'RunAs' } else { 'Open' }
            $exe = switch ((Get-Item -Path $target).Extension) {
                .exe { $target }
                .msi { $args += ('/I', $target); 'msiexec.exe' }
                Default { throw "Unknown file type for $target" }
            }
            Start-Process -FilePath $exe -ArgumentList $Args -Wait -Verb $verb
        }
        catch {
            Write-Warning "Unable to install $($p.url)"
            Write-Warning "[$($_.Exception.GetType().FullName)] $($_.Exception.Message)"
        }
        finally {
            if (Test-Path -Path $target) { Remove-Item -Path $target -Force }
        }
    }
}

Install-SSH
Install-Virtualization
Install-Packages
