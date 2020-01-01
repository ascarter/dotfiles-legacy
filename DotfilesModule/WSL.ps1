function Install-WSL {
    <#
    .SYNOPSIS
        Enable WSL
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
        # Enable WSL
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
        Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform

        # Set WSL 2 as default version
        wsl --set-default-version 2

        # Install Ubuntu 18.04
        Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1804 -OutFile Ubuntu-1804.appx -UseBasicParsing
        Add-AppxPackage .\Ubuntu-1804.appx
    }
    
    end {
        
    }
}
