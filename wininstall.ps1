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

# Use TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Dotfiles enlistment
$dotfiles = Join-Path -Path $env:USERPROFILE -ChildPath .config\dotfiles

function Install-PSModules() {
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

function Install-Packages() {
    # Read package catalog
    $activity = "Install packages"
    $pspackages = Join-Path -Path $dotfiles -ChildPath pspackages.json
    Write-Progress -Activity $activity -CurrentOperation "Reading $pspackages" -Id 1
    $packages = Get-Content -Path $pspackages | ConvertFrom-Json
    $installed = Get-Package -ProviderName msi, programs

    $idx = 0
    foreach ($p in $packages) {
        $idx++
        $useSudo = if (Get-Member -Name sudo -InputObject $p) { $p.sudo } else { $false }
        $args = if (Get-Member -Name args -InputObject $p) { $p.args } else { $null }
        $completed = [math]::Round((($idx - 1) / $packages.Count) * 100)

        if ($installed | Where-Object { $_.CanonicalID -eq $p.id }) {
            Write-Progress -Activity $activity -CurrentOperation "$($p.id) installed" -Id 1 -Status "$completed% complete" -PercentComplete $completed
            Write-Host "$($p.id) installed"
            continue
        }

        try {
            # Download file
            Write-Progress -Activity $activity -CurrentOperation "Downloading $($p.url)" -Id 1 -Status "$completed% complete" -PercentComplete $completed
            $target = Join-Path -Path $env:TEMP -ChildPath (Split-Path -Path $p.url -Leaf)
            $wc = New-Object System.Net.WebClient
            $wc.DownloadFile($gitUri, $target)

            # Execute installer
            Write-Progress -Activity $activity -CurrentOperation "Installing $(Split-Path -Path $target -Leaf)" -Id 1 -Status "$completed% complete" -PercentComplete $completed
            $verb = if ($useSudo) { 'RunAs' } else { 'Open' }
            $exe = switch ($target.Extension) {
                .exe { $target }
                .msi { $args += ('/I', $target); 'msiexec.exe' }
                Default { throw "Unknown file type for $file" }
            }
            Start-Process -FilePath $exe -ArgumentList $Args -Wait -Verb $verb
        }
        catch {
            Write-Warning "Unable to install $($p.url)"
            Write-Warning "[$($_.Exception.GetType().FullName)] $($_.Exception.Message)"
        }
        finally {
            if (Test-Path -Path $target) { Remove-Item -Path $file -Force }
        }
    }
}

Install-PSModules
Install-Packages