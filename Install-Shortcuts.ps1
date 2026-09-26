$ErrorActionPreference = "Stop"

$repo = Split-Path -Parent $MyInvocation.MyCommand.Path
$desktop = [Environment]::GetFolderPath("Desktop")
$shell = New-Object -ComObject WScript.Shell

function New-Shortcut($name, $script) {
    $shortcut = $shell.CreateShortcut((Join-Path $desktop "$name.lnk"))
    $shortcut.TargetPath = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
    $shortcut.Arguments = '-NoProfile -ExecutionPolicy Bypass -File "' + (Join-Path $repo $script) + '"'
    $shortcut.WorkingDirectory = $repo
    $shortcut.Save()
}

New-Shortcut "1 Start Codex (Debug)" "Start-Codex-Debug.ps1"
New-Shortcut "2 Fix Codex Spinner" "Fix-Codex.ps1"

Write-Host "Desktop shortcuts created."
