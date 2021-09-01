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
    process {
        $parts = $Env:PATH -Split ";"
        if ($SetEnv) { $envparts = [System.Environment]::GetEnvironmentVariable("PATH") -Split ";" }

        foreach ($p in $paths) {
            if (Test-Path -Path $p) {
                # Add to current path
                if ($parts -NotContains $p) { $parts += $p }
                # Add to environment path if requested
                if (($SetEnv) -and ($envparts -NotContains $p)) { $envparts += $p }
            }
        }

        # Set current path
        $Env:PATH = $parts -Join ";"

        # Save to environment path if requested
        if ($SetEnv) { [System.Environment]::SetEnvironmentVariable("PATH", $envparts -Join ";", [System.EnvironmentVariableTarget]::User) }
    }
}

function Install-Zip {
    <#
    .SYNOPSIS
        Download and extract zip archive to target location 
    .EXAMPLE
        PS C:\> Install-Zip https://example.com/myapp.zip
        Downloads myapp.zip from URI and extracts
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

#region Git

function Get-GitConfig {
    param (
        [string]$Key
    )

    git config --global --get $Key
}

function Read-GitConfig {
    param (
        [string]$Key,
        [string]$Prompt
    )

    $default = Get-GitConfig -Key $Key
    $msg = if ($null -eq $default) { $Prompt } else { "$Prompt (default $default)" }
    $value = Read-Host -Prompt $msg
    if ($null -eq $value) { $value = $default }
    Set-GitConfig -Key $Key -Value $value
}
function Remove-GitConfig {
    param (
        [string]$Key
    )

    git config --global --unset $Key
}

function Set-GitConfig {
    param (
        [string]$Key,
        [string]$Value
    )

    git config --global $Key $Value | Out-Null
}
function Update-GitConfig {
    param (
        [string]$Key,
        [string]$Value
    )

    Remove-GitConfig -Key $Key
    Set-GitConfig -Key $Key -Value $Value
}

function Write-GitConfig {
    [CmdletBinding()]
    param()

    # Include defaults and aliases
    Update-GitConfig -Key 'include.path' -Value (Join-Path -Path $Env:DOTFILES -ChildPath gitconfig)

    # No line ending conversion
    Set-GitConfig -Key 'core.autocrlf' -Value 'input'

    # Enable longpaths
    Set-GitConfig -Key 'core.longpaths' -Value 'true'

    # User info
    Read-GitConfig -Key 'user.name' -Prompt "User name"
    Read-GitConfig -Key 'user.email' -Prompt "Email"

    # GUI
    Set-GitConfig -Key 'gui.fontui' -Value '-family \"Segoe UI\" -size 10 -weight normal -slant roman -underline 0 -overstrike 0'
    Set-GitConfig -Key 'gui.fontdiff' -Value '-family \"Cascadia Code\" -size 10 -weight normal -slant roman -underline 0 -overstrike 0'

    # Show full gitconfig
    Write-Verbose -Message "$((git config --global --list) | Out-String)"
}

#endregion

#region Helpers

function Get-Uname {
    Get-CimInstance Win32_OperatingSystem | Select-Object 'Caption', 'CSName', 'Version', 'BuildType', 'OSArchitecture' | Format-Table
}

Set-Alias -Name uname -Value Get-Uname

function Test-Adminstrator {
    ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Invoke-Administrator {
    <#
    .SYNOPSIS
    Execute command using elevated privileges (sudo for Windows)
    .EXAMPLE
    PS> Invoke-Administrator -Command &{Write-Host "I am admin"}

    This example runs a Write-Host command as Administrator
    .PARAMETER Command
    Script block for command to execute as Administrator
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$Command
    )
    process {
        Start-Process powershell -Verb RunAs -ArgumentList @('-Command', $Command) -Wait
    }
}

Set-Alias -Name sudo -Value Invoke-Administrator

#endregion
