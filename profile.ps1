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

# Set DOTFILES environment varible
Set-Item -Path Env:DOTFILES -Value (Join-Path $env:USERPROFILE -ChildPath ".config\dotfiles")

# Enable Git to use Windows SSH
# [Environment]::SetEnvironmentVariable("GIT_SSH", "$((Get-Command ssh).Source)", [System.EnvironmentVariableTarget]::User)
Set-Item -Path Env:GIT_SSH -Value ((Get-Command ssh).Source)

# Set EDITOR and VISUAL
Set-Item -Path Env:EDITOR -Value ((Get-Command vim).Source)
Set-Item -Path Env:VISUAL -Value ((Get-Command code).Source)

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
  Set-Location -Path $env:DOTFILES
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
  $setprofiles = Join-Path -Path $env:DOTFILES -ChildPath setprofiles.ps1
  if (Test-Path -Path $setprofiles) {
    Start-Process -FilePath (Get-Process -Id $pid).ProcessName -ArgumentList "$setprofiles -Force"  -Wait -NoNewWindow
  }
}

function Update-VSCodeExtensions() {
  $extensions = Get-Content -Path (Join-Path -Path $env:DOTFILES -ChildPath '.\vscode-extensions.txt')
  foreach ($extension in $extensions) { code --install-extension $extension }
}

# gitconfig

function gc_set([string]$Key, [string]$Value) {
  git config --global $Key $Value | Out-Null
}

function gc_update([string]$Key, [string]$Value) {
  git config --global --unset $Key
  gc_set $Key $Value
}

function gc_prompt([string]$Key, [string]$Prompt) {
  $default = git config --global --get $Key
  $msg = if ($null -eq $default) { $Prompt } else { "$Prompt (default $default)" }
  $value = Read-Host -Prompt $msg
  if ($null -eq $value) { $value = $default }
  gc_set $Key $value
}

function Update-GitConfig() {
  # Include defaults and aliases
  gc_update 'include.path' (Join-Path -Path $env:DOTFILES -ChildPath gitconfig)

  # User info
  gc_prompt 'user.name' "User name"
  gc_prompt 'user.email' "Email"

  # Platform configuration
  gc_set 'gui.fontui' '-family \"Segoe UI\" -size 10 -weight normal -slant roman -underline 0 -overstrike 0'
  gc_set 'gui.fontdiff' '-family \"Cascadia Code\" -size 10 -weight normal -slant roman -underline 0 -overstrike 0'

  # Show full gitconfig
  Write-Output $(git config --global --list)
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
