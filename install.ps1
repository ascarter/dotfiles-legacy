<#
.SYNOPSIS
    Dotfiles Install script for Windows 10
.DESCRIPTION
	Install user profile and configuration
#>
[cmdletbinding()]
param(
    [Parameter(HelpMessage = "Dotfiles destination")]
    [string]
    $DotfileDest = (Join-Path -Path $env:USERPROFILE -ChildPath ".config\dotfiles")
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

#region Setup

# Use TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Check that running PowerShell Core
if ($PSVersionTable.PSEdition -ne "Core") {
    throw "Run in PowerShell Core"
}

#endregion

#region Bootstrap

function Install-Git() {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        throw "Git not installed"
    }

    # Set Git SSH client
    if ($null -eq [System.Environment]::GetEnvironmentVariable("GIT_SSH", [System.EnvironmentVariableTarget]::User)) {
        Write-Output "Set GIT_SSH environment variable"
        $sshPath = (Get-Command ssh.exe).Path
        [System.Environment]::SetEnvironmentVariable("GIT_SSH", $sshPath, [System.EnvironmentVariableTarget]::User)
    }
}

function Install-Dotfiles() {
    # Clone dotfiles
    if (-not (Test-Path -Path $DotfileDest)) {
        Write-Output "Clone dotfiles"
        $dotfileParent = Split-Path -Path $DotfileDest
        if (-not (Test-Path -Path $dotfileParent)) {
            New-Item -Path $dotfileParent -ItemType Directory -Force
        }
        Start-Process -FilePath (Get-Command git.exe) -ArgumentList "clone https://github.com/ascarter/dotfiles.git $DotfileDest" -Wait -NoNewWindow
    }

    # Set DOTFILES environment variable
    if ($null -eq [System.Environment]::GetEnvironmentVariable("DOTFILES", [System.EnvironmentVariableTarget]::User)) {
        Write-Output "Set DOTFILES environment variable"
        [System.Environment]::SetEnvironmentVariable("DOTFILES", $DotfileDest, [System.EnvironmentVariableTarget]::User)
    }
}

function Install-Profile() {
    # PowerShell profile
    if (-not (Test-Path $PROFILE)) {
        Write-Output "Install PowerShell profile"
        New-Item -Path $PROFILE -ItemType File -Force
        Set-Content -Path $PROFILE -Value ". $DotfileDest\powershell\profile.ps1"
    }
}

function Install_WindowsTerminalProfile() {
    # Windows terminal profile
    $wintermSrc = Join-Path -Path $DotfileDest -ChildPath windows_terminal_settings.json
    $wintermID = "Microsoft.WindowsTerminal_8wekyb3d8bbwe"
    $wintermTarget = Join-Path -Path $env:LocalAppData -ChildPath Packages\$wintermID\LocalState\settings.json
    if (-not (Test-Path -Path $wintermTarget)) {
        Write-Output "Install Windows Terminal settings"
        Copy-Item -Path $wintermSrc -Destination $wintermTarget -Force
    }
}

function Install-Vimrc() {
    # Vim profile
    $vimrc = Join-Path -Path $env:USERPROFILE -ChildPath _vimrc
    if (-not (Test-Path -Path $vimrc)) {
        Write-Output "Install vimrc"
        New-Item -Path $vimrc -ItemType File -Force
        Set-Content -Path $vimrc -Value "source $DotfileDest/conf/vimrc"
    }
}

function Install-SSHConfig() {
    $source = Join-Path $DotfileDest -ChildPath windows\sshd_config
    $target = Join-Path $env:ProgramData -ChildPath sshd_config
    Copy-Item -Path $source -Destination $target -Force
}

function Install-SSHKeys() {
    $sshDir = Join-Path -Path $env:USERPROFILE -ChildPath .ssh
    $sshKeys = 'ed25519', 'rsa'
    foreach ($key in $sshKeys) {
        $keyFile = Join-Path -Path $sshDir -ChildPath "id_$key"
        if (-not (Test-Path $keyFile)) {
            Write-Output "Generating SSH key $key"
            ssh-keygen -t $key -C "$env:USERNAME@$env:COMPUTERNAME"
            ssh-add $key
        }
    }

    # Create authorized_keys
    $authorizedKeys = Join-Path -Path $sshDir -ChildPath authorized_keys
    if (-not (Test-Path $authorizedKeys)) {
        New-Item -Path $authorizedKeys -ItemType File
    }

    # Disable inheritance and preserve access rules 
    $acl = Get-Acl -Path $authorizedKeys
    $acl.SetAccessRuleProtection($true, $true)
    Set-Acl -Path $authorizedKeys -AclObject $acl

    # Remove administrators rule
    $identity = New-Object System.Security.Principal.NTAccount('BUILTIN\Administrators')
    $acl = Get-Acl -Path $authorizedKeys
    $rule = $acl.Access | Where-Object {$_.IdentityReference.Equals($identity)}
    if ($rule) {
        $acl.RemoveAccessRule($rule)
        Set-Acl -Path $authorizedKeys -AclObject $acl
    }
}

# Install-Bin creates a system root bin for adding tools. Similar to /usr/local/bin on Unix
function Install-Bin() {
    $usrbin = Join-Path -Path $Env:SystemDrive -ChildPath bin
    if (!(Test-Path -Path $usrbin)) {
        Write-Output "Creating $usrbin"
        New-Item -Path $usrbin -ItemType Directory
    }

    # Add to path so WSL can see it
    Update-Path @($usrbin)
}

#endregion

#region Helpers

function Update-Path([string[]]$paths) {
    $parts = [System.Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::User) -Split ";"
    foreach ($p in $paths) {
        if ((Test-Path -Path $p) -and ($parts -NotContains $p)) {
            $parts += $p
        }
    }
    [System.Environment]::SetEnvironmentVariable("PATH", $parts -Join ";", [System.EnvironmentVariableTarget]::User)
}

#endregion

Write-Output "Install dotfiles"
Install-Git
Install-Dotfiles
Install-Profile
Install-Vimrc
Install-SSHConfig
Install-SSHKeys
Install-Bin
Write-Output "dotfiles install complete"
Write-Output "Reload session to apply configuration"
