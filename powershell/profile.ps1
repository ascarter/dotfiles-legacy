#region Dotfiles setup

# Set DOTFILES environment varible if not already set
if ($null -eq [System.Environment]::GetEnvironmentVariable("DOTFILES", "User")) {
    Set-Item -Path Env:DOTFILES -Value (Join-Path $Env:USERPROFILE -ChildPath .config\dotfiles)
}

# Import Dotfiles module
Import-Module (Join-Path -Path $Env:DOTFILES -ChildPath PowerShell\Modules\Dotfiles)

#endregion

# Add tools to path
Update-Path @(
    (Join-Path -Path $Env:SystemDrive -ChildPath bin),
    (Join-Path -Path $Env:LOCALAPPDATA -ChildPath "Fork"),
    (Join-Path -Path $Env:ProgramFiles -ChildPath "7-Zip"),
    (Join-Path -Path $Env:ProgramFiles -ChildPath "Sublime Text"),
    (Join-Path -Path $Env:ProgramFiles -ChildPath "Yubico\YubiKey Manager"),
    (Join-Path -Path $Env:ProgramFiles -ChildPath vim\vim82)
)

#region Aliases

function Start-DevEnv() {
    & { Import-Module (Join-Path ${env:ProgramFiles(x86)} "Microsoft Visual Studio\2019\Enterprise\Common7\Tools\Microsoft.VisualStudio.DevShell.dll"); Enter-VsDevShell da341a44 }
}
Set-Alias -Name dev -Value Start-DevEnv

function Start-Fork {
    param(
        [string]$Repo = $PWD
    )

    & Fork.exe (Convert-Path -Path $Repo)
}
Set-Alias -Name fork -Value Start-Fork

Set-Alias -Name drawio -Value "C:\Program Files\draw.io\draw.io.exe"
Set-Alias -Name mc -Value "C:\Program Files (x86)\Midnight Commander\mc.exe"

#endregion
