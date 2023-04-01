#region Dotfiles setup

# Set DOTFILES environment varible if not already set
if ($null -eq [System.Environment]::GetEnvironmentVariable('DOTFILES', 'User')) {
    Set-Item -Path Env:DOTFILES -Value (Join-Path $Env:USERPROFILE -ChildPath .config\dotfiles)
}

# Add PSDotfiles module to path
$Env:PSModulePath += [System.IO.Path]::PathSeparator + (Join-Path -Path $Env:DOTFILES -ChildPath powershell\Modules)

#endregion

# Add tools to path
Update-Path @(
    (Join-Path -Path ${env:SystemDrive} -ChildPath bin),
    (Join-Path -Path ${env:LOCALAPPDATA} -ChildPath Fork),
    (Join-Path -Path ${env:ProgramFiles} -ChildPath '7-Zip'),
    (Join-Path -Path ${env:ProgramFiles} -ChildPath 'Sublime Text'),
    (Join-Path -Path ${env:ProgramFiles} -ChildPath 'Yubico\YubiKey Manager'),
    (Join-Path -Path ${env:ProgramFiles} -ChildPath qemu),
    (Join-Path -Path ${env:ProgramFiles(x86)} -ChildPath GnuPG\bin),
    (Join-Path -Path ${env:ProgramFiles(x86)} -ChildPath 'Gpg4Win\bin'),
    (Join-Path -Path ${env:ProgramFiles(x86)} -ChildPath 'Gpg4Win\bin_64')
)

#region Aliases

function Start-DevEnv {
    [CmdletBinding()]
    [Alias("dev")]
    param()
    & { Import-Module (Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\2019\Enterprise\Common7\Tools\Microsoft.VisualStudio.DevShell.dll'); Enter-VsDevShell da341a44 }
}

function Start-Fork {
    [CmdletBinding()]
    [Alias("fork")]
    param(
        [string]$Repo = $PWD
    )

    & Fork.exe (Convert-Path -Path $Repo)
}

Set-Alias -Name drawio -Value 'C:\Program Files\draw.io\draw.io.exe'
Set-Alias -Name mc -Value 'C:\Program Files (x86)\Midnight Commander\mc.exe'

#endregion
