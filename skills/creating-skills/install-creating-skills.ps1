param(
  [string]$AiWikiRoot = "<AI_WIKI_ROOT>",
  [string]$SkillName  = "creating-skills",
  [string]$Version    = "0.1.3",
  [switch]$Apply,
  [switch]$NoSelfDelete
)

$ErrorActionPreference = "Stop"

# ── Preflight ────────────────────────────────────────────
Write-Host ""
Write-Host "==> install-creating-skills" -ForegroundColor Cyan
Write-Host "Version:   $Version"
Write-Host "AI Wiki:   $AiWikiRoot"
Write-Host "Skill:     $SkillName"
Write-Host "Mode:      $(if ($Apply) { 'INSTALL' } else { 'DRY RUN' })"
Write-Host ""

$SkillRoot = Join-Path $AiWikiRoot "04_skills/universal/$SkillName"
$ValidPy   = Join-Path $SkillRoot "scripts/validate_skill.py"
$RegPy     = Join-Path $SkillRoot "scripts/rebuild_skills_registry.py"

if (-not (Test-Path -LiteralPath $SkillRoot)) {
  throw "Skill root not found: $SkillRoot"
}

if (-not $Apply) {
  Write-Host "[DRY RUN] Contents of $SkillRoot/:"
  Get-ChildItem -LiteralPath $SkillRoot -Recurse | ForEach-Object {
    Write-Host ("  {0} [{1}]" -f ($_.FullName.Replace($SkillRoot, "")), $_.GetType().Name)
  }
  exit 0
}

# ── Validate ─────────────────────────────────────────────
Write-Host "==> Validating SKILL.md" -ForegroundColor Cyan
pwsh -NoProfile -ExecutionPolicy Bypass -Command "python $ValidPy $SkillRoot"
if ($LASTEXITCODE -ne 0) {
  Write-Host "FAIL: SKILL.md validation failed — aborting." -ForegroundColor Red
  exit 1
}

# ── Rebuild registry ─────────────────────────────────────
Write-Host "==> Rebuilding skill registry" -ForegroundColor Cyan
pwsh -NoProfile -ExecutionPolicy Bypass -Command "python $RegPy --ai-wiki-root $AiWikiRoot --apply --backup"
if ($LASTEXITCODE -ne 0) {
  Write-Host "WARN: registry rebuild exited non-zero (may be benign on first run)." -ForegroundColor Yellow
}

# ── Report ───────────────────────────────────────────────
Write-Host ""
Write-Host "PASS: install-creating-skills $Version" -ForegroundColor Green
Write-Host "  Skill root:  $SkillRoot"
Write-Host "  Registry:    $AiWikiRoot/03_indexes/skills/skills-registry.json"

if (-not $NoSelfDelete -and $PSCommandPath) {
  try { Remove-Item -LiteralPath $PSCommandPath -Force -ErrorAction SilentlyContinue } catch {}
}
