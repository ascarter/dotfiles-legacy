# Enable Git to use Windows SSH
# [Environment]::SetEnvironmentVariable("GIT_SSH", "$((Get-Command ssh).Source)", [System.EnvironmentVariableTarget]::User)
Set-Item -Path Env:GIT_SSH -Value ((Get-Command ssh).Source)

# Configure posh-git
Import-Module posh-git

# Alias behavoirs

function Start-Fork([string]$MyRepo = $PWD) {
  $exe = $Env:LOCALAPPDATA + '\Fork\Fork.exe'
  $target = Convert-Path -Path $MyRepo
  & $exe $target
}

function Start-Insomnia() {
  $exe = $Env:HOMEPATH + '\bin\insomnia.exe'
  Start-Process -FilePath $exe -WindowStyle Minimized
}

Set-Alias -Name fork -Value Start-Fork
Set-Alias -Name insomnia -Value Start-Insomnia

# Helper functions

function StartPro { code -n $PROFILE.CurrentUserAllHosts }

# Enable Windows PowerShell modules
# function Enable-Windows-PowerShell {
#   Install-Module WindowsPSModulePath -Force -Scope CurrentUser 
#   Add-WindowsPSModulePath
# }

function Get-CmdletAlias ($cmdletname) {
  Get-Alias | Where-Object -FilterScript { $_.Definition -like "$cmdletname" } | Format-Table -Property Definition, Name -AutoSize
}

# function prompt {
#   $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
#   $principal = [Security.Principal.WindowsPrincipal] $identity

#   $(if (Test-Path variable:/PSDebugContext) { '[DBG]: ' }
#     elseif($principal.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { "[ADMIN]: " }
#     else { '' }
#   ) + 'PS ' + $(Get-Location) +
#     $(if ($NestedPromptLevel -ge 1) { '>>' }) + '> '
# }

function prompt {
  $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = [Security.Principal.WindowsPrincipal] $identity

  $GitPromptSettings.DefaultPromptPrefix = '`n'
  $GitPromptSettings.DefaultPromptBeforeSuffix.Text = '`n'
  $GitPromptSettings.WindowTitle = { param($GitStatus, [bool]$IsAdmin) "$(if ($IsAdmin) {'Admin: '})$(if ($GitStatus) {"$($GitStatus.RepoName) [$($GitStatus.Branch)]"} else {Get-PromptPath}) ~ PowerShell $($PSVersionTable.PSEdition) $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)" }

  $prompt = $(
    if (Test-Path variable:/PSDebugContext) { Write-Prompt '[DBG]: ' }
    elseif ($principal.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Write-Prompt '[ADMIN]: ' }
  )
  $prompt += & $GitPromptScriptBlock
  if ($prompt) { $prompt } else { '' }
}
