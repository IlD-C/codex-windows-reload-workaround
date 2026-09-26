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

    $env:Path =
        [Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
        [Environment]::GetEnvironmentVariable("Path","User")
}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw "GitHub CLI installation finished, but gh is not available yet. Open a new PowerShell window and run this script again."
}

# gh returns a non-zero exit code when the user is not logged in.
# Temporarily avoid treating that expected status check as a terminating error.
$oldPreference = $ErrorActionPreference
$ErrorActionPreference = "Continue"
gh auth status *> $null
$notLoggedIn = ($LASTEXITCODE -ne 0)
$ErrorActionPreference = $oldPreference

if ($notLoggedIn) {
    Write-Host "GitHub login is required. A browser sign-in will open."
    gh auth login --hostname github.com --web --git-protocol https

    if ($LASTEXITCODE -ne 0) {
        throw "GitHub login failed."
    }
}

if (-not (Test-Path ".git")) {
    git init
}

git add .

$status = git status --porcelain
if ($status) {
    git commit -m "Update public workaround release"

    if ($LASTEXITCODE -ne 0) {
        throw "git commit failed. Check your Git user.name and user.email configuration."
    }
}

# If origin already exists, just push.
$remotes = @(git remote)
if ($remotes -contains "origin") {
    $existingOrigin = git remote get-url origin
    Write-Host "Using existing origin:"
    Write-Host $existingOrigin

    git push -u origin HEAD

    if ($LASTEXITCODE -ne 0) {
        throw "git push failed."
    }

    Write-Host ""
    Write-Host "Published successfully."
    gh repo view --web
    exit
}

# No origin yet. Determine the signed-in GitHub account.
$owner = gh api user --jq .login
if ($LASTEXITCODE -ne 0 -or -not $owner) {
    throw "Unable to determine the signed-in GitHub account."
}

$fullRepo = "$owner/$RepoName"

# The repository may already exist even when the local clone has no origin.
$oldPreference = $ErrorActionPreference
$ErrorActionPreference = "Continue"
gh repo view $fullRepo *> $null
$repoExists = ($LASTEXITCODE -eq 0)
$ErrorActionPreference = $oldPreference

if ($repoExists) {
    Write-Host "GitHub repository already exists: $fullRepo"
    git remote add origin "https://github.com/$fullRepo.git"

    git push -u origin HEAD

    if ($LASTEXITCODE -ne 0) {
        throw "git push failed."
    }
}
else {
    gh repo create $RepoName "--$Visibility" --source . --remote origin --push

    if ($LASTEXITCODE -ne 0) {
        throw "GitHub repository creation or push failed."
    }
}

Write-Host ""
Write-Host "Published successfully."
gh repo view --web
