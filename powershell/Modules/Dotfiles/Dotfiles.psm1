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

function Get-GitConfig([string]$Key) {
    git config --global --get $Key
}

function Set-GitConfig([string]$Key, [string]$Value) {
    git config --global $Key $Value | Out-Null
}

function Clear-GitConfig([string]$Key) {
    git config --global --unset $Key
}

function Update-GitConfig([string]$Key, [string]$Value) {
    Clear-GitConfig $Key
    Set-GitConfig $Key $Value
}

function Read-GitConfig([string]$Key, [string]$Prompt) {
    $default = Get-GitConfig $Key
    $msg = if ($null -eq $default) { $Prompt } else { "$Prompt (default $default)" }
    $value = Read-Host -Prompt $msg
    if ($null -eq $value) { $value = $default }
    Set-GitConfig $Key $value
}

function Update-GitConfig() {
    # Include defaults and aliases
    Update-GitConfig 'include.path' (Join-Path -Path $Env:DOTFILES -ChildPath gitconfig)

    # No line ending conversion
    Set-GitConfig 'core.autocrlf' 'input'

    # Enable longpaths
    Set-GitConfig 'core.longpaths' 'true'

    # User info
    Read-GitConfig 'user.name' "User name"
    Read-GitConfig 'user.email' "Email"

    # GUI
    Set-GitConfig 'gui.fontui' '-family \"Segoe UI\" -size 10 -weight normal -slant roman -underline 0 -overstrike 0'
    Set-GitConfig 'gui.fontdiff' '-family \"Cascadia Code\" -size 10 -weight normal -slant roman -underline 0 -overstrike 0'

    # Show full gitconfig
    Write-Output $(git config --global --list)
}

#endregion

#region Helpers

function Get-InstalledSoftware {
    <#
    .SYNOPSIS
    Retrieves a list of all software installed on a Windows computer.
    .EXAMPLE
    PS> Get-InstalledSoftware

    This example retrieves all software installed on the local computer.
    .PARAMETER ComputerName
    If querying a remote computer, use the computer name here.

    .PARAMETER Name
    The software title you'd like to limit the query to.

    .PARAMETER Guid
    The software GUID you'e like to limit the query to
    #>
    [CmdletBinding()]
    param (

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$ComputerName = $Env:COMPUTERNAME,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter()]
        [guid]$Guid,

        [Parameter(Mandatory = $false)]
        [switch]$Gui
    )
    process {
        try {
            $scriptBlock = {
                $args[0].GetEnumerator() | ForEach-Object { New-Variable -Name $_.Key -Value $_.Value }

                $UninstallKeys = @(
                    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
                    "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
                )

                if (Get-IsAdmin) {
                    New-PSDrive -Name HKU -PSProvider Registry -Root Registry::HKEY_USERS | Out-Null
                    $UninstallKeys += Get-ChildItem HKU: | Where-Object { $_.Name -match 'S-\d-\d+-(\d+-){1,14}\d+$' } | ForEach-Object {
                        "HKU:\$($_.PSChildName)\Software\Microsoft\Windows\CurrentVersion\Uninstall"
                    }
                }

                if (-not $UninstallKeys) {
                    Write-Warning -Message 'No software registry keys found'
                }
                else {
                    foreach ($UninstallKey in $UninstallKeys) {
                        $friendlyNames = @{
                            'DisplayName'    = 'Name'
                            'DisplayVersion' = 'Version'
                        }
                        Write-Verbose -Message "Checking uninstall key [$($UninstallKey)]"
                        if ($Name) {
                            $WhereBlock = { $_.GetValue('DisplayName') -like "$Name*" }
                        }
                        elseif ($GUID) {
                            $WhereBlock = { $_.PsChildName -eq $Guid.Guid }
                        }
                        else {
                            $WhereBlock = { $_.GetValue('DisplayName') }
                        }
                        $SwKeys = Get-ChildItem -Path $UninstallKey -ErrorAction SilentlyContinue | Where-Object $WhereBlock
                        if (-not $SwKeys) {
                            Write-Verbose -Message "No software keys in uninstall key $UninstallKey"
                        }
                        else {
                            foreach ($SwKey in $SwKeys) {
                                $output = @{ }
                                $output.Name = $SwKey
                                foreach ($ValName in $SwKey.GetValueNames()) {
                                    if ($ValName -ne 'Version') {
                                        $output.InstallLocation = ''
                                        if ($ValName -eq 'InstallLocation' -and
                                            ($SwKey.GetValue($ValName)) -and
                                            (@('C:', 'C:\Windows', 'C:\Windows\System32', 'C:\Windows\SysWOW64') -notcontains $SwKey.GetValue($ValName).TrimEnd('\'))) {
                                            $output.InstallLocation = $SwKey.GetValue($ValName).TrimEnd('\')
                                        }
                                        [string]$ValData = $SwKey.GetValue($ValName)
                                        if ($friendlyNames[$ValName]) {
                                            $output[$friendlyNames[$ValName]] = $ValData.Trim() ## Some registry values have trailing spaces.
                                        }
                                        else {
                                            $output[$ValName] = $ValData.Trim() ## Some registry values trailing spaces
                                        }
                                    }
                                }
                                $output.GUID = ''
                                if ($SwKey.PSChildName -match '\b[A-F0-9]{8}(?:-[A-F0-9]{4}){3}-[A-F0-9]{12}\b') {
                                    $output.GUID = $SwKey.PSChildName
                                }
                                New-Object -TypeName PSObject -Prop $output
                            }
                        }
                    }
                }
            }

            if ($ComputerName -eq $Env:COMPUTERNAME) {
                $results = Invoke-Command -ScriptBlock $scriptBlock -ArgumentList $PSBoundParameters
            }
            else {
                $results = Invoke-Command -ComputerName $ComputerName -ScriptBlock $scriptBlock -ArgumentList $PSBoundParameters
            }
            if ($Gui) {
                $results | Out-GridView -Title "Installed Software"
            }
            else {
                $results | Format-Table -AutoSize -Property Name, Publisher, Version, GUID
            }
        }
        catch {
            Write-Error -Message "Error: $($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)"
        }
    }
}

function Get-Uname() {
    Get-CimInstance Win32_OperatingSystem | Select-Object 'Caption', 'CSName', 'Version', 'BuildType', 'OSArchitecture' | Format-Table
}

function Get-IsAdmin() {
    ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-CmdletAlias ($cmdletname) {
    Get-Alias | Where-Object -FilterScript { $_.Definition -like "$cmdletname" } | Format-Table -Property Definition, Name -AutoSize
}

#endregion
