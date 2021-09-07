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

$DefaultDotfilesPath = Join-Path -Path $env:USERPROFILE -ChildPath ".config\dotfiles"

#region Helpers

function Install-Bootstrap {
    <#
    .SYNOPSIS
    Bootstrap dotfiles
    #>
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage = "Dotfiles path")]
        [string]
        $Path = $DefaultDotfilesPath
    )
    Write-Output "Bootstrap dotfiles"
    Write-Verbose "Install profile to $Path"
    Install-Profile -Path $Path
    Write-Verbose "Install vimrc"
    Install-Vimrc
    Write-Verbose "Install bin"
    Install-Bin
    Write-Output "Boostrap complete"
}

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
        [Parameter()]
        [string]$Uri,

        [Parameter()]
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

#region Configuration

# TODO: Support -Force
function Install-Profile {
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage = "Dotfiles path")]
        [string]
        $Path = $DefaultDotfilesPath
    )
    if (-not (Test-Path $PROFILE)) {
        Write-Output "Install PowerShell profile"
        New-Item -Path $PROFILE -ItemType File -Force
        $dfprofile = Join-Path $Path -ChildPath "PowerShell\profile.ps1"
        Set-Content -Path $PROFILE -Value ". $dfprofile"
    }
}

# TODO: Support -Force
function Install-Vimrc {
    # Vim profile
    $vimrc = Join-Path -Path $env:USERPROFILE -ChildPath _vimrc
    if (-not (Test-Path -Path $vimrc)) {
        Write-Output "Install vimrc"
        New-Item -Path $vimrc -ItemType File -Force
        Set-Content -Path $vimrc -Value "source $DotfileDest/conf/vimrc"
    }
}

#endregion

#region Powershell modules

function Update-PowerShellModules {
    foreach ($m in @(
            'Microsoft.PowerShell.GraphicalTools',
            'Microsoft.PowerShell.ConsoleGuiTools',
            'posh-git',
            'WslInterop'
        )) {
        if (!(Get-Module -Name $m -ListAvailable)) {
            Install-Module -Name $m -Scope CurrentUser -Force -AllowClobber -AllowPrerelease -AcceptLicense
        } else {
            Update-Module -Name $m -Force
        }
    }

    Update-Help -UICulture en-US
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

function Install-Virtualization() {
    # Windows Sandbox
    Install-WindowsOptionalFeature Containers-DisposableClientVM

    # Hyper-V
    Install-WindowsOptionalFeature Microsoft-Hyper-V
    Install-WindowsOptionalFeature VirtualMachinePlatform

    # WSL
    Install-WindowsOptionalFeature Microsoft-Windows-Subsystem-Linux
}

#endregion

#region Tools

function Install-Bin {
    <#
    .SYNOPSIS
    Create system root bin for adding tools (like /usr/local/bin on Unix)
    #>
    $usrbin = Join-Path -Path $Env:SystemDrive -ChildPath bin
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
