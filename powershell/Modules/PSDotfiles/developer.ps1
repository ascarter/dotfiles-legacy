# Set editors
if (Get-Command vim -ErrorAction SilentlyContinue) {
    Set-Item -Path Env:EDITOR -Value 'vim'
}

if (Get-Command code -ErrorAction SilentlyContinue) {
    Set-Item -Path Env:VISUAL -Value 'code --wait'
}

# Check for Tailscale
if (Get-Command tailscale -ErrorAction SilentlyContinue) {
    Update-Path @(Join-Path -Path 'Env:\ProgramFiles(x86)' -ChildPath "Tailscale IPN")
}

# Check for Python
if (Get-Command python -ErrorAction SilentlyContinue) {
    # Use UTF-8 by default
    Set-Item -Path Env:PYTHONUTF8 -Value 1
}

# Check for Android SDK
if (Test-Path -Path (Join-Path $Env:LOCALAPPDATA -ChildPath Android\SDK)) {
    if ($null -eq [System.Environment]::GetEnvironmentVariable('ANDROID_SDK_ROOT', 'User')) {
        Set-Item -Path Env:ANDROID_SDK_ROOT -Value (Join-Path $Env:LOCALAPPDATA -ChildPath Android\SDK)
    }

    Update-Path @(
        (Join-Path -Path $Env:ANDROID_SDK_ROOT -ChildPath cmdline-tools\latest\bin),
        (Join-Path -Path $Env:ANDROID_SDK_ROOT -ChildPath platform-tools),
        (Join-Path -Path $Env:ANDROID_SDK_ROOT -ChildPath tools\bin)
    )
}

function Invoke-Codespace {
    <#
        .SYNOPSIS
            Codespace sandbox
    #>
    [CmdletBinding()]
    [Alias("udc")]
    param()
    docker run --rm -it -v .:/workspace -w /workspace mcr.microsoft.com/devcontainers/universal:latest $args
}
