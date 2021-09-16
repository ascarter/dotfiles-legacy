#region PSReadLine

if ($host.Name -eq 'ConsoleHost') {
    Import-Module PSReadLine
    Set-PSReadLineOption -EditMode Emacs
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineOption -PredictionSource History
    # Set-PSReadLineOption -PredictionViewStyle ListView        
}

#endregion

#region Helpers

function Set-LocationDotfiles() { Set-Location -Path $Env:DOTFILES }
Set-Alias -Name dotfiles -Value Set-LocationDotfiles

function Start-ProfileEdit { code -n $PROFILE.CurrentUserAllHosts }
Set-Alias -Name editprofile -Value Start-ProfileEdit

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
        $parts = ($Env:PATH -Split ";" | Sort-Object | Get-Unique)
        if ($SetEnv) { $envparts = ([System.Environment]::GetEnvironmentVariable("PATH") -Split ";" | Sort-Object | Get-Unique) }

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

    $values = @{
        RegisteredOwner = $Owner
        RegisteredOrganization = $Organization
    }

    $current = Get-ItemProperty -Path $OwnerKey
    foreach ($prop in $values.Keys) {
        $value = $values[$prop]
        if ($value -ne $current.$prop) {
            Invoke-Administrator "& { Set-ItemProperty -Path '$OwnerKey' -Name '$prop' -Value '$value' }"
        } else {
            Write-Output "No change for $prop"
        }
    }

    Get-Owner        
}

#endregion

#region Developer

# Set editors
if (Get-Command vim -ErrorAction SilentlyContinue) {
    Set-Item -Path Env:EDITOR -Value 'vim'
}

if (Get-Command code -ErrorAction SilentlyContinue) {
    Set-Item -Path Env:VISUAL -Value 'code --wait'
}

# Set SDK environment variable if not set
if ($null -eq [System.Environment]::GetEnvironmentVariable("SDK_ROOT", "User")) {
    Set-Item -Path Env:SDK_ROOT -Value (Join-Path $Env:USERPROFILE -ChildPath sdk)
}

# Check for Go
if (Get-Command go -ErrorAction SilentlyContinue) {
    Update-Path @(Join-Path -Path (go env GOPATH) -ChildPath bin)
}

# Check for Android SDK
if (Test-Path -Path (Join-Path $Env:LOCALAPPDATA -ChildPath Android\SDK)) {
    if ($null -eq [System.Environment]::GetEnvironmentVariable("ANDROID_SDK_ROOT", "User")) {
        Set-Item -Path Env:ANDROID_SDK_ROOT -Value (Join-Path $Env:LOCALAPPDATA -ChildPath Android\SDK)
    }

    Update-Path @(
        (Join-Path -Path $Env:ANDROID_SDK_ROOT -ChildPath cmdline-tools\latest\bin),
        (Join-Path -Path $Env:ANDROID_SDK_ROOT -ChildPath platform-tools),
        (Join-Path -Path $Env:ANDROID_SDK_ROOT -ChildPath tools\bin)
    )
}

# Check for Flutter SDK
if (Test-Path -Path (Join-Path $Env:SDK_ROOT -ChildPath flutter)) {
    if ($null -eq [System.Environment]::GetEnvironmentVariable("FLUTTER_SDK", "User")) {
        Set-Item -Path Env:FLUTTER_SDK -Value (Join-Path $Env:SDK_ROOT -ChildPath flutter)
    }

    Update-Path @(Join-Path -Path $Env:SDK_ROOT -ChildPath flutter\bin)
}

#endregion

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

#region PowerShell

# Enable winget completion
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)

        [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
        $Local:word = $wordToComplete.Replace('"', '""')
        $Local:ast = $commandAst.ToString().Replace('"', '""')
        winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}

function Get-CmdletAlias ($cmdletname) {
    <#
        .SYNOPSIS
            List aliases for any cmdlet
    #>
    Get-Alias |
      Where-Object -FilterScript {$_.Definition -like "$cmdletname"} |
        Format-Table -Property Definition, Name -AutoSize
}

function Get-Uname {
    <#
    .SYNOPSIS
    Emulate Unix uname
    #>
    Get-CimInstance Win32_OperatingSystem | Select-Object 'Caption', 'CSName', 'Version', 'BuildType', 'OSArchitecture' | Format-Table
}

# Unix aliases
Set-Alias -Name uname -Value Get-Uname
Set-Alias -Name ll -Value Get-ChildItem
Set-Alias -Name which -Value Get-Command

# macOS aliases
Set-Alias -Name pbcopy -Value Set-Clipboard
Set-Alias -Name pbpaste -Value Get-Clipboard

Set-Alias -Name fal -Value Get-CmdletAlias

#endregion

#region Prompt

if (Get-Module -Name posh-git -ListAvailable) {
    Import-Module posh-git

    function prompt {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = [Security.Principal.WindowsPrincipal] $identity

        $GitPromptSettings.DefaultPromptPrefix.Text = "`n[$Env:COMPUTERNAME] "
        $GitPromptSettings.DefaultPromptBeforeSuffix.Text = '`n' + $(
            if (Test-Path variable:/PSDebugContext) {
                Write-Prompt '[DBG]: ' -ForegroundColor Red
            }
            elseif ($principal.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
                Write-Prompt '[ADMIN]: ' -ForegroundColor Magenta
            }
        )
        $GitPromptSettings.DefaultPromptSuffix.Text = "PS > "
        $prompt = & $GitPromptScriptBlock
        if ($prompt) { $prompt } else { ' ' }
    }
}
else {
    # Default prompt with ADMIN and DBG
    function prompt {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = [Security.Principal.WindowsPrincipal] $identity

        $(if (Test-Path variable:/PSDebugContext) { '[DBG]: ' }
            elseif ($principal.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { "[ADMIN]: " }
            else { '' }
        ) + 'PS ' + $(Get-Location) +
        $(if ($NestedPromptLevel -ge 1) { '>>' }) + '> '
    }
}    

#endregion
