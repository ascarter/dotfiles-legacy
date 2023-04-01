if ($host.Name -eq 'ConsoleHost') {
    Import-Module PSReadLine
    Set-PSReadLineOption -EditMode Emacs
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineOption -PredictionSource History
    # Set-PSReadLineOption -PredictionViewStyle ListView
}

# Import scripts
. $PSScriptRoot/sudo.ps1
. $PSScriptRoot/helpers.ps1
. $PSScriptRoot/developer.ps1
. $PSScriptRoot/git.ps1
. $PSScriptRoot/installers.ps1
. $PSScriptRoot/powershell.ps1

#region Prompt

if (Get-Module -Name posh-git -ListAvailable) {
    Import-Module posh-git

    function prompt {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = [Security.Principal.WindowsPrincipal] $identity

        $GitPromptSettings.DefaultPromptPrefix.Text = "`n[$Env:COMPUTERNAME] "
        $GitPromptSettings.DefaultPromptBeforeSuffix.Text = '`n' + $(
            if (Test-Path variable:/PSDebugContext) {
                Write-Prompt '[DBG]: ' -ForegroundColor Red
            }
            elseif ($principal.IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
                Write-Prompt '[ADMIN]: ' -ForegroundColor Magenta
            }
        )
        $GitPromptSettings.DefaultPromptSuffix.Text = 'PS > '
        $prompt = & $GitPromptScriptBlock
        if ($prompt) { $prompt } else { ' ' }
    }
}
else {
    # Default prompt with ADMIN and DBG
    function prompt {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = [Security.Principal.WindowsPrincipal] $identity

        $(if (Test-Path variable:/PSDebugContext) { '[DBG]: ' }
            elseif ($principal.IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) { '[ADMIN]: ' }
            else { '' }
        ) + 'PS ' + $(Get-Location) +
        $(if ($NestedPromptLevel -ge 1) { '>>' }) + '> '
    }
}

#endregion
