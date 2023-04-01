#region Tasks

function Install-Bootstrap {
    <#
        .SYNOPSIS
            Bootstrap PSDotfiles
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # dotfiles path
        [string]$Path = $Env:DOTFILES,

        # Replace existing configuration
        [switch]$Force
    )

    Write-Output 'Bootstrap PSDotfiles'

    Write-Verbose "Install profile to $Path"
    Install-Profile -Path $Path -Force:$Force

    Write-Verbose 'Install vimrc'
    Install-Vimrc -Path $Path -Force:$Force

    Write-Verbose 'Install bin'
    Install-Bin

    Write-Output 'Boostrap complete'
}

function Update-DevTools {
    <#
    .SYNOPSIS
        Update/install developer tools
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # Replace existing configuration
        [switch]$Force
    )

    Write-Output 'Updating developer system settings'

    Install-Bootstrap -Force:$Force

    Write-Output 'Update git configuration'
    Write-GitConfig

    Write-Output 'Update PowerShell modules'
    Update-PowerShellModules -Force:$Force

    # Install developer tools
    # winget install --id GoLang.Go.1.19 --interactive
    # go install github.com/jstarks/npiperelay@latest

    Write-Output 'Recommend reboot to enable all services'
}

function Enable-Virtualization {
    <#
        .SYNOPSIS
            Enable Windows virtualization features
    #>

    Assert-Administrator

    # Enable Windows Features
    $features = @('VirtualMachinePlatform', 'HypervisorPlatform', 'Microsoft-Hyper-V')
    foreach ($f in $features) {
        try {
            Write-Output "Enable $f"
            Enable-WindowsOptionalFeature -Online -FeatureName $f -All -NoRestart
        }
        catch { Write-Warning $_ }
    }
}

function Enable-WSL {
    <#
        .SYNOPSIS
            Enable Windows Subystem for Linux
    #>
    Assert-Administrator
    Write-Output 'Enable WSL'
    wsl --update
    wsl --install --distribution Ubuntu
}

#endregion

#region Helpers

function Install-Zip {
    <#
    .SYNOPSIS
        Download and extract zip archive to target location
    .EXAMPLE
        PS C:\> Install-Zip -Uri https://example.com/myapp.zip -Dest C;\bin
        Downloads myapp.zip from URI and extracts to C:\bin
    .PARAMETER Uri
    URI of zip file
    .PARAMETER Dest
    Destination path
    #>
    [CmdletBinding()]
    param (
        [string]$Uri,
        [string]$Dest
    )

    try {
        # Create a random file in temp
        $zipfile = [System.IO.Path]::GetRandomFileName()
        $target = Join-Path -Path $env:TEMP -ChildPath $zipfile

        # Download to temp
        Write-Verbose "Downloading $uri to $target"
        $wc = New-Object System.Net.WebClient
        $wc.DownloadFile($uri, $target)

        # Unzip
        Write-Verbose "Extracting $target to $Dest"
        Expand-Archive -Path $target -DestinationPath $Dest -Force
    }
    finally {
        if (Test-Path $target) { Remove-Item -Path $target }
    }
}

function Get-WinGetLinks {
    <#
        .SYNOPSIS
            List winget links
    #>
    [CmdletBinding()]
    [Alias("wglinks")]
    param ()

    $linksPath = Join-Path $Env:LOCALAPPDATA -ChildPath Microsoft\WinGet\Links
    Get-ChildItem -Path $linksPath | Where-Object -Property LinkType -eq -Value "SymbolicLink" | Format-Table -Property Name, LinkTarget
}

#endregion

#region Configuration

function Install-Profile {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # Path of dotfiles
        [string]$Path = $Env:DOTFILES,

        [string]$PSProfile = $PROFILE.CurrentUserAllHosts,

        # Replace existing profile
        [switch]$Force
    )

    if ($Force -and (Test-Path $PSProfile)) {
        Remove-Item -Path $PSProfile -Force
    }

    if (-not (Test-Path $PSProfile)) {
        Write-Output 'Install PowerShell profile'
        New-Item -Path $PSProfile -ItemType File -Force
        $dotfilesProfile = (Join-Path $Path -ChildPath profile.ps1)
        Set-Content -Path $PSProfile -Value ". $dotfilesProfile"
    }
}

