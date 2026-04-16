# push-work-repo.ps1
# Initializes the work repo as a git repo and pushes to PedroRamosProfisee/Opencode-config-work
#
# REQUIREMENTS:
#   - Git must be installed and on PATH
#   - You must be authenticated to GitHub as PedroRamosProfisee (or have push access to the repo)
#   - The remote repo https://github.com/PedroRamosProfisee/Opencode-config-work must already exist
#     (create it at https://github.com/new if not - do NOT initialize with README)
#
# USAGE:
#   .\push-work-repo.ps1
#   .\push-work-repo.ps1 -Message "your commit message"
#   .\push-work-repo.ps1 -Branch "main" -Message "initial unified config"

param(
    [string]$Branch = "main",
    [string]$Message = "chore: unify config with live install - MM pipeline, rules, magic-context",
    [string]$Remote = "https://github.com/PedroRamosProfisee/Opencode-config-work.git"
)

$RepoPath = $PSScriptRoot

Write-Host ""
Write-Host "=== Work Repo Push Script ===" -ForegroundColor Cyan
Write-Host "Path   : $RepoPath"
Write-Host "Remote : $Remote"
Write-Host "Branch : $Branch"
Write-Host "Message: $Message"
Write-Host ""

$confirm = Read-Host "Review the above. Proceed? (y/N)"
if ($confirm -ne 'y' -and $confirm -ne 'Y') {
    Write-Host "Aborted." -ForegroundColor Yellow
    exit 0
}

Set-Location $RepoPath

if (-not (Test-Path ".git")) {
    Write-Host "`nInitializing git repo..." -ForegroundColor Green
    git init -b $Branch
    if ($LASTEXITCODE -ne 0) { Write-Host "git init failed." -ForegroundColor Red; exit 1 }
} else {
    Write-Host "`nGit repo already initialized." -ForegroundColor Yellow
}

$existingRemote = git remote get-url origin 2>$null
if ($existingRemote) {
    Write-Host "Updating remote origin to $Remote" -ForegroundColor Green
    git remote set-url origin $Remote
} else {
    Write-Host "Adding remote origin: $Remote" -ForegroundColor Green
    git remote add origin $Remote
}

Write-Host "`nStaging all files..." -ForegroundColor Green
git add -A

Write-Host "`nFiles staged:" -ForegroundColor Cyan
git status --short

Write-Host ""
$confirm2 = Read-Host "Commit and push? (y/N)"
if ($confirm2 -ne 'y' -and $confirm2 -ne 'Y') {
    Write-Host "Staged but not committed. Run git commit manually when ready." -ForegroundColor Yellow
    exit 0
}

git commit -m $Message
if ($LASTEXITCODE -ne 0) { Write-Host "git commit failed." -ForegroundColor Red; exit 1 }

Write-Host "`nPushing to $Remote ($Branch)..." -ForegroundColor Green
git push -u origin $Branch
if ($LASTEXITCODE -ne 0) {
    Write-Host "`nPush failed. Common causes:" -ForegroundColor Red
    Write-Host "  - Repo does not exist yet at $Remote" -ForegroundColor Yellow
    Write-Host "    Create it at https://github.com/new (do NOT add README/gitignore)" -ForegroundColor Yellow
    Write-Host "  - Not authenticated as PedroRamosProfisee" -ForegroundColor Yellow
    Write-Host "    Run: gh auth switch  OR  gh auth login" -ForegroundColor Yellow
    exit 1
}

Write-Host "`nDone! Work repo pushed to $Remote" -ForegroundColor Green
