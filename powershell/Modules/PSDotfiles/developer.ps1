# Set editors
if (Get-Command vim -ErrorAction SilentlyContinue) {
    Set-Item -Path Env:EDITOR -Value 'vim'
}

if (Get-Command code -ErrorAction SilentlyContinue) {
    Set-Item -Path Env:VISUAL -Value 'code --wait'
}

# Set SDK environment variable if not set
if ($null -eq [System.Environment]::GetEnvironmentVariable('SDK_ROOT', 'User')) {
    Set-Item -Path Env:SDK_ROOT -Value (Join-Path $Env:USERPROFILE -ChildPath sdk)
}

# Check for Tailscale
if (Get-Command tailscale -ErrorAction SilentlyContinue) {
    Update-Path @(Join-Path -Path 'Env:\ProgramFiles(x86)' -ChildPath "Tailscale IPN")
}

# Check for Go
if (Get-Command go -ErrorAction SilentlyContinue) {
    Update-Path @(Join-Path -Path (go env GOPATH) -ChildPath bin)
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

# Check for Flutter SDK
if (Test-Path -Path (Join-Path $Env:SDK_ROOT -ChildPath flutter)) {
    if ($null -eq [System.Environment]::GetEnvironmentVariable('FLUTTER_SDK', 'User')) {
        Set-Item -Path Env:FLUTTER_SDK -Value (Join-Path $Env:SDK_ROOT -ChildPath flutter)
    }

    Update-Path @(Join-Path -Path $Env:SDK_ROOT -ChildPath flutter\bin)
}
