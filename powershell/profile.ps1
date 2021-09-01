#region Environment

# Set DOTFILES environment varible if not already set
if ($null -eq [System.Environment]::GetEnvironmentVariable("DOTFILES", "User")) {
    Set-Item -Path Env:DOTFILES -Value (Join-Path $Env:USERPROFILE -ChildPath .config\dotfiles)
}

# Import Dotfiles module
Import-Module (Join-Path -Path $Env:DOTFILES -ChildPath PowerShell\Modules\Dotfiles)

# Set keybindings
Set-PSReadLineOption -EditMode Emacs

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

# Check for JDK
if (Test-Path -Path (Join-Path $Env:SDK_ROOT -ChildPath jdk)) {
    # Use latest JDK
    $jdkSdk = Join-Path $Env:SDK_ROOT -ChildPath jdk
    $jdk = Get-ChildItem -Path $jdkSdk -Filter jdk-* | Sort-Object -Descending | Select-Object -First 1
    if ($jdk) {
        Set-Item -Path Env:JAVA_HOME -Value $jdk
        Update-Path @((Join-Path $Env:JAVA_HOME -ChildPath bin))
    }
}

# Check for Android SDK
if (Test-Path -Path (Join-Path $Env:LOCALAPPDATA -ChildPath Android\SDK)) {
    if ($null -eq [System.Environment]::GetEnvironmentVariable("ANDROID_SDK", "User")) {
        Set-Item -Path Env:ANDROID_SDK -Value (Join-Path $Env:LOCALAPPDATA -ChildPath Android\SDK)
    }

    Update-Path @(
        (Join-Path -Path $Env:ANDROID_SDK -ChildPath platform-tools),
        (Join-Path -Path $Env:ANDROID_SDK -ChildPath emulator),
        (Join-Path -Path $Env:ANDROID_SDK -ChildPath tools\bin)
    )
}

# Check for Flutter SDK
if (Test-Path -Path (Join-Path $Env:SDK_ROOT -ChildPath flutter)) {
    if ($null -eq [System.Environment]::GetEnvironmentVariable("FLUTTER_SDK", "User")) {
        Set-Item -Path Env:FLUTTER_SDK -Value (Join-Path $Env:SDK_ROOT -ChildPath flutter)
    }

    Update-Path @(
        (Join-Path -Path $Env:SDK_ROOT -ChildPath flutter\bin)
    )
}

# Add developer tools to path
Update-Path @(
    (Join-Path -Path $Env:SystemDrive -ChildPath bin),
    (Join-Path -Path $Env:LOCALAPPDATA -ChildPath "Fork"),
    (Join-Path -Path $Env:ProgramFiles -ChildPath "7-Zip"),
    (Join-Path -Path $Env:ProgramFiles -ChildPath "Sublime Text"),
    (Join-Path -Path $Env:ProgramFiles -ChildPath "Yubico\YubiKey Manager"),
    (Join-Path -Path $Env:ProgramFiles -ChildPath vim\vim82)
)

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

#endregion

#region Alias behavoirs

Set-Alias -Name dev -Value Start-DevEnv
Set-Alias -Name dotfiles -Value Set-LocationDotfiles
Set-Alias -Name fork -Value Start-Fork

# Application aliases
Set-Alias -Name drawio -Value "C:\Program Files\draw.io\draw.io.exe"
Set-Alias -Name mc -Value "C:\Program Files (x86)\Midnight Commander\mc.exe"

# Unix alias helpers
Set-Alias -Name ll -Value Get-ChildItem
Set-Alias -Name which -Value Get-Command
Set-Alias -Name uname -Value Get-Uname

# macOS alias helpers
Set-Alias -Name pbcopy -Value Set-Clipboard
Set-Alias -Name pbpaste -Value Get-Clipboard

#endregion

#region Helpers

function Start-DevEnv() {
    & { Import-Module (Join-Path ${env:ProgramFiles(x86)} "Microsoft Visual Studio\2019\Enterprise\Common7\Tools\Microsoft.VisualStudio.DevShell.dll"); Enter-VsDevShell da341a44 }
}

function Start-Fork([string]$MyRepo = $PWD) {
    $target = Convert-Path -Path $MyRepo
    & Fork.exe $target
}
function Set-LocationDotfiles() { Set-Location -Path $Env:DOTFILES }
function Start-ProfileEdit { code -n $PROFILE.CurrentUserAllHosts }

#endregion

#region Prompt

# Configure prompt
if (Get-Module -Name posh-git -ListAvailable) {
    Import-Module posh-git

    function prompt {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = [Security.Principal.WindowsPrincipal] $identity

        $GitPromptSettings.DefaultPromptPrefix.Text = "`n[$Env:COMPUTERNAME] "
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