function Install-Vimrc {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # Path of dotfiles
        [string]$Path = $Env:DOTFILES,

        # Replace existing vimrc
        [switch]$Force
    )
    # Vim profile
    $vimrc = Join-Path -Path $env:USERPROFILE -ChildPath _vimrc
    if ($Force) { Remove-Item -Path $vimrc -Force }
    if (-not (Test-Path -Path $vimrc)) {
        Write-Output 'Install vimrc'
        New-Item -Path $vimrc -ItemType File -Force
        $dotfilesVimrc = (Join-Path $Path -ChildPath conf\vimrc)
        Set-Content -Path $vimrc -Value "source $dotfilesVimrc"
    }
}

#endregion

#region Powershell modules

function Update-PowerShellModules {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # Replace existing modules
        [switch]$Force
    )
    $psmodules = @(
        'Microsoft.PowerShell.ConsoleGuiTools',
        'posh-git',
        'PSScriptAnalyzer',
        'WslInterop'
    )
    foreach ($m in $psmodules) {
        try {
            if (-not (Find-Module -Name $m -ErrorAction SilentlyContinue)) { throw "Module $m is not available" }

            if ($Force -and (Get-Module -Name $m)) {
                Write-Output "Removing $m"
                Uninstall-Module -Name $m -Force
            }

            if (-not (Get-Module -Name $m)) {
                Write-Output "Installing $m"
                Install-Module -Name $m -Scope CurrentUser -Force -AllowClobber -AllowPrerelease -AcceptLicense
            }
            else {
                Write-Output "Updating $m"
                Update-Module -Name $m -Scope CurrentUser -Force -AllowPrerelease -AcceptLicense
            }
        }
        catch {
            Write-Warning $_
        }
    }
}

$M365UpdateKey = 'HKLM:Software\Policies\Microsoft\office\16.0\common\officeupdate'

function Get-M365UpdateChannel {
    [CmdletBinding()]
    param ()

    # Check if the registry key exists
    if (-not (Test-Path $M365UpdateKey)) {
        Write-Output 'Current'
        return
    }

    Write-Output (Get-ItemProperty -Path $M365UpdateKey -Name updatebranch).updatebranch
}

function Set-M365UpdateChannel {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateSet('Current', 'MonthlyEnterprise', 'BetaChannel', 'CurrentPreview')]
        [string]$Channel = 'Current'
    )

    # Get the current update channel
    $currentChannel = Get-M365UpdateChannel

    # If the current channel is not the same as the requested channel, change it
    if ($currentChannel -ne $Channel) {
        Write-Output "Updating Microsoft 365 update channel from $currentChannel to $Channel"
        Set-ItemProperty -Path $M365UpdateKey -Name updatebranch -Value $Channel
    }
}

#endregion

#region System

function Install-SSH {
    <#
        .SYNOPSIS
            Enable OpenSSH server
        .PARAMETER EnableAgent
            Enable SSH agent
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [switch]$EnableAgent
    )

    Assert-Administrator

    # Install OpenSSH
    # https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse
    Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

    # Start sshd service
    Start-Service sshd
    Set-Service -Name sshd -StartupType 'Automatic'
    Get-Service sshd

    if ($EnableAgent) {
        # Start ssh-agent service
        Start-Service ssh-agent
        Set-Service -Name ssh-agent -StartupType 'Automatic'
    }

    # Confirm the Firewall rule is configured. It should be created automatically by setup. Run the following to verify
    if (!(Get-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
        Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
        New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
    }
    else {
        Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists."
    }

    # Configure default shell
    Set-ItemProperty -Path HKLM:\SOFTWARE\OpenSSH -Name DefaultShell -Value $Env:ProgramFiles\PowerShell\7\pwsh.exe
}

function Get-SSHAgentKeys {
    <#
        .SYNOPSIS
            Fetch active public keys from SSH agent
    #>
    @(ssh-add -L)
}

