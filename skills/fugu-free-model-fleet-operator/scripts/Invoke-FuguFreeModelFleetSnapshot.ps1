#Requires -Version 7.0
[CmdletBinding()]
param(
  [Parameter(Mandatory)][string]$AiWikiRoot,
  [string]$OutputRoot,
  [string]$SnapshotId,
  [string]$ProviderCatalogJson,
  [string]$AdapterPath = $env:FUGU_ADAPTER_PATH,
  [string]$PolicyPath = $env:FUGU_POLICY_PATH,
  [string]$SourcePath = $env:FUGU_SOURCE_PATH,
  [string]$ManifestPath = $env:FUGU_MANIFEST_PATH,
  [string]$FleetPolicyPath = $env:FUGU_FLEET_POLICY_PATH,
  [string]$T3OpsPath = $env:T3_OPS_PATH,
  [string]$T3UpdatePath = $env:T3_UPDATE_PATH,
  [string]$OpenCodePath = $env:OPENCODE_CONFIG_PATH,
  [string]$HermesRoot = $env:HERMES_ROOT,
  [string]$T3UserdataRoot = $env:T3_USERDATA_ROOT,
  [string]$RuntimeRoot = $env:FUGU_RUNTIME_ROOT,
  [string]$BlogRoot,
  [switch]$RefreshFuguCatalog
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Resolve-ExistingDirectory {
  param([Parameter(Mandatory)][string]$Path)

  if ([string]::IsNullOrWhiteSpace($Path)) {
    throw 'A required directory path was empty.'
  }
  if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
    throw "Directory not found: $Path"
  }
  return (Resolve-Path -LiteralPath $Path).Path
}

function Ensure-OutputDirectory {
  param([Parameter(Mandatory)][string]$Path)

  if ([string]::IsNullOrWhiteSpace($Path)) {
    throw 'OutputRoot was empty.'
  }
  if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
    [void](New-Item -ItemType Directory -Path $Path -Force)
  }
  return (Resolve-Path -LiteralPath $Path).Path
}

function Get-FileFingerprint {
  param([Parameter(Mandatory)][string]$Path)

  if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
    return [pscustomobject]@{
      path = $Path
      present = $false
      length = $null
      last_write_time_utc = $null
      sha256 = $null
    }
  }

  $item = Get-Item -LiteralPath $Path
  $hash = Get-FileHash -LiteralPath $Path -Algorithm SHA256
  return [pscustomobject]@{
    path = $item.FullName
    present = $true
    length = $item.Length
    last_write_time_utc = $item.LastWriteTimeUtc.ToString('o')
    sha256 = $hash.Hash
  }
}

function Get-CommandRecord {
  param([Parameter(Mandatory)][string]$Name)

  $command = Get-Command $Name -ErrorAction SilentlyContinue | Select-Object -First 1
  if (-not $command) {
    return [pscustomobject]@{ name = $Name; present = $false; source = $null; version = $null }
  }

  $version = $null
  try {
    if ($command.Version) { $version = $command.Version.ToString() }
  } catch { $version = $null }

  return [pscustomobject]@{
    name = $Name
    present = $true
    source = $command.Source
    version = $version
  }
}

function Get-HermesProfileRecord {
  param([Parameter(Mandatory)][System.IO.DirectoryInfo]$Directory)

  $configPath = Join-Path $Directory.FullName 'config.yaml'
  $authPath = Join-Path $Directory.FullName 'auth.json'
  $envPath = Join-Path $Directory.FullName '.env'
  $text = if (Test-Path -LiteralPath $configPath -PathType Leaf) {
    Get-Content -LiteralPath $configPath -Raw
  } else { '' }

  $providerMatch = [regex]::Match($text, '(?m)^\s*provider:\s*(?<value>[^#\r\n]+)')
  $defaultMatch = [regex]::Match($text, '(?m)^\s*default:\s*(?<value>[^#\r\n]+)')
  $modelMatch = [regex]::Match($text, '(?m)^\s*model:\s*(?<value>[^#\r\n]+)')
  $modelValue = if ($defaultMatch.Success) { $defaultMatch.Groups['value'].Value.Trim() } elseif ($modelMatch.Success) { $modelMatch.Groups['value'].Value.Trim() } else { $null }

  return [pscustomobject]@{
    name = $Directory.Name
    config_present = Test-Path -LiteralPath $configPath -PathType Leaf
    auth_metadata_present = Test-Path -LiteralPath $authPath -PathType Leaf
    env_present = Test-Path -LiteralPath $envPath -PathType Leaf
    provider = if ($providerMatch.Success) { $providerMatch.Groups['value'].Value.Trim() } else { $null }
    model_or_default = $modelValue
    config_sha256 = if (Test-Path -LiteralPath $configPath -PathType Leaf) { (Get-FileHash -LiteralPath $configPath -Algorithm SHA256).Hash } else { $null }
  }
}

function Get-TextLines {
  param([string[]]$Lines)
  if (-not $Lines) { return @() }
  return @($Lines | Where-Object { $_ -and $_.Trim().Length -gt 0 } | Select-Object -First 200)
}

function Get-OptionalJsonProperty {
  param(
    [Parameter(Mandatory)]$Object,
    [Parameter(Mandatory)][string]$Name
  )

  $property = $Object.PSObject.Properties[$Name]
  if ($property) { return $property.Value }
  return $null
}

$resolvedAiWikiRoot = Resolve-ExistingDirectory -Path $AiWikiRoot
if ([string]::IsNullOrWhiteSpace($OutputRoot)) {
  $OutputRoot = Join-Path $resolvedAiWikiRoot '05_Outputs\fugu-free-model-fleet'
}
$resolvedOutputRoot = Ensure-OutputDirectory -Path $OutputRoot

$now = Get-Date
if ([string]::IsNullOrWhiteSpace($SnapshotId)) {
  $SnapshotId = $now.ToString('yyyy-MM-dd-HHmmss')
}
if ($SnapshotId -notmatch '^[0-9A-Za-z._-]+$') {
  throw "SnapshotId contains unsupported characters: $SnapshotId"
}

$snapshotDirectory = Join-Path $resolvedOutputRoot $SnapshotId
$resolvedSnapshotDirectory = Ensure-OutputDirectory -Path $snapshotDirectory

$adapterPath = $AdapterPath
$policyPath = $PolicyPath
$sourcePath = $SourcePath
$manifestPath = $ManifestPath
$fleetPolicyPath = $FleetPolicyPath
$t3OpsPath = $T3OpsPath
$t3UpdatePath = $T3UpdatePath
$openCodePath = $OpenCodePath
$hermesRoot = $HermesRoot
$hermesConfigPath = Join-Path $hermesRoot 'config.yaml'
$hermesProfilesRoot = Join-Path $hermesRoot 'profiles'
$t3UserdataRoot = $T3UserdataRoot
$blogRoot = if ([string]::IsNullOrWhiteSpace($BlogRoot)) { Join-Path $resolvedAiWikiRoot '07_Projects\blog.ryanspice.com' } else { $BlogRoot }
$runtimeRoot = $RuntimeRoot

$pathBindings = [ordered]@{
  FUGU_ADAPTER_PATH = $adapterPath
  FUGU_POLICY_PATH = $policyPath
  FUGU_SOURCE_PATH = $sourcePath
  FUGU_MANIFEST_PATH = $manifestPath
  FUGU_FLEET_POLICY_PATH = $fleetPolicyPath
  T3_OPS_PATH = $t3OpsPath
  T3_UPDATE_PATH = $t3UpdatePath
  OPENCODE_CONFIG_PATH = $openCodePath
  HERMES_ROOT = $hermesRoot
  T3_USERDATA_ROOT = $t3UserdataRoot
  FUGU_RUNTIME_ROOT = $runtimeRoot
}
$missingBindings = @($pathBindings.GetEnumerator() | Where-Object { [string]::IsNullOrWhiteSpace([string]$_.Value) })
if ($missingBindings.Count -gt 0) {
  throw "Missing required path bindings: $($missingBindings.Name -join ', '). Pass explicit parameters or set the corresponding environment variables."
}

Write-Host 'Fugu free-model fleet snapshot' -ForegroundColor Cyan
Write-Host ("Current location: {0}" -f (Get-Location).Path)
Write-Host ("Script root:      {0}" -f $PSScriptRoot)
Write-Host ("PowerShell:       {0}" -f $PSVersionTable.PSVersion)
Write-Host ("AI Wiki root:     {0}" -f $resolvedAiWikiRoot)
Write-Host ("Snapshot output:  {0}" -f $resolvedSnapshotDirectory)
Write-Host ("Catalog refresh:  {0}" -f $RefreshFuguCatalog.IsPresent)

if ($RefreshFuguCatalog) {
  if (-not (Test-Path -LiteralPath $adapterPath -PathType Leaf)) {
    throw "Fugu adapter not found: $adapterPath"
  }
  Write-Host 'Refreshing the Fugu catalog through the adapter.' -ForegroundColor Yellow
  & $adapterPath -CatalogJson | Out-Null
  if ($LASTEXITCODE -ne 0) {
    throw "Fugu catalog refresh exited with code $LASTEXITCODE."
  }
}

$files = @(
  $policyPath,
  $adapterPath,
  $sourcePath,
  $manifestPath,
  $fleetPolicyPath,
  $t3OpsPath,
  $t3UpdatePath,
  $openCodePath,
  $hermesConfigPath
) | ForEach-Object { Get-FileFingerprint -Path $_ }

$hermesProfiles = @()
if (Test-Path -LiteralPath $hermesProfilesRoot -PathType Container) {
  $hermesProfiles = @(Get-ChildItem -LiteralPath $hermesProfilesRoot -Directory | Sort-Object Name | ForEach-Object {
    Get-HermesProfileRecord -Directory $_
  })
}

$manifestSummary = [ordered]@{
  present = Test-Path -LiteralPath $manifestPath -PathType Leaf
  schema = $null
  generated_at = $null
  catalog_fetched_at = $null
  catalog_fresh = $null
  lane_count = 0
  statuses = @{}
  lanes = @()
}
if ($manifestSummary.present) {
  $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
  $manifestSummary.schema = Get-OptionalJsonProperty -Object $manifest -Name 'schema'
  $manifestSummary.generated_at = Get-OptionalJsonProperty -Object $manifest -Name 'generated_at'
  $manifestSummary.catalog_fetched_at = Get-OptionalJsonProperty -Object $manifest -Name 'catalog_fetched_at'
  $manifestSummary.catalog_fresh = Get-OptionalJsonProperty -Object $manifest -Name 'catalog_fresh'
  $lanes = @(Get-OptionalJsonProperty -Object $manifest -Name 'lanes')
  $manifestSummary.lane_count = $lanes.Count
  $statusGroups = $lanes | Group-Object status
  foreach ($group in $statusGroups) { $manifestSummary.statuses[$group.Name] = $group.Count }
  $laneInventory = @($lanes | ForEach-Object {
    [pscustomobject]@{
      lane = Get-OptionalJsonProperty -Object $_ -Name 'lane'
      profile = Get-OptionalJsonProperty -Object $_ -Name 'profile'
      provider = Get-OptionalJsonProperty -Object $_ -Name 'provider'
      model = Get-OptionalJsonProperty -Object $_ -Name 'model'
      canonical_model = Get-OptionalJsonProperty -Object $_ -Name 'canonical_model'
      effort = Get-OptionalJsonProperty -Object $_ -Name 'effort'
      status = Get-OptionalJsonProperty -Object $_ -Name 'status'
      reason = Get-OptionalJsonProperty -Object $_ -Name 'reason'
      dispatchable = Get-OptionalJsonProperty -Object $_ -Name 'dispatchable'
      cost_class = Get-OptionalJsonProperty -Object $_ -Name 'cost_class'
      toolsets = Get-OptionalJsonProperty -Object $_ -Name 'toolsets'
      context_tokens = Get-OptionalJsonProperty -Object $_ -Name 'context_tokens'
      output_tokens = Get-OptionalJsonProperty -Object $_ -Name 'output_tokens'
      output_limit_source = Get-OptionalJsonProperty -Object $_ -Name 'output_limit_source'
      expiry = Get-OptionalJsonProperty -Object $_ -Name 'expiry'
      fallback_lanes = Get-OptionalJsonProperty -Object $_ -Name 'fallback_lanes'
      equivalent_lanes = Get-OptionalJsonProperty -Object $_ -Name 'equivalent_lanes'
      children_supported = Get-OptionalJsonProperty -Object $_ -Name 'children_supported'
      profile_sha256 = Get-OptionalJsonProperty -Object $_ -Name 'profile_sha256'
      last_probe = Get-OptionalJsonProperty -Object $_ -Name 'last_probe'
    }
  })
  $manifestSummary.lanes = $laneInventory
}

$fleetPolicy = $null
if (Test-Path -LiteralPath $fleetPolicyPath -PathType Leaf) {
  $fleetPolicy = Get-Content -LiteralPath $fleetPolicyPath -Raw | ConvertFrom-Json
}

$wingetText = $null
if (Get-Command winget -ErrorAction SilentlyContinue) {
  $wingetText = (& winget list --id T3Tools.T3Code -e --accept-source-agreements 2>&1 | Out-String).Trim()
}

$gitBranch = $null
$gitStatusLines = @()
if ((Test-Path -LiteralPath $blogRoot -PathType Container) -and (Get-Command git -ErrorAction SilentlyContinue)) {
  $gitBranch = (& git -C $blogRoot branch --show-current 2>$null | Out-String).Trim()
  $gitStatusLines = Get-TextLines -Lines @(& git -C $blogRoot status --porcelain=v1 --branch 2>$null)
}

$runtimeReceiptSummary = [ordered]@{
  root = $runtimeRoot
  present = Test-Path -LiteralPath $runtimeRoot -PathType Container
  file_count = 0
  latest_files = @()
}
if ($runtimeReceiptSummary.present) {
  $receiptFiles = @(Get-ChildItem -LiteralPath $runtimeRoot -File -Recurse -ErrorAction SilentlyContinue | Sort-Object LastWriteTimeUtc -Descending)
  $runtimeReceiptSummary.file_count = $receiptFiles.Count
  $runtimeReceiptSummary.latest_files = @($receiptFiles | Select-Object -First 20 | ForEach-Object {
    [pscustomobject]@{ name = $_.Name; relative_path = $_.FullName.Substring($runtimeRoot.Length).TrimStart('\'); length = $_.Length; last_write_time_utc = $_.LastWriteTimeUtc.ToString('o') }
  })
}

$catalogSummary = [ordered]@{
  supplied_json = $null
  live_refresh_requested = $RefreshFuguCatalog.IsPresent
  note = 'Catalog listing is not proof of account reachability, free entitlement, capability, or task acceptance.'
}
if (-not [string]::IsNullOrWhiteSpace($ProviderCatalogJson)) {
  if (-not (Test-Path -LiteralPath $ProviderCatalogJson -PathType Leaf)) {
    throw "ProviderCatalogJson not found: $ProviderCatalogJson"
  }
  $catalog = Get-Content -LiteralPath $ProviderCatalogJson -Raw | ConvertFrom-Json
  $catalogSummary.supplied_json = [pscustomobject]@{
    path = (Resolve-Path -LiteralPath $ProviderCatalogJson).Path
    fetched_at = $catalog.fetched_at
    sources = @($catalog.sources.PSObject.Properties.Name)
    openrouter_exact_free_models = $catalog.sources.openrouter.exact_free_models
  }
}

$snapshot = [ordered]@{
  schema_version = '1.0.0'
  snapshot_id = $SnapshotId
  captured_at_local = $now.ToString('o')
  captured_at_utc = $now.ToUniversalTime().ToString('o')
  current_location = (Get-Location).Path
  powershell = $PSVersionTable.PSVersion.ToString()
  ai_wiki_root = $resolvedAiWikiRoot
  files = $files
  tools = @('pwsh', 'hermes', 'opencode', 't3', 't3code', 'winget', 'git') | ForEach-Object { Get-CommandRecord -Name $_ }
  hermes = [pscustomobject]@{
    root = $hermesRoot
    authoritative_config = $hermesConfigPath
    profiles_root = $hermesProfilesRoot
    profile_count = $hermesProfiles.Count
    profiles = $hermesProfiles
    env_policy = 'presence recorded only; values never read into the snapshot'
  }
  fugu = [pscustomobject]@{
    policy_path = $policyPath
    adapter_path = $adapterPath
    source_mirror_path = $sourcePath
    generated_manifest_path = $manifestPath
    fleet_policy_path = $fleetPolicyPath
    manifest = [pscustomobject]$manifestSummary
    fleet_policy = $fleetPolicy
  }
  opencode = [pscustomobject]@{
    config_path = $openCodePath
    config_present = Test-Path -LiteralPath $openCodePath -PathType Leaf
    auth_store_presence = 'not read; verify through opencode auth list when binary is available'
  }
  t3 = [pscustomobject]@{
    package_query = $wingetText
    cli_boundary = 't3/t3code command discovery is evidence only; supported UI/application state remains authoritative'
    userdata_root = $t3UserdataRoot
    userdata_presence = Test-Path -LiteralPath $t3UserdataRoot -PathType Container
  }
  protected_boundaries = @(
    '<T3_USERDATA_ROOT>/settings.json',
    '<T3_USERDATA_ROOT>/client-settings.json',
    '<HERMES_PROFILES_ROOT>/*/.env',
    'OpenCode auth store values and provider API keys'
  )
  provider_catalog = [pscustomobject]$catalogSummary
  runtime_receipts = [pscustomobject]$runtimeReceiptSummary
  blog_workspace = [pscustomobject]@{
    root = $blogRoot
    git_branch = $gitBranch
    status_lines = $gitStatusLines
    note = 'Existing dirty work was observed and is preserved; it is not part of this workflow change.'
  }
  acceptance = [ordered]@{
    parsed = 'not evaluated by this snapshot script'
    catalog = 'requires live sanitized catalog'
    authenticated_inference = 'not run by this snapshot script'
    capability_canaries = 'not run by this snapshot script'
    broker_child = 'not run by this snapshot script'
    t3_ui = 'not run by this snapshot script'
  }
}

$manifestFingerprint = $files | Where-Object { $_.path -eq $manifestPath } | Select-Object -First 1
$manifestHashText = if ($manifestFingerprint -and $manifestFingerprint.sha256) { $manifestFingerprint.sha256 } else { 'unavailable' }
$snapshot.Add('observations', @(
  'Fugu inventory or validation may refresh the derived manifest; re-hash and compare lane semantics after such checks.',
  ("Derived manifest hash captured in this snapshot: {0}" -f $manifestHashText)
))

$jsonPath = Join-Path $resolvedSnapshotDirectory 'snapshot.json'
$markdownPath = Join-Path $resolvedSnapshotDirectory 'snapshot.md'
$lanesPath = Join-Path $resolvedSnapshotDirectory 'fugu-lanes.json'
$json = $snapshot | ConvertTo-Json -Depth 30
[System.IO.File]::WriteAllText($jsonPath, $json, (New-Object System.Text.UTF8Encoding($false)))
[System.IO.File]::WriteAllText($lanesPath, (@($manifestSummary.lanes) | ConvertTo-Json -Depth 20), (New-Object System.Text.UTF8Encoding($false)))

$statusText = if ($manifestSummary.statuses.Count -gt 0) {
  ($manifestSummary.statuses.GetEnumerator() | Sort-Object Name | ForEach-Object { '{0}={1}' -f $_.Key, $_.Value }) -join '; '
} else { 'unavailable' }
$markdown = @"
---
snapshot_id: $SnapshotId
captured_at: $($now.ToString('o'))
schema_version: 1.0.0
status: evidence-only
---

# Fugu Free-Model Fleet Snapshot

This is a secret-free operational snapshot. It records local files, hashes, tool discovery, profile metadata, generated-manifest state, provider-state boundaries, T3 protection boundaries, and existing dirty-work evidence. It does not prove authenticated inference or task acceptance.

## Summary

- AI Wiki root: $resolvedAiWikiRoot
- Snapshot directory: $resolvedSnapshotDirectory
- Fugu manifest lanes: $($manifestSummary.lane_count)
- Fugu manifest statuses: $statusText
- Full secret-free Fugu lane inventory: fugu-lanes.json
- Hermes profiles: $($hermesProfiles.Count)
- T3 package query captured: $([bool]$wingetText)
- OpenCode command discoverable: $((Get-CommandRecord -Name 'opencode').present)
- Catalog refresh requested: $($RefreshFuguCatalog.IsPresent)

## Evidence files

See snapshot.json for machine-readable records and SHA-256 fingerprints. The following durable surfaces were inspected:

- $policyPath
- $adapterPath
- $sourcePath
- $manifestPath
- $fleetPolicyPath
- $t3OpsPath
- $t3UpdatePath
- $openCodePath
- $hermesConfigPath

## Current boundary notes

- fugu-fleet.json is derived and must be regenerated.
- fugu-lanes-source.json must not become an independent editable roster.
- T3 userdata and profile .env values were not read into the snapshot.
- OpenCode and T3 CLI discovery must be repaired or explicitly marked unavailable before apply.
- Existing blog worktree changes were observed and preserved.

## Acceptance state

All runtime acceptance fields are intentionally `not run` or `requires live catalog` until an update pass performs exact no-fallback/no-child canaries and receipt review.

## Derived-state observation

Fugu inventory/validation may refresh the derived fugu-fleet.json. The hash captured in this snapshot is $manifestHashText. Compare lane identity, status, provider, model, and profile hash before deciding that a derived refresh changed routing.
"@
[System.IO.File]::WriteAllText($markdownPath, $markdown, (New-Object System.Text.UTF8Encoding($false)))

Write-Host ("PASS: wrote {0}" -f $jsonPath) -ForegroundColor Green
Write-Host ("PASS: wrote {0}" -f $markdownPath) -ForegroundColor Green
Write-Host ("PASS: wrote {0}" -f $lanesPath) -ForegroundColor Green
Write-Host ("PASS: captured {0} Hermes profiles and {1} Fugu lanes" -f $hermesProfiles.Count, $manifestSummary.lane_count) -ForegroundColor Green

[pscustomobject]@{
  status = 'pass'
  snapshot_id = $SnapshotId
  snapshot_directory = $resolvedSnapshotDirectory
  json_path = $jsonPath
  markdown_path = $markdownPath
  lanes_path = $lanesPath
  hermes_profile_count = $hermesProfiles.Count
  fugu_lane_count = $manifestSummary.lane_count
}
