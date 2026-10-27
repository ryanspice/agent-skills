$ScriptPath = "<DOWNLOADS_ROOT>/<script-name>-v0.1.0.ps1"

@'
param(
  [switch]$Apply,
  [switch]$NoSelfDelete
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "==> <Task name>" -ForegroundColor Cyan
Write-Host "Mode: $(if ($Apply) { 'APPLY' } else { 'DRY RUN' })"

# TODO: implement checks/work here.

if (-not $Apply) {
  Write-Host "[DRY RUN] No changes made." -ForegroundColor Yellow
  exit 0
}

Write-Host "PASS: completed" -ForegroundColor Green

if (-not $NoSelfDelete -and $PSCommandPath) {
  try { Remove-Item -LiteralPath $PSCommandPath -Force -ErrorAction SilentlyContinue } catch {}
}
'@ | Set-Content -LiteralPath $ScriptPath -Encoding utf8NoBOM

pwsh -NoProfile -ExecutionPolicy Bypass -File $ScriptPath
