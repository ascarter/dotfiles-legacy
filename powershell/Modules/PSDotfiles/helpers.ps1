#region Profile

function Set-LocationDotfiles {
    [CmdletBinding()]
    [Alias("dotfiles")]
    param()
    Set-Location -Path $Env:DOTFILES
}

function Start-ProfileEdit {
    [CmdletBinding()]
    [Alias("editprofile")]
    param()
    code -n $PROFILE.CurrentUserAllHosts
}

function Update-Path {
    <#
    .SYNOPSIS
    Add list of paths to current path
    .EXAMPLE
    PS> Update-Path @(C:\bin, C:\tools)

    This example adds C:\bin and C:\tools to the current path
    .PARAMETER Paths
    List of paths to add
    .PARAMETER SetEnv
    Flag to indicate if the list of paths should be saved to the User PATH environment variable
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [string[]]$Paths,

        [Parameter(Mandatory = $false)]
        [switch]$SetEnv
    )

    $parts = ($Env:PATH -Split ';' | Sort-Object | Get-Unique)
    if ($SetEnv) {
        $envparts = ([System.Environment]::GetEnvironmentVariable('PATH') -Split ';' | Sort-Object | Get-Unique)
    }

    foreach ($p in $paths) {
        if (Test-Path -Path $p) {
            # Add to current path
            if ($parts -NotContains $p) { $parts += $p }
            # Add to environment path if requested
            if (($SetEnv) -and ($envparts -NotContains $p)) { $envparts += $p }
        }
    }

    # Set current path
    $Env:PATH = $parts -Join ';'

    # Save to environment path if requested
    if ($SetEnv) {
        [System.Environment]::SetEnvironmentVariable('PATH', $envparts -Join ';', [System.EnvironmentVariableTarget]::User)
    }
}

#endregion


#region Owner

$OwnerKey = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'

function Get-Owner {
    <#
    .SYNOPSIS
        Show register owner and organziation
    #>

    Get-ItemProperty -Path $OwnerKey | Format-Table RegisteredOwner, RegisteredOrganization
}

function Update-Owner {
    <#
    .SYNOPSIS
        Set owner and organization
    #>
    [CmdletBinding()]
    param(
        [string]$Owner = (Get-ItemProperty -Path $OwnerKey).RegisteredOwner,
        [string]$Organization = (Get-ItemProperty -Path $OwnerKey).RegisteredOrganization
    )

    Assert-Administrator

    $values = @{
        RegisteredOwner        = $Owner
        RegisteredOrganization = $Organization
    }

    $current = Get-ItemProperty -Path $OwnerKey
    foreach ($prop in $values.Keys) {
        $value = $values[$prop]
        if ($value -ne $current.$prop) {
            Set-ItemProperty -Path $OwnerKey -Name $prop -Value $value
        }
        else {
            Write-Output "No change for $prop"
        }
    }

    Get-Owner
}

#endregion


#region Environment Variables

$SessionEnvKey = 'HKLM:\System\CurrentControlSet\Control\Session Manager\Environment'

function Get-EnvironmentVariable {
    <#
    .SYNOPSIS
        Get system environment variable
    #>
    [CmdletBinding()]
    param(
        [string]$Name
    )

    Get-ItemProperty -Path $SessionEnvKey -Name $Name | Format-Table $Name
}

function Set-EnvironmentVariable {
    <#
    .SYNOPSIS
        Set system environment variable
    #>
    [CmdletBinding()]
    param(
        [string]$Name,
        [string]$Value
    )

    Set-ItemProperty -Path $SessionEnvKey -Name $Name -Value $Value
}

#region Multipass

$MultipassStorageEnv = 'MULTIPASS_STORAGE'

function Get-MultipassStoragePath {
    <#
    .SYNOPSIS
        Get Multipass storage location
    #>
    Get-EnvironmentVariable -Name $MultipassStorageEnv
}

function Set-MultipassStoragePath {
    <#
    .SYNOPSIS
        Set Multipass storage path
    #>
    [CmdletBinding()]
    param(
        [string]$Path
    )
    Stop-Service Multipass
    Set-EnvironmentVariable -Name $MultipassStorageEnv -Value $Path
    Start-Service Multipass
}
#endregion
