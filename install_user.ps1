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

# if (!(Get-Module -Name WindowsCompatibility)) { Install-Module -Name WindowsCompatibility -Scope CurrentUser }
# Import-Module -Name WindowsCompatibility

# Use TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Dotfiles enlistment
$dotfiles = Join-Path -Path $env:USERPROFILE -ChildPath .config\dotfiles

#region Helpers

function Get-ProfilePath() {
    if ($PSVersionTable.PSEdition -eq 'Core') {
        $profile.CurrentUserAllHosts
    }
    else {
        pwsh -Command { $profile.CurrentUserAllHosts }
    }
}

function Get-InternetPackage([string]$Uri) {
    $pkgCache = Join-Path -Path $env:USERPROFILE -ChildPath .config\cache\dotfiles
    $pkg = Split-Path -Path $Uri -Leaf
    $target = Join-Path -Path $pkgCache -ChildPath $pkg
    if (!(Test-Path -Path $target)) {
        $wc = New-Object [System.Net.WebClient]
        $wc.DownloadFile($Uri, $target)
    }
    Get-Item -Path $target
}

function Get-InstalledPackages() {
    powershell.exe -C { Get-Package -ProviderName msi, programs }
    # Invoke-WinCommand { Get-Package }
}

function Invoke-MSI {
    Param(
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        [Object]
        $InputObject

    )

    $args = "/I $InputObject"
    Start-Process -FilePath msiexec.exe -ArgumentList $args -Wait -NoNewWindow
}

function Invoke-Installer {
    Param(
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        [Object]
        $InputObject,

        [Parameter()]
        [bool]
        $UseSudo = $false
    )

    $exe = Split-Path -Path $InputObject -Leaf
    $verb = if ($UseSudo) { 'RunAs' } else { 'Open' }

    Write-Host "Installing $exe"
    Start-Process -FilePath $InputObject -Wait -Verb $verb
}

#endregion

#region Installers

function Install-Packages() {
    # Read package catalog
    $activity = "Install packages"
    $pspackages = Join-Path -Path $dotfiles -ChildPath pspackages.json
    Write-Progress -Activity $activity -CurrentOperation "Reading $pspackages" -Id 1
    $packages = Get-Content -Path $pspackages | ConvertFrom-Json
    $installed = Get-InstalledPackages

    $idx = 0
    foreach ($p in $packages) {
        $idx++
        $useSudo = if (Get-Member -Name sudo -InputObject $p) { $p.sudo } else { $false }
        $completed = (($idx - 1) / $packages.Count) * 100

        if ($installed | Where-Object { $_.CanonicalID -eq $p.id }) {
            Write-Progress -Activity $activity -CurrentOperation "$($p.id) installed" -Id 1 -Status "$completed% complete" -PercentComplete $completed
            continue
        }

        try {
            Write-Progress -Activity $activity -CurrentOperation "Downloading $($p.url)" -Id 1 -Status "$completed% complete" -PercentComplete $completed
            $file = Get-InternetPackage $p.url

            if (!$file) {
                Write-Warning "Unable to download $($p.id)"
                continue
            }

            Write-Progress -Activity $activity -CurrentOperation "Installing $file" -Id 1 -Status "$completed% complete" -PercentComplete $completed
            switch ($file.Extension) {
                .exe { Invoke-Installer $file $useSudo }
                .msi { Invoke-MSI $file }
                Default { Write-Warning "Unknown file type for $file" }
            }
        }
        catch {
            Write-Warning "Unable to install $($p.url)"
            Write-Warning "[$($_.Exception.GetType().FullName)] $($_.Exception.Message)"
        }
    }
}

function Install-SSHKeys() {
    # Create SSH key if not present
    $sshKeyfile = Join-Path -Path $env:USERPROFILE -ChildPath '.ssh\id_rsa'
    if (!(Test-Path $sshKeyFile)) {
        Write-Host "Generating SSH user key"
        $githubEmail = Read-Host -Prompt "Enter GitHub email address"
        ssh-keygen -t rsa -b 4096 -C "$githubEmail"
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

function Install-PSModules() {
    $psblock = {
        # PowerShellGet
        if (!(Get-Module -Name PowerShellGet -All)) {
            Install-Module -Name PowerShellGet -Scope CurrentUser -Force -AllowClobber
        }


        if (!(Get-Module -Name Microsoft.PowerShell.GraphicalTools -All)) {
            Install-Module Microsoft.PowerShell.GraphicalTools
        }

        # posh-git
        if (!(Get-Module -Name posh-git -All)) {
            Install-Module -Name posh-git -Scope CurrentUser -AllowPrerelease -Force
        }
    }

    # Execute in PowerShell Core
    Start-Process -FilePath pwsh.exe -ArgumentList "-Command $psblock" -Wait -NoNewWindow
}

function Install-Symlinks() {
    # PowerShell Core profile
    $profilePath = Get-ProfilePath
    if (!(Test-Path -Path $profilePath)) {
        Write-Host "Linking profile"
        $target = Join-Path -Path $dotfiles -ChildPath profile.ps1
        New-Item -ItemType SymbolicLink -Path $profilePath -Target $target
    }

    # Windows Terminal
    $wintermProfile = Join-Path -Path $env:LocalAppData -ChildPath Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\profiles.json
    if (!(Test-Path -Path $wintermProfile)) {
        Write-Host "Linking Windows Terminal profiles"
        $target = Join-Path -Path $dotfiles -ChildPath windows_terminal_profiles.json
        New-Item -ItemType SymbolicLink -Path $wintermProfile -Target $target
    }

    # Vim
    $vimrc = Join-Path -Path $env:USERPROFILE -ChildPath _vimrc
    if (!(Test-Path -Path $vimrc)) {
        Write-Host "Linking vimrc"
        $target = Join-Path -Path $dotfiles -ChildPath vimrc
        New-Item -ItemType SymbolicLink -Path $vimrc -Target $target
    }
}

function Update-Dotfiles() {
    # TODO: change dotfiles from https -> ssh
}

#endregion

#region Main

Write-Host "dotfiles configure user environment"

# Install-PSModules
Install-Packages
Install-Symlinks
Install-SSHKeys
Update-Dotfiles

Write-Host "User environment configured"

#endregion
