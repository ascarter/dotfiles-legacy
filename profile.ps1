# Bootstrap modules

if (!(Get-Module -Name PowerShellGet -ListAvailable)) {
  Install-Module -Name PowerShellGet -Scope CurrentUser -Force -AllowClobber
}

if (!(Get-Module -Name Microsoft.PowerShell.GraphicalTools -ListAvailable)) {
  Install-Module Microsoft.PowerShell.GraphicalTools -Scope CurrentUser -Force -AllowClobber
}

if (!(Get-Module -Name posh-git -ListAvailable)) {
  Install-Module -Name posh-git -Scope CurrentUser -AllowPrerelease -Force
}

# Enable Git to use Windows SSH
# [Environment]::SetEnvironmentVariable("GIT_SSH", "$((Get-Command ssh).Source)", [System.EnvironmentVariableTarget]::User)
Set-Item -Path Env:GIT_SSH -Value ((Get-Command ssh).Source)

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

function cdDotfiles() {
  Set-Location -Path (Join-Path $env:USERPROFILE -ChildPath ".config\dotfiles")
}

Set-Alias -Name fork -Value Start-Fork
Set-Alias -Name insomnia -Value Start-Insomnia
Set-Alias -Name dotf -Value cdDotfiles

# Unix alias helpers
Set-Alias -Name ll -Value Get-ChildItem
Set-Alias -Name which -Value Get-Command

# Set keybindings
Set-PSReadLineOption -EditMode Emacs

# Helper functions

function Start-ProfileEdit { code -n $PROFILE.CurrentUserAllHosts }

function Update-Profiles() {
  $setprofiles = Join-Path -Path $env:USERPROFILE -ChildPath .config\dotfiles\setprofiles.ps1
  if (Test-Path -Path $setprofiles) { Start-Process -FilePath powershell -ArgumentList $setprofiles -Wait -NoNewWindow }
}

function Get-CmdletAlias ($cmdletname) {
  Get-Alias | Where-Object -FilterScript { $_.Definition -like "$cmdletname" } | Format-Table -Property Definition, Name -AutoSize
}

# Default prompt with ADMIN and DBG
# function prompt {
#   $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
#   $principal = [Security.Principal.WindowsPrincipal] $identity
#
#   $(if (Test-Path variable:/PSDebugContext) { '[DBG]: ' }
#     elseif($principal.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { "[ADMIN]: " }
#     else { '' }
#   ) + 'PS ' + $(Get-Location) +
#     $(if ($NestedPromptLevel -ge 1) { '>>' }) + '> '
# }

# Configure posh-git
if (Get-Module -Name posh-git -ListAvailable) {
  Import-Module posh-git

  function prompt {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal] $identity

    $GitPromptSettings.DefaultPromptPrefix.Text = "`n[$env:COMPUTERNAME] "
    $GitPromptSettings.DefaultPromptBeforeSuffix.Text = '`n' + $(
      if (Test-Path variable:/PSDebugContext) { Write-Prompt '[DBG]: ' -ForegroundColor Red }
      elseif ($principal.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Write-Prompt '[ADMIN]: ' -ForegroundColor Magenta }
    )
    $GitPromptSettings.DefaultPromptSuffix.Text = "PS > "
    $prompt = & $GitPromptScriptBlock
    if ($prompt) { $prompt } else { ' ' }
  }
}
