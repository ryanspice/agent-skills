param(
  [string]$ArchiveName = "package-name-v0.1.0.tar.gz",
  [string]$SourceDir = "<DOWNLOADS_ROOT>",
  [string]$DestinationDir = "<DEV_ROOT>/project-name",
  [switch]$Apply,
  [switch]$NoSelfDelete
)

$ErrorActionPreference = "Stop"

function Write-Step([string]$Text) {
  Write-Host ""
  Write-Host "==> $Text" -ForegroundColor Cyan
}

$ArchivePath = Join-Path $SourceDir $ArchiveName
$StageDir = Join-Path $SourceDir ([IO.Path]::GetFileNameWithoutExtension([IO.Path]::GetFileNameWithoutExtension($ArchiveName)))
$BackupDir = Join-Path $SourceDir ("backup-" + (Get-Date -Format "yyyyMMdd-HHmmss"))

Write-Step "Checking paths"
if (-not (Test-Path -LiteralPath $ArchivePath)) { throw "Archive not found: $ArchivePath" }
New-Item -ItemType Directory -Path $StageDir -Force | Out-Null
New-Item -ItemType Directory -Path $DestinationDir -Force | Out-Null

Write-Step "Extracting"
tar -xzf $ArchivePath -C $StageDir

Write-Step "Planning"
Write-Host "Source:      $ArchivePath"
Write-Host "Stage:       $StageDir"
Write-Host "Destination: $DestinationDir"
Write-Host "Backup:      $BackupDir"

if (-not $Apply) {
  Write-Host "[DRY RUN] Add -Apply to copy files." -ForegroundColor Yellow
  exit 0
}

Write-Step "Applying"
# TODO: copy intended files only. Back up touched paths first.

Write-Step "Cleaning up"
Remove-Item -LiteralPath $StageDir -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath $ArchivePath -Force -ErrorAction SilentlyContinue

Write-Host "PASS: applied package" -ForegroundColor Green

if (-not $NoSelfDelete -and $PSCommandPath) {
  try { Remove-Item -LiteralPath $PSCommandPath -Force -ErrorAction SilentlyContinue } catch {}
}