function Add-SSHAuthorizedKeys {
    <#
        .SYNOPSIS
            Add input list of keys as authorized SSH keys
        .DESCRIPTION
            Adds keys to either user's `~/.ssh/authorized_keys` file or to `$Env:ProgramData\ssh\adminstrator_authorized_keys`.
            If executed using Administrator privileges, admin authorized key file is used. Otherwise uses user's authorized keys.
        .PARAMETER AuthorizedKeys
            List of SSH public keys to add to authorized keys. Can either be a single key or a list.
            Default - any public keys in the active SSH agent
        .PARAMETER Force
            Replace all existing authorized keys with the input list
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string[]]$AuthorizedKeys = @(Get-SSHAgentKeys),
        [switch]$Force
    )

    if (Test-Administrator) {
        $keyfile = Join-Path -Path $Env:ProgramData -ChildPath 'ssh\administrators_authorized_keys'
    }
    else {
        $keyfile = Join-Path -Path $Env:USERPROFILE -ChildPath '.ssh\authorized_keys'
    }

    # Ensure SSH directory is present
    $sshdir = Split-Path -Path $keyfile
    if (-Not (Test-Path -Path $sshdir)) {
        Write-Output "Creating $sshdir"
        New-Item -Force -ItemType Directory -Path $sshdir
    }

    # Use `-Force` to replace all existing keys with new list
    if ((-not ($Force)) -and (Test-Path -Path $keyfile)) {
        # Merge existing keys with input keys
        $keys = (@(Get-Content -Path $keyfile) + @($AuthorizedKeys))
    }
    else {
        $keys = @($AuthorizedKeys)
    }

    # Filter duplicate keys
    $keys = @($keys | Select-Object -Unique)

    Write-Output ("Writing {0} keys to {1}" -f $keys.Length, $keyfile)
    Set-Content -Force -Path $keyfile -Value $keys

    # Set permissions on adminstrator authorized keys file
    if (Test-Administrator) {
        Get-Acl $ENV:ProgramData\ssh\ssh_host_dsa_key | Set-Acl $keyfile
    }
}

function Install-Remoting {
    <#
        .SYNOPSIS
            Enable WS-Man remoting
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param()

    Assert-Administrator
    Write-Output 'Enable PowerShell Remoting'
    Install-PowerShellRemoting.ps1
    Enable-PSRemoting
}

function Enable-PowerShellSSHRemoting {
    <#
        .SYNOPSIS
            Enable SSH PowerShell remoting
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param()

    Assert-Administrator

    # Add Powershell subsystem to sshd_config
    $sshd_config = Join-Path -Path $Env:ProgramData -ChildPath 'ssh\sshd_config'
    $lines = Get-Content -Path $sshd_config
    $subsystems = $lines -match '^Subsystem'
    $configdata = $lines -notmatch '^Subsystem'

    Write-Output 'Current subsystems:'
    $subsystems | Write-Output

    if (($subsystems -match '^Subsystem\spowershell').Length -eq 0) {
        # Add powershell to subsystems
        $subsystems += 'Subsystem	powershell	c:/progra~1/powershell/7/pwsh.exe -sshs -nologo'

        $output = foreach ($line in $configdata) {
            switch -Wildcard ($line) {
                '*subsystems' {
                    # Write subsystems block
                    $line
                    $subsystems
                }
                Default { $line }
            }
        }

        Write-Output 'Updated subsystems:'
        $subsystems | Write-Output

        Write-Debug 'sshd_config:'
        $output | Write-Debug

        # Rewrite sshd_config
        Set-Content -Force -Path $sshd_config -Value $output
        Write-Output 'Restart sshd service to enable Powershell subsystem.'
    }
    else {
        Write-Output 'Subsystem Powershell enabled '
    }
}

#endregion

#region Tools

function Install-Bin {
    <#
    .SYNOPSIS
        Create system root bin for adding tools (like /usr/local/bin on Unix)
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param()

    $usrbin = Join-Path -Path $Env:SystemDrive -ChildPath bin
    if (!(Test-Path -Path $usrbin)) {
        Write-Output "Creating $usrbin"
        New-Item -Path $usrbin -ItemType Directory
    }

    # Add to path so WSL can see it
    Update-Path @($usrbin) -SetEnv
}

function Install-CLI() {
    <#
    .SYNOPSIS
        Install CLI to ProgramFiles
    .PARAMETER Uri
        URI of zip file for CLI
    .PARAMETER Dest
        Directory to install to in Program Files
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter()]
        [string]$Uri,
        [string]$Dest
    )
    Assert-Administrator
    $destDir = Join-Path -Path $Env:ProgramFiles -ChildPath $Dest
    Install-Zip -Uri $Uri -Dest $destDir
    # Add CLI to path
    Update-Path @($destDir) -SetEnv
}

#endregion
