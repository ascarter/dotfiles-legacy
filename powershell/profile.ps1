#region Bootstrap modules

if (!(Get-Module -Name PowerShellGet -ListAvailable)) {
    Install-Module -Name PowerShellGet -Scope CurrentUser -Force -AllowClobber
}

if (!(Get-Module -Name Microsoft.PowerShell.GraphicalTools -ListAvailable)) {
    Install-Module Microsoft.PowerShell.GraphicalTools -Scope CurrentUser -Force -AllowClobber
}

if (!(Get-Module -Name posh-git -ListAvailable)) {
    Install-Module -Name posh-git -Scope CurrentUser -AllowPrerelease -Force
}

#endregion

#region Environment

# Set DOTFILES environment varible if not already set
if ($null -eq [System.Environment]::GetEnvironmentVariable("DOTFILES", "User")) {
    Set-Item -Path Env:DOTFILES -Value (Join-Path $env:USERPROFILE -ChildPath ".config\dotfiles")
}

# Set editors
if (Get-Command vim -ErrorAction SilentlyContinue) {
    Set-Item -Path Env:EDITOR -Value 'vim'
}

if (Get-Command code -ErrorAction SilentlyContinue) {
    Set-Item -Path Env:VISUAL -Value 'code --wait'
}

function Update-Path([string[]]$paths) {
    $parts = $Env:PATH -Split ";"
    foreach ($p in $paths) {
        if ((Test-Path -Path $p) -and ($parts -NotContains $p)) {
            $parts += $p
        }
    }
    $Env:PATH = $parts -Join ";"
}

# Check for JDK
if (Test-Path -Path C:\JDK) {
    # TODO: figure out which JDK to use
    $jdk_version = '14.0.1'
    Set-Item -Path Env:JAVA_HOME -Value (Join-Path C:\JDK -ChildPath jdk-$jdk_version)
    Update-Path @(
        (Join-Path $Env:JAVA_HOME -ChildPath bin)
    )
}

# Check for Android SDK
if (Test-Path -Path $Env:LOCALAPPDATA\Android\SDK) {
    if ($null -eq [System.Environment]::GetEnvironmentVariable("ANDROID_SDK", "User")) {
        Set-Item -Path Env:ANDROID_SDK -Value $Env:LOCALAPPDATA\Android\SDK
    }

    Update-Path @(
        (Join-Path -Path $Env:ANDROID_SDK -ChildPath platform-tools),
        (Join-Path -Path $Env:ANDROID_SDK -ChildPath emulator),
        (Join-Path -Path $Env:ANDROID_SDK -ChildPath tools\bin)
    )
}

# Add developer tools to path
Update-Path @(
    (Join-Path -Path $Env:SystemDrive -ChildPath bin),
    (Join-Path -Path $Env:ProgramFiles -ChildPath vim\vim82),
    (Join-Path -Path $Env:LOCALAPPDATA -ChildPath "Fork")
)

#endregion

#region Alias behavoirs

Set-Alias -Name dev -Value Start-DevEnv
Set-Alias -Name dotfiles -Value Set-LocationDotfiles
Set-Alias -Name fork -Value Start-Fork
Set-Alias -Name opsignin -Value Start-1Password
Set-Alias -Name opssh -Value Get-SSHPassphrase

# Unix alias helpers
Set-Alias -Name ll -Value Get-ChildItem
Set-Alias -Name which -Value Get-Command
Set-Alias -Name uname -Value Get-Uname

# Set keybindings
Set-PSReadLineOption -EditMode Emacs

# macOS alias helpers
Set-Alias -Name pbcopy -Value Set-Clipboard
Set-Alias -Name pbpaste -Value Get-Clipboard

#endregion

#region Helpers

function Start-Fork([string]$MyRepo = $PWD) {
    $target = Convert-Path -Path $MyRepo
    & Fork.exe $target
}

function Start-1Password() {
    if ($null -eq $env:OP_SESSION_carters) {
        Invoke-Expression $(op signin carters)
    }
}

function Set-LocationDotfiles() {
    Set-Location -Path $env:DOTFILES
}

# Get-Password retrieves a password for a 1Password password item
function Get-SSHPassphrase([string]$Key = $env:COMPUTERNAME.ToLower()) {
    $sshKey = 'ssh ' + $Key
    Start-1Password
    op get item $sshKey | jq -r '.details.password' | Set-Clipboard
}

function Start-DevEnv() {
    & { Import-Module (Join-Path ${env:ProgramFiles(x86)} "Microsoft Visual Studio\2019\Enterprise\Common7\Tools\Microsoft.VisualStudio.DevShell.dll"); Enter-VsDevShell da341a44 }
}

function Start-ProfileEdit { code -n $PROFILE.CurrentUserAllHosts }

function Update-VSCodeExtensions() {
    $extensions = Get-Content -Path (Join-Path -Path $env:DOTFILES -ChildPath '.\vscode-extensions.txt')
    foreach ($extension in $extensions) { code --install-extension $extension }
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

#region gitconfig

function gc_set([string]$Key, [string]$Value) {
    git config --global $Key $Value | Out-Null
}

function gc_update([string]$Key, [string]$Value) {
    git config --global --unset $Key
    gc_set $Key $Value
}

function gc_prompt([string]$Key, [string]$Prompt) {
    $default = git config --global --get $Key
    $msg = if ($null -eq $default) { $Prompt } else { "$Prompt (default $default)" }
    $value = Read-Host -Prompt $msg
    if ($null -eq $value) { $value = $default }
    gc_set $Key $value
}

function Update-GitConfig() {
    # Include defaults and aliases
    gc_update 'include.path' (Join-Path -Path $env:DOTFILES -ChildPath gitconfig)

    # No line ending conversion
    gc_set 'core.autocrlf' 'input'

    # User info
    gc_prompt 'user.name' "User name"
    gc_prompt 'user.email' "Email"

    # GUI
    gc_set 'gui.fontui' '-family \"Segoe UI\" -size 10 -weight normal -slant roman -underline 0 -overstrike 0'
    gc_set 'gui.fontdiff' '-family \"Cascadia Code\" -size 10 -weight normal -slant roman -underline 0 -overstrike 0'

    # Show full gitconfig
    Write-Output $(git config --global --list)
}

#endregion

#region Prompt

# Configure prompt
if (Get-Module -Name posh-git -ListAvailable) {
    Import-Module posh-git

    function prompt {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = [Security.Principal.WindowsPrincipal] $identity

        $GitPromptSettings.DefaultPromptPrefix.Text = "`n[$env:COMPUTERNAME] "
        $GitPromptSettings.DefaultPromptBeforeSuffix.Text = '`n' + $(
            if (Test-Path variable:/PSDebugContext) { Write-Prompt '[DBG]: ' -ForegroundColor Red }
            elseif ($principal.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Write-Prompt '[ADMIN]: ' -ForegroundColor Magenta }
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
        [string]$ComputerName = $env:COMPUTERNAME,

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

            if ($ComputerName -eq $env:COMPUTERNAME) {
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
