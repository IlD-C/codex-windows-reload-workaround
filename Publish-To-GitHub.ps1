param(
    [string]$RepoName = "codex-windows-reload-workaround",
    [ValidateSet("public","private")]
    [string]$Visibility = "public"
)

$ErrorActionPreference = "Stop"
$repoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $repoDir

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "Git is required. Install Git for Windows first."
}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "GitHub CLI not found. Installing with winget..."
    winget install --id GitHub.cli -e --accept-source-agreements --accept-package-agreements
    $env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
                [Environment]::GetEnvironmentVariable("Path","User")
}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw "GitHub CLI installation finished but gh is not available yet. Open a new PowerShell window and run this script again."
}

gh auth status 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "GitHub login is required. A browser window will open."
    gh auth login --web --git-protocol https
}

if (-not (Test-Path ".git")) {
    git init
}

git add .

$status = git status --porcelain
if ($status) {
    git commit -m "Initial public workaround release"
}

$existingOrigin = git remote get-url origin 2>$null

if ($LASTEXITCODE -eq 0 -and $existingOrigin) {
    Write-Host "An origin remote already exists:"
    Write-Host $existingOrigin
    git push -u origin HEAD
    exit
}

gh repo create $RepoName "--$Visibility" --source . --remote origin --push

Write-Host ""
Write-Host "Published successfully."
gh repo view --web
