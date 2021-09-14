<#
.SYNOPSIS
    Windows developer configuration
.DESCRIPTION
    Configure Windows for development
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

#region Tasks

function Install-Bootstrap {
    <#
    .SYNOPSIS
    Bootstrap dotfiles
    #>
    [CmdletBinding()]
    param (
        # Dotfiles path
        [string]$Path = $Env:DOTFILES,
        
        # Replace existing configuration
        [switch]$Force = $false
    )
    Write-Output "Bootstrap dotfiles"
    Write-Verbose "Install profile to $Path"
    Install-Profile -Path $Path -Force $Force
    Write-Verbose "Install vimrc"
    Install-Vimrc -Force $Force
    Write-Verbose "Install bin"
    Install-Bin -Force $Force
    Write-Output "Boostrap complete"
}

function Update-DevTools {
    <#
    .SYNOPSIS
        Update/install developer tools
    #>
    [CmdletBinding()]
    param(
        # Replace existing configuration
        [switch]$Force = $false
    )

    Write-Host "Updating developer system settings"

    Write-Host "Set PowerShell profile"
    Install-Profile -Force $force

    Write-Host "Set vimrc"
    Install-Vimrc -Force $force

    Write-Host "Update git configuration"
    Write-GitConfig

    Write-Host "Update PowerShell modules"
    Update-PowerShellModules -Force $Force

    Write-Host "Enable Hyper-V"
    Invoke-Administrator -Command { Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All }

    Write-Host "Enable WSL"
    Invoke-Administrator -Command { wsl --update; wsl --install --distribution Ubuntu }

    Write-Host "Enable hypervisor platform (for Android emulator and QEMU)"
    Invoke-Administrator -Command { Enable-WindowsOptionalFeature -Online -FeatureName HypervisorPlatform -All }

    Write-Host "Recommend reboot to enable all services"
}

#endregion

#region Helpers

function Install-Zip {
    <#
    .SYNOPSIS
        Download and extract zip archive to target location 
    .EXAMPLE
        PS C:\> Install-Zip -Uri https://example.com/myapp.zip -Dest C;\bin
        Downloads myapp.zip from URI and extracts to C:\bin
    .PARAMETER Uri
    URI of zip file
    .PARAMETER Dest
    Destination path
    #>
    [CmdletBinding()]
    param (
        [string]$Uri,
        [string]$Dest
    )
    process {
        try {
            # Create a random file in temp
            $zipfile = [System.IO.Path]::GetRandomFileName()
            $target = Join-Path -Path $env:TEMP -ChildPath $zipfile

            # Download to temp
            $wc = New-Object System.Net.WebClient
            $wc.DownloadFile($uri, $target)

            # Unzip
            Expand-Archive -Path $target -DestinationPath $Dest -Force
        }
        finally {
            if (Test-Path $target) { Remove-Item -Path $target }
        }
    }
}

#endregion

#region Configuration

function Install-Profile {
    [CmdletBinding()]
    param (
        # Path of source profile
        [string]$Path = (Join-Path $Env:DOTFILES -ChildPath powershell\profile.ps1),
        
        # Replace existing profile
        [switch]$Force = $false
    )
    if ($Force) { Remove-Item -Path $PROFILE -Force }
    if (-not (Test-Path $PROFILE)) {
        Write-Output "Install PowerShell profile"
        New-Item -Path $PROFILE -ItemType File -Force
        Set-Content -Path $PROFILE -Value ". $Path"
    }
}

function Install-Vimrc {
    [CmdletBinding()]
    param (
        # Path of source vimrc
        [string]$Path = (Join-Path $Env:DOTFILES -ChildPath conf\vimrc),

        # Replace existing vimrc
        [switch]$Force = $false
    )
    # Vim profile
    $vimrc = Join-Path -Path $env:USERPROFILE -ChildPath _vimrc
    if ($Force) { Remove-Item -Path $vimrc -Force }
    if (-not (Test-Path -Path $vimrc)) {
        Write-Output "Install vimrc"
        New-Item -Path $vimrc -ItemType File -Force
        Set-Content -Path $vimrc -Value "source $Path"
    }
}

#endregion

#region Powershell modules

function Update-PowerShellModules {
    param(
        # Replace existing modules
        [switch]$Force = $false
    )
    foreach ($m in @(
            'Microsoft.PowerShell.ConsoleGuiTools',
            'posh-git',
            'WslInterop'
        )) {
        try {
            if(-not (Get-Module -Name $m -ListAvailable)) { throw "Module $m is not available" }

            if ($Force -and (Get-Module -Name $m)) { 
                Write-Host "Removing $m"
                Uninstall-Module -Name $m -Force
            }
            
            if (-not (Get-Module -Name $m)) {
                Write-Host "Installing $m"
                Install-Module -Name $m -Scope CurrentUser -Force -AllowClobber -AllowPrerelease -AcceptLicense
            }
            else {
                Write-Host "Updating $m"
                Update-Module -Name $m -Scope CurrentUser -Force -AllowPrerelease -AcceptLicense
            }
        }
        catch {
            Write-Warning $_
        }
    }
}

#endregion

#region System

function Install-SSH() {
    # Install OpenSSH
    # https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse
    Install-WindowsCapability OpenSSH.Client~~~~0.0.1.0
    Install-WindowsCapability OpenSSH.Server~~~~0.0.1.0

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

#endregion

#region Tools

function Install-Bin {
    <#
    .SYNOPSIS
    Create system root bin for adding tools (like /usr/local/bin on Unix)
    #>
    param(
        # Replace existing bin directory
        [switch]$Force = $false
    )

    $usrbin = Join-Path -Path $Env:SystemDrive -ChildPath bin
    if ($Force -and (Test-Path -Path $usrbin)) {
        Write-Host "Removing $usrbin"
        Remove-Item -Path $usrbin -Force
    }
    
    if (!(Test-Path -Path $usrbin)) {
        Write-Output "Creating $usrbin"
        New-Item -Path $usrbin -ItemType Directory
    }

    # Add to path so WSL can see it
    Update-Path @($usrbin) -SetEnv
}

function Install-Sysinternals {
    <#
    .SYNOPSIS
    Install sysinternals suite and adjusts path
    #>

    $sysinternals = Join-Path -Path $Env:SystemDrive -ChildPath sysinternals
    $uri = 'https://download.sysinternals.com/files/SysinternalsSuite.zip'

    # Remove old sysinternals
    if (Test-Path -Path $sysinternals) { Remove-Item -Path $sysinternals }

    Write-Output "Updating sysinternals"
    Install-Zip -Uri $uri -Dest $sysinternals

    # Add to system path
    Update-Path @($sysinternals) -SetEnv
}

function Install-Speedtest() {
    <#
    .SYNOPSIS
    Install speedtest cli
    #>
    $bin = Join-Path -Path $Env:SystemDrive -ChildPath bin
    $uri = 'https://bintray.com/ookla/download/download_file?file_path=ookla-speedtest-1.0.0-win64.zip'
    Write-Output "Updating speedtest"
    Install-Zip -Uri $uri -Dest $bin
}

#endregion
