function Install-SSH {
    <#
    .SYNOPSIS
        Install SSH
    .DESCRIPTION
        Long description
    .EXAMPLE
        PS C:\> <example usage>
        Explanation of what the example does
    .INPUTS
        Inputs (if any)
    .OUTPUTS
        Output (if any)
    .NOTES
        General notes
    #>
    [CmdletBinding()]
    param (

    )
    
    begin {
        
    }
    
    process {
        # Install OpenSSH
        # https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse
        Add-WindowsCapability -Online -Name OpenSSH.Client
        Add-WindowsCapability -Online -Name OpenSSH.Server

        # Add firewall rule
        New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22

        # Install OpenSSHUtils
        Install-Module -Force OpenSSHUtils -Scope AllUsers

        # Configure SSH Agent
        Set-Service -Name ssh-agent -StartupType 'Automatic'
        Start-Service ssh-agent

        # Configure SSH server
        Set-Service -Name sshd -StartupType 'Automatic'
        Start-Service sshd
    }
    
    end {
        
    }
}
