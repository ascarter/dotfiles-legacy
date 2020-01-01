<#
.SYNOPSIS
    Install script for Windows 10
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

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '.\DotfilesModule\DotfilesModule.psd1') -Verbose

function Install-Dotfiles {
	<#
    .SYNOPSIS
        Install dotfiles to user account
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
		# Verify administrator

		# Turn on optional Windows features
		Enable-WindowsFeatures

		# Install PowerShell modules
		Install-PowerShellModules

		# Run installers
		Install-SSH
		Install-WSL
		Install-DotnetCore
		Install-Chocolatey
		Install-AzureCLI

		# Link user profile
		if (!(Test-Path -Path $PROFILE.CurrentUserAllHosts)) {
			New-Item -ItemType SymbolicLink -Path $PROFILE.CurrentUserAllHosts -Target (Join-Path -Path $PSScriptRoot -ChildPath 'profile.ps1')
		}

		# Link JEA role
		$sudoJEALink = Join-Path $env:HOME 'Documents\PowerShell\Modules\SudoJEA'
		if (!(Test-Path -Path $sudoJEALink)) {
			New-Item -ItemType SymbolicLink -Path $sudoJEALink -Target (Resolve-Path .\windows\SudoJEA)
		}

		# Register JEA role
		$sudoJEAConfig = (Resolve-Path .\SudoJEAConfig.pssc)
		$roles = @{ "$env:USERDNSDOMAIN\$env:USERNAME" = @{ RoleCapabilities = 'SudoJEA' } }
		New-PSSessionConfigurationFile -SessionType RestrictedRemoteServer -Path $sudoJEAConfig -RunAsVirtualAccount -TranscriptDirectory 'C:\ProgramData\JEAConfiguration\Transcripts' -RoleDefinitions $roles -RequiredGroups @{ Or = '2FA-logon', 'smartcard-logon' } -MountUserDrive $true
		Test-PSSessionConfigurationFile -Path $sudoJEAConfig
		Register-PSSessionConfiguration -Path $sudoJEAConfig -Name 'SudoJEA' -Force
		Remove-Item $sudoJEAConfig
	}
    
	end {
        
	}
}

function Enable-WindowsFeatures {
	<#
	.SYNOPSIS
		Enable Windows features
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
		# Enable PowerShell remoting
		Enable-PSRemoting
		
		# Enable Hyper-V platform and tools
		Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All		
	}
	
	end {
		
	}
}

function Install-PowerShellModules {
	<#
	.SYNOPSIS
		Install PowerShell extension modules
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
		# Posh-Git
		Install-Module -Name posh-git -Scope CurrentUser -AllowPrerelease -Force
	}
	
	process {
		
	}
	
	end {
		
	}
}

Install-Dotfiles