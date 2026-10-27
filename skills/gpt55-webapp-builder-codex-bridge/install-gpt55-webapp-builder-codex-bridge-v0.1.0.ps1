param(
  [string] $AiWikiRoot = '<AI_WIKI_ROOT>',
  [string] $ArchivePath = '',
  [switch] $DryRun,
  [switch] $Force,
  [switch] $CleanTemp
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$SkillSlug = 'gpt55-webapp-builder-codex-bridge'
$PackageName = 'gpt55-webapp-builder-codex-bridge-v0.1.0'
$GeneratedRoot = Join-Path $AiWikiRoot '04_skills\generated'
$Destination = Join-Path $GeneratedRoot $SkillSlug
$BackupRoot = Join-Path $AiWikiRoot '99_backups\skills'
$Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$TempRoot = Join-Path $env:TEMP ("$PackageName-install-$Timestamp")

function Write-Step {
  param([Parameter(Mandatory=$true)] [string] $Message)
  Write-Host "==> $Message"
}

function Get-ScriptRoot {
  if ($PSScriptRoot) { return $PSScriptRoot }
  return (Get-Location).Path
}

$ScriptRoot = Get-ScriptRoot

try {
  Write-Step 'Preflight'
  Write-Host "AI Wiki root: $AiWikiRoot"
  Write-Host "Destination:  $Destination"
  Write-Host "DryRun:       $DryRun"
  Write-Host "Force:        $Force"
  Write-Host "CleanTemp:    $CleanTemp"

  if (-not (Test-Path -LiteralPath $AiWikiRoot -PathType Container)) {
    throw "AI Wiki root not found: $AiWikiRoot"
  }

  $SourceRoot = $null
  $LocalSkill = Join-Path $ScriptRoot 'SKILL.md'
  if (Test-Path -LiteralPath $LocalSkill -PathType Leaf) {
    $SourceRoot = $ScriptRoot
    Write-Host "Source mode:  expanded package folder"
  } else {
    if ([string]::IsNullOrWhiteSpace($ArchivePath)) {
      $candidate = Join-Path $ScriptRoot "$PackageName.tar.gz"
      if (Test-Path -LiteralPath $candidate -PathType Leaf) {
        $ArchivePath = $candidate
      }
    }

    if ([string]::IsNullOrWhiteSpace($ArchivePath)) {
      throw "ArchivePath not supplied and archive not found beside installer: $ScriptRoot\$PackageName.tar.gz"
    }

    if (-not (Test-Path -LiteralPath $ArchivePath -PathType Leaf)) {
      throw "Archive not found: $ArchivePath"
    }

    if (-not (Get-Command tar.exe -ErrorAction SilentlyContinue)) {
      throw 'tar.exe not found on PATH. Windows 10/11 usually includes tar.exe.'
    }

    Write-Host "Archive:      $ArchivePath"
    if ($DryRun) {
      Write-Step 'Archive listing'
      tar.exe -tzf $ArchivePath | Select-Object -First 80
    } else {
      New-Item -ItemType Directory -Path $TempRoot -Force | Out-Null
      Write-Step 'Extracting archive to temp review folder'
      tar.exe -xzf $ArchivePath -C $TempRoot
      $possible = Join-Path $TempRoot $PackageName
      if (-not (Test-Path -LiteralPath $possible -PathType Container)) {
        $dirs = @(Get-ChildItem -LiteralPath $TempRoot -Directory)
        if ($dirs.Count -eq 1) {
          $possible = $dirs[0].FullName
        }
      }
      if (-not (Test-Path -LiteralPath (Join-Path $possible 'SKILL.md') -PathType Leaf)) {
        throw "Extracted package did not contain expected SKILL.md under: $possible"
      }
      $SourceRoot = $possible
    }
  }

  Write-Step 'Planned copy'
  Write-Host "Source:       $SourceRoot"
  Write-Host "Destination:  $Destination"

  if ($DryRun) {
    Write-Step 'Dry-run complete; no files changed'
    if (Test-Path -LiteralPath $Destination) {
      Write-Host 'Destination already exists. Apply with -Force to back it up and replace it.'
    }
    return
  }

  if (-not $SourceRoot) {
    throw 'SourceRoot could not be resolved.'
  }

  New-Item -ItemType Directory -Path $GeneratedRoot -Force | Out-Null

  if (Test-Path -LiteralPath $Destination) {
    if (-not $Force) {
      throw "Destination exists. Re-run with -Force to back up and replace: $Destination"
    }
    New-Item -ItemType Directory -Path $BackupRoot -Force | Out-Null
    $BackupPath = Join-Path $BackupRoot "$SkillSlug-$Timestamp"
    Write-Step "Backing up existing destination to $BackupPath"
    Copy-Item -LiteralPath $Destination -Destination $BackupPath -Recurse -Force
    Remove-Item -LiteralPath $Destination -Recurse -Force
  }

  Write-Step 'Installing repo-backed skill'
  New-Item -ItemType Directory -Path $Destination -Force | Out-Null
  Get-ChildItem -LiteralPath $SourceRoot -Force | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination $Destination -Recurse -Force
  }

  Write-Step 'Verification'
  $InstalledSkill = Join-Path $Destination 'SKILL.md'
  if (-not (Test-Path -LiteralPath $InstalledSkill -PathType Leaf)) {
    throw "Install verification failed: $InstalledSkill missing"
  }
  Write-Host "Installed: $InstalledSkill"

  $HashPath = Join-Path $Destination 'hashes.sha256'
  if (Test-Path -LiteralPath $HashPath -PathType Leaf) {
    Write-Host "Hashes:   $HashPath"
  }

  if ($CleanTemp -and -not [string]::IsNullOrWhiteSpace($ArchivePath) -and (Test-Path -LiteralPath $ArchivePath -PathType Leaf)) {
    Write-Step 'Cleaning downloaded archive'
    Remove-Item -LiteralPath $ArchivePath -Force -ErrorAction SilentlyContinue
  }

  Write-Step 'Done'
}
finally {
  if (Test-Path -LiteralPath $TempRoot) {
    Remove-Item -LiteralPath $TempRoot -Recurse -Force -ErrorAction SilentlyContinue
  }
}
