#region sudo

function Test-Administrator {
    <#
        .SYNOPSIS
            Test if active user is administrator
    #>
    ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Assert-Administrator {
    <#
        .SYNOPSIS
            Require administrator privileges or abort. Used to ensure code is executed only when Administrator.
    #>
    if (-not (Test-Administrator)) {
        Write-Warning "Administrator required to execute"
        Break
    }
}

function Invoke-Administrator {
    <#
        .SYNOPSIS
            Execute command using elevated adminstrator privileges
        .DESCRIPTION
            Invoke-Administrator is a version of sudo for Windows. The alias `sudo` will work as well.
            The command will be invoked in another PowerShell process running as administrator.
        .PARAMETER Command
            Script block for command to execute
        .PARAMETER NoExit
            Does not exit administrator session after running command
        .PARAMETER Wait
            Wait for command to complete before continuing
        .PARAMETER PowerShellEdition
            PowerShell edition to use
            Default value is `Default` which uses the same shell as the calling process
            Values can be `Default`, `Desktop` or `Core`
        .PARAMETER CommandLine
            Collects remainder of the command line to enable convenient style.
        .EXAMPLE
            PS> Invoke-Administrator -Command & { Write-Host "I am admin" }

            This example runs a Write-Host command as Administrator
        .EXAMPLE
            sudo Get-Item -Path $PROFILE.CurrentUserAllHosts
    #>
    [CmdletBinding()]
    [Alias("sudo")]
    param (
        [Parameter()]
        [Alias("c")]
        [string]$Command,
        [Alias("noe")]
        [switch]$NoExit,
        [Alias("w")]
        [switch]$Wait,
        [ValidateSet("Default", "Desktop", "Core")]
        [string]$PowerShellEdition = "Default",
        [parameter(ValueFromRemainingArguments = $true)]
        [string[]]$CommandLine
    )

    if ($PowerShellEdition -eq "Default") {
        $PowerShellEdition = $PSVersionTable["PSEdition"]
    }

    $cmdLine = ($Command + " " + ($CommandLine -join " ")).Trim()
    Write-Verbose ("sudo using PowerShell {0} edition: {1}" -f $PowerShellEdition, $cmdLine)

    switch ($PowerShellEdition) {
        "Core" { $shell = 'pwsh' }
        "Desktop" { $shell = 'powershell' }
    }
    $procArgs = @('-Command', $cmdLine)
    if ($NoExit) { $procArgs = @('-NoExit') + $procArgs }

    Start-Process -FilePath $shell -ArgumentList $procArgs -Wait:$Wait -Verb RunAs
}

function Invoke-AdministratorTerminal {
    <#
        .SYNOPSIS
            Launch Windows Terminal as administrator
        .DESCRIPTION
            Launch a new Windows Terminal instance as administrator.
            Alias `wsudo` for windowed sudo
    #>
    [CmdletBinding()]
    [Alias("wsudo")]
    param()

    Start-Process -FilePath wt -Verb RunAs
}

#endregion
