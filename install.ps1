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

# Git
$gitCmd = Join-Path -Path $env:ProgramFiles -ChildPath "Git\cmd\git.exe"

#endregion

#region Bootstrap

function Install-Git() {
    if (!(Test-Path -Path $gitCmd)) {
        try {
            $gitUri = 'https://github.com/git-for-windows/git/releases/download/v2.26.2.windows.1/Git-2.26.2-64-bit.exe'
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
        Write-Host "Set GIT_SSH environment variable"
        [System.Environment]::SetEnvironmentVariable("GIT_SSH", (Get-Command ssh.exe).Path, [System.EnvironmentVariableTarget]::User)
    }
}

function Install-Dotfiles() {
    # Clone dotfiles
    if (!(Test-Path -Path $DotfileDest)) {
        Write-Host "Clone dotfiles"
        $dotfileParent = Split-Path -Path $DotfileDest
        if (!(Test-Path -Path $dotfileParent)) { New-Item -Path $dotfileParent -ItemType Directory -Force }
        Start-Process -FilePath $gitCmd -ArgumentList "clone https://github.com/ascarter/dotfiles.git $DotfileDest" -Wait -NoNewWindow
    }

    # Set DOTFILES environment variable
    if ($null -eq [System.Environment]::GetEnvironmentVariable("DOTFILES", "User")) {
        Write-Host "Set DOTFILES enviornment variable"
        [System.Environment]::SetEnvironmentVariable("DOTFILES", $DotfileDest, [System.EnvironmentVariableTarget]::User)
    }
}

function Install-Profile() {
    # PowerShell profile
    if (!(Test-Path $PROFILE)) {
        Write-Host "Install PowerShell profile"
        New-Item -Path $PROFILE -ItemType File -Force
        Set-Content -Path $PROFILE -Value ". $DotfileDest\powershell\profile.ps1"
    }
}

function Install_WindowsTerminalProfile() {
    # Windows terminal profile
    $wintermSrc = Join-Path -Path $DotfileDest -ChildPath windows_terminal_settings.json
    $wintermID = "Microsoft.WindowsTerminal_8wekyb3d8bbwe"
    $wintermTarget = Join-Path -Path $env:LocalAppData -ChildPath Packages\$wintermID\LocalState\settings.json
    if (!(Test-Path -Path $wintermTarget)) {
        Write-Host "Install Windows Terminal settings"
        Copy-Item -Path $wintermSrc -Destination $wintermTarget -Force
    }
}

function Install-Vimrc() {
    # Vim profile
    $vimrc = Join-Path -Path $env:USERPROFILE -ChildPath _vimrc
    if (!(Test-Path -Path $vimrc)) {
        Write-Host "Install vimrc"
        New-Item -Path $vimrc -ItemType File -Force
        Set-Content -Path $vimrc -Value "source $DotfileDest/conf/vimrc"
    }
}

function Install-SSHKeys() {
    $sshDir = Join-Path -Path $env:USERPROFILE -ChildPath .ssh
    $sshKeys = 'ed25519', 'rsa'
    foreach ($key in $sshKeys) {
        $keyFile = Join-Path -Path $sshDir -ChildPath "id_$key"
        if (!(Test-Path $keyFile)) {
            Write-Host "Generating SSH key $key"
            $comment = "$env:USERNAME@$env:COMPUTERNAME"
            ssh-keygen -t $key -C "$env:USERNAME@$env:COMPUTERNAME"
            ssh-add $key
        }
    }
}

#endregion

Write-Output "Install dotfiles"

Install-Git
Install-Dotfiles
Install-Profile
Install-Vimrc
Install-SSHKeys

Write-Output "Dotfiles install complete"
