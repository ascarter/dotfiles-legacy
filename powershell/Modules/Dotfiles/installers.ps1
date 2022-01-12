<#
.SYNOPSIS
    Windows developer configuration
.DESCRIPTION
    Configure Windows for development
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

#region Tasks

function Install-Bootstrap {
    <#
        .SYNOPSIS
            Bootstrap dotfiles
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # Dotfiles path
        [string]$Path = $Env:DOTFILES,

        # Replace existing configuration
        [switch]$Force
    )

    Write-Output 'Bootstrap dotfiles'

    Write-Verbose "Install profile to $Path"
    Install-Profile -Path $Path -Force:$Force

    Write-Verbose 'Install vimrc'
    Install-Vimrc -Path $Path -Force:$Force

    Write-Verbose 'Install bin'
    Install-Bin

    Write-Output 'Boostrap complete'
}

function Update-DevTools {
    <#
    .SYNOPSIS
        Update/install developer tools
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # Replace existing configuration
        [switch]$Force
    )

    Write-Output 'Updating developer system settings'

    Install-Bootstrap -Force:$Force

    Write-Output 'Update git configuration'
    Write-GitConfig

    Write-Output 'Update PowerShell modules'
    Update-PowerShellModules -Force:$Force

    Write-Output 'Enable Hyper-V'
    Invoke-Administrator -Command { Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All }

    Write-Output 'Enable WSL'
    Invoke-Administrator -Command { wsl --update; wsl --install --distribution Ubuntu }

    Write-Output 'Enable hypervisor platform (for Android emulator and QEMU)'
    Invoke-Administrator -Command { Enable-WindowsOptionalFeature -Online -FeatureName HypervisorPlatform -All }

    Write-Output 'Recommend reboot to enable all services'
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
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # Path of dotfiles
        [string]$Path = $Env:DOTFILES,

        [string]$PSProfile = $PROFILE.CurrentUserAllHosts,

        # Replace existing profile
        [switch]$Force
    )

    if ($Force -and (Test-Path $PSProfile)) {
        Remove-Item -Path $PSProfile -Force
    }

    if (-not (Test-Path $PSProfile)) {
        Write-Output 'Install PowerShell profile'
        New-Item -Path $PSProfile -ItemType File -Force
        $dotfilesProfile = (Join-Path $Path -ChildPath powershell\profile.ps1)
        Set-Content -Path $PSProfile -Value ". $dotfilesProfile"
    }
}

function Install-Vimrc {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # Path of dotfiles
        [string]$Path = $Env:DOTFILES,

        # Replace existing vimrc
        [switch]$Force
    )
    # Vim profile
    $vimrc = Join-Path -Path $env:USERPROFILE -ChildPath _vimrc
    if ($Force) { Remove-Item -Path $vimrc -Force }
    if (-not (Test-Path -Path $vimrc)) {
        Write-Output 'Install vimrc'
        New-Item -Path $vimrc -ItemType File -Force
        $dotfilesVimrc = (Join-Path $Path -ChildPath conf\vimrc)
        Set-Content -Path $vimrc -Value "source $dotfilesVimrc"
    }
}

#endregion

#region Powershell modules

function Update-PowerShellModules {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # Replace existing modules
        [switch]$Force
    )
    foreach ($m in @(
            'Microsoft.PowerShell.ConsoleGuiTools',
            'posh-git',
            'PSScriptAnalyzer',
            'WslInterop'
        )) {
        try {
            if (-not (Find-Module -Name $m -ErrorAction SilentlyContinue)) { throw "Module $m is not available" }

            if ($Force -and (Get-Module -Name $m)) {
                Write-Output "Removing $m"
                Uninstall-Module -Name $m -Force
            }

            if (-not (Get-Module -Name $m)) {
                Write-Output "Installing $m"
                Install-Module -Name $m -Scope CurrentUser -Force -AllowClobber -AllowPrerelease -AcceptLicense
            }
            else {
                Write-Output "Updating $m"
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
    Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

    # Start ssh services
    Start-Service sshd
    Start-Service ssh-agent

    # Configure ssh services to startup automatically
    Set-Service -Name sshd -StartupType 'Automatic'
    Set-Service -Name ssh-agent -StartupType 'Automatic'

    # Confirm the Firewall rule is configured. It should be created automatically by setup. Run the following to verify
    if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
        Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
        New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
    } else {
        Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists."
    }

    # Configure default shell
    Set-ItemProperty -Path HKLM:\SOFTWARE\OpenSSH -Name DefaultShell -Value $env:ProgramFiles\PowerShell\7\pwsh.exe
}

function Install-Remoting() {
    <#
    .SYNOPSIS
        Enable WS-Man remoting
    #>
    Write-Output 'Enable PowerShell Remoting'
    Invoke-Administrator -Core -Command {
        Install-PowerShellRemoting.ps1
        Enable-PSRemoting
    }
}

#endregion

#region Tools

function Install-Bin {
    <#
    .SYNOPSIS
        Create system root bin for adding tools (like /usr/local/bin on Unix)
    #>
    param()

    $usrbin = Join-Path -Path $Env:SystemDrive -ChildPath bin
    if (!(Test-Path -Path $usrbin)) {
        Write-Output "Creating $usrbin"
        New-Item -Path $usrbin -ItemType Directory
    }

    # Add to path so WSL can see it
    Update-Path @($usrbin) -SetEnv
}

function Install-Speedtest() {
    <#
    .SYNOPSIS
        Install speedtest cli
    #>
    $bin = Join-Path -Path $Env:SystemDrive -ChildPath bin
    $uri = 'https://bintray.com/ookla/download/download_file?file_path=ookla-speedtest-1.0.0-win64.zip'
    Write-Output 'Updating speedtest'
    Install-Zip -Uri $uri -Dest $bin
}

#endregion
