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
    if (!$value) { $value = $default }
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
    [Alias("gitconfig")]
    param()

    # Include defaults and aliases
    Update-GitConfig -Key 'include.path' -Value (Join-Path -Path $Env:DOTFILES -ChildPath conf\gitconfig)

    # Set SSH command
    Set-GitConfig -Key 'core.sshCommand' -Value 'C:/Windows/System32/OpenSSH/ssh.exe'

    # No line ending conversion
    Set-GitConfig -Key 'core.autocrlf' -Value 'input'

    # Enable longpaths
    Set-GitConfig -Key 'core.longpaths' -Value 'true'

    # User info
    Read-GitConfig -Key 'user.name' -Prompt 'User name'
    Read-GitConfig -Key 'user.email' -Prompt 'Email'

    # GUI
    Set-GitConfig -Key 'gui.fontui' -Value '-family \"Segoe UI\" -size 10 -weight normal -slant roman -underline 0 -overstrike 0'
    Set-GitConfig -Key 'gui.fontdiff' -Value '-family \"Cascadia Code\" -size 10 -weight normal -slant roman -underline 0 -overstrike 0'

    # Show full gitconfig
    Write-Verbose -Message "$((git config --global --list) | Out-String)"
}
