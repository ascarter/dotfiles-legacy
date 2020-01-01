function Install-Chocolatey {
    <#
    .SYNOPSIS
        Install Chocolatey
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
        # Set-ExecutionPolicy Bypass -Scope Process -Force
        # Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

        Set-ExecutionPolicy AllSigned -Scope Process -Force
        Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression

        
    }
    
    process {
        
    }
    
    end {
        
    }
}
