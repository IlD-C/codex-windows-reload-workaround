$ErrorActionPreference = "Stop"

$node = Get-ChildItem `
"$env:LOCALAPPDATA\OpenAI\Codex\runtimes\cua_node" `
-Recurse -File -Filter node.exe `
-ErrorAction SilentlyContinue |
Sort-Object LastWriteTime -Descending |
Select-Object -First 1

if (-not $node) {
    throw "Codex bundled Node.js was not found."
}

$reloadScript = Join-Path $PSScriptRoot "codex-cdp-reload.cjs"

if (-not (Test-Path $reloadScript)) {
    throw "codex-cdp-reload.cjs was not found next to this script."
}

try {
    Invoke-RestMethod `
        "http://127.0.0.1:9222/json/version" `
        -TimeoutSec 2 |
        Out-Null
}
catch {
    throw "Port 9222 is unavailable. Launch Codex with Start-Codex-Debug.ps1 first."
}

& "$($node.FullName)" "$reloadScript"
