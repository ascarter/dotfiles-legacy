# Enable winget completion
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)

        [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
        $Local:word = $wordToComplete.Replace('"', '""')
        $Local:ast = $commandAst.ToString().Replace('"', '""')
        winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}

function Get-CmdletAlias {
    <#
        .SYNOPSIS
            List aliases for any cmdlet
    #>
    [CmdletBinding()]
    [Alias("fal")]
    param(
        [string]$Name
    )
    Get-Alias |
    Where-Object -FilterScript { $_.Definition -like "$Name" } |
    Format-Table -Property Definition, Name -AutoSize
}

function Get-Uname {
    <#
        .SYNOPSIS
            Emulate Unix uname
    #>
    [CmdletBinding()]
    [Alias("uname")]
    param()
    Get-CimInstance Win32_OperatingSystem | Select-Object 'Caption', 'CSName', 'Version', 'BuildType', 'OSArchitecture' | Format-Table
}


function Invoke-SSHWithPassword {
    <#
        .SYNOPSIS
            Execute SSH using password authentication
    #>
    [CmdletBinding()]
    [Alias("sshpw")]
    param (
        [string[]]
        [Parameter(Position=1, ValueFromRemainingArguments)]
        $Remaining
    )
    ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no $Remaining
}

function Get-LastCommand {
    [CmdletBinding()]
    [Alias("lc")]
    param()
    (Get-History | Select-Object -Last 1).CommandLine
}

function Select-Command {
    [CmdletBinding()]
    [Alias("slc")]
    param()
    & (Get-History | Sort-Object -Property Id -Descending | Select-Object -Property CommandLine | Out-ConsoleGridView -OutputMode Single -Title "Select Command").CommandLine
}

# Unix aliases
Set-Alias -Name ll -Value Get-ChildItem
Set-Alias -Name which -Value Get-Command

# macOS aliases
Set-Alias -Name pbcopy -Value Set-Clipboard
Set-Alias -Name pbpaste -Value Get-Clipboard
