[CmdletBinding()]
param(
  [string]$WikiRoot = "<AI_WIKI_ROOT>",
  [Parameter(Mandatory = $true)]
  [string]$SourceSlug,
  [Parameter(Mandatory = $true)]
  [string]$SourceUrl,
  [switch]$Apply
)

$ErrorActionPreference = "Stop"

function Write-Step([string]$Message) {
  Write-Host ""
  Write-Host "==> $Message"
}

function Normalize-KeyPart($Value) {
  if ($null -eq $Value) { return "" }
  return [string]$Value
}

$Index = Join-Path $WikiRoot "03_indexes\skills\external-sources\external-candidate-skills.json"

Write-Host "AI Wiki external candidate index repair v0.1.0"
Write-Host ("Mode: " + ($(if ($Apply) { "APPLY" } else { "DRY-RUN" })))
Write-Host "WikiRoot: $WikiRoot"
Write-Host "Index: $Index"
Write-Host "SourceSlug: $SourceSlug"
Write-Host "SourceUrl: $SourceUrl"

Write-Step "Checking input"
if (!(Test-Path $WikiRoot)) {
  throw "Missing WikiRoot: $WikiRoot"
}
if (!(Test-Path $Index)) {
  throw "Missing candidate index: $Index"
}

$json = Get-Content $Index -Raw | ConvertFrom-Json

Write-Step "Normalizing sources"
$seenSources = @{}
$sources = @()
foreach ($s in @($json.sources)) {
  $key = if ($s.source_slug) {
    [string]$s.source_slug
  } elseif ($s.source_url) {
    [string]$s.source_url
  } else {
    ($s | ConvertTo-Json -Compress)
  }

  if (!$seenSources.ContainsKey($key)) {
    $seenSources[$key] = $true
    $sources += $s
  }
}

Write-Step "Normalizing candidates"
$seenCandidates = @{}
$candidates = @()
$sourceSlugAdded = 0
$duplicatesRemoved = 0

foreach ($c in @($json.candidates)) {
  if ($c.source_url -eq $SourceUrl -and -not ($c.PSObject.Properties.Name -contains "source_slug")) {
    $c | Add-Member -NotePropertyName source_slug -NotePropertyValue $SourceSlug
    $sourceSlugAdded++
  }

  $keyParts = @(
    (Normalize-KeyPart $c.source_slug),
    (Normalize-KeyPart $c.source_url),
    (Normalize-KeyPart $c.slug),
    (Normalize-KeyPart $c.local_candidate_path),
    (Normalize-KeyPart $c.promotion_target)
  ) | Where-Object { $_ -ne "" }

  $key = ($keyParts -join "|")

  if (!$seenCandidates.ContainsKey($key)) {
    $seenCandidates[$key] = $true
    $candidates += $c
  } else {
    $duplicatesRemoved++
  }
}

Write-Host "source_slug additions: $sourceSlugAdded"
Write-Host "duplicates removed: $duplicatesRemoved"

if ($Apply) {
  Write-Step "Backing up and writing index"
  $Backup = "$Index.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
  Copy-Item $Index $Backup -Force

  $json.sources = $sources
  $json.candidates = $candidates
  $json.updated_at = (Get-Date).ToString("o")
  $json | ConvertTo-Json -Depth 30 | Set-Content $Index -Encoding UTF8

  Write-Host "Backup: $Backup"
  Write-Host "PASS: Fixed external candidate index"
} else {
  Write-Step "Dry run complete"
  Write-Host "No files changed. Re-run with -Apply to write the repaired index."
}

Write-Step "Verification preview"
$candidates |
  Where-Object source_slug -eq $SourceSlug |
  Select-Object slug, name, status, review_only, local_candidate_path, promotion_target |
  Format-Table -AutoSize
