param(
  [string]$Archive,
  [string]$Work,
  [string]$DownloadsRoot = "<DOWNLOADS_ROOT>",
  [string]$DevRoot = "<DEV_ROOT>",
  [string]$Category = "",
  [string]$ProjectName = "",
  [string]$OutputRoot = "",
  [string]$InternalInstaller = "",
  [switch]$InstallToDev,
  [switch]$RunInternalInstaller,
  [switch]$RunBunInstall,
  [switch]$UseBunIsolated,
  [switch]$FrozenLockfile,
  [switch]$PruneDependencyFolders = $true,
  [switch]$CleanupArchive,
  [switch]$Apply,
  [switch]$Open
)

$ErrorActionPreference = "Stop"

function Write-Step {
  param([string]$Message)
  Write-Host ""
  Write-Host ("==> " + $Message) -ForegroundColor Cyan
}

function Get-ArchiveBaseName {
  param([string]$Path)
  $name = [System.IO.Path]::GetFileName($Path)
  if ($name.EndsWith(".tar.gz", [StringComparison]::OrdinalIgnoreCase)) {
    return $name.Substring(0, $name.Length - 7)
  }
  return [System.IO.Path]::GetFileNameWithoutExtension($Path)
}

function Get-FirstDirectory {
  param([string]$Path)
  $dirs = Get-ChildItem $Path -Directory -ErrorAction SilentlyContinue
  if ($dirs.Count -eq 1) { return $dirs[0].FullName }
  return $Path
}

function Remove-NoiseFolders {
  param([string]$Root)

  $names = @(
    "node_modules",
    ".svelte-kit",
    ".next",
    "dist",
    "build",
    "out",
    "target",
    ".gradle",
    ".venv",
    "venv",
    "__pycache__",
    ".turbo",
    ".parcel-cache"
  )

  foreach ($name in $names) {
    Get-ChildItem $Root -Directory -Recurse -Force -ErrorAction SilentlyContinue |
      Where-Object { $_.Name -eq $name } |
      ForEach-Object {
        Write-Host ("Prune: " + $_.FullName) -ForegroundColor DarkYellow
        if ($Apply) { Remove-Item $_.FullName -Recurse -Force }
      }
  }
}

function Find-InternalInstaller {
  param([string]$Root)

  $candidate = Get-ChildItem $Root -File -Filter "install-*.ps1" -ErrorAction SilentlyContinue |
    Sort-Object Name |
    Select-Object -First 1

  if ($candidate) { return $candidate.FullName }

  $candidate = Get-ChildItem $Root -File -Filter "install-*.ps1" -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch "\\node_modules\\|\\.git\\" } |
    Sort-Object FullName |
    Select-Object -First 1

  if ($candidate) { return $candidate.FullName }

  return $null
}

if (-not $Archive) {
  $latest = Get-ChildItem $DownloadsRoot -File -Filter "*.tar.gz" -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

  if (-not $latest) {
    throw ("No -Archive provided and no .tar.gz files found in " + $DownloadsRoot)
  }

  $Archive = $latest.FullName
}

if (-not (Test-Path $Archive)) {
  throw ("Archive not found: " + $Archive)
}

$ArchiveBase = Get-ArchiveBaseName $Archive

if (-not $ProjectName) {
  $ProjectName = $ArchiveBase -replace "-v\d+\.\d+\.\d+.*$", ""
}

if (-not $Work) {
  $Work = Join-Path $DownloadsRoot $ArchiveBase
}

if (-not $OutputRoot) {
  if ($Category) {
    $OutputRoot = Join-Path (Join-Path $DevRoot $Category) $ProjectName
  } else {
    $OutputRoot = Join-Path $DevRoot $ProjectName
  }
}

Write-Host "TAR package installer"
Write-Host ("Mode:       " + $(if ($Apply) { "APPLY" } else { "DRY RUN" }))
Write-Host ("Archive:    " + $Archive)
Write-Host ("Work:       " + $Work)
Write-Host ("OutputRoot: " + $OutputRoot)

Write-Step "Extracting archive to work folder"
if (Test-Path $Work) {
  if ($Apply) { Remove-Item $Work -Recurse -Force }
  else { Write-Host ("Would remove existing work folder: " + $Work) -ForegroundColor Yellow }
}

if ($Apply) {
  New-Item -ItemType Directory -Path $DownloadsRoot -Force | Out-Null
  tar -xzf $Archive -C $DownloadsRoot
} else {
  Write-Host ("Would extract " + $Archive + " to " + $DownloadsRoot) -ForegroundColor Yellow
}

if (-not (Test-Path $Work)) {
  $possible = Join-Path $DownloadsRoot $ArchiveBase
  if (Test-Path $possible) { $Work = $possible }
}

$ExtractRoot = if (Test-Path $Work) { Get-FirstDirectory $Work } else { $Work }

if ($PruneDependencyFolders -and (Test-Path $ExtractRoot)) {
  Write-Step "Pruning dependency/build noise from extracted package"
  Remove-NoiseFolders -Root $ExtractRoot
}

if ($InstallToDev) {
  Write-Step "Mirroring extracted package to Dev output"
  if ($Apply) {
    New-Item -ItemType Directory -Path $OutputRoot -Force | Out-Null

    $robocopyArgs = @(
      $ExtractRoot,
      $OutputRoot,
      "/MIR",
      "/XD",
      ".git",
      "node_modules",
      ".svelte-kit",
      ".next",
      "dist",
      "build",
      "out",
      "target",
      ".gradle",
      ".venv",
      "venv",
      "__pycache__",
      ".turbo",
      ".parcel-cache",
      "/XF",
      "*.lock.tmp"
    )

    robocopy @robocopyArgs | Out-Host
    $code = $LASTEXITCODE
    if ($code -gt 7) {
      throw ("robocopy failed with exit code " + $code)
    }
  } else {
    Write-Host ("Would mirror " + $ExtractRoot + " to " + $OutputRoot) -ForegroundColor Yellow
  }
}

$RunRoot = if ($InstallToDev) { $OutputRoot } else { $ExtractRoot }

if ($RunInternalInstaller) {
  Write-Step "Running internal installer"
  $installer = $InternalInstaller
  if (-not $installer) {
    $installer = Find-InternalInstaller -Root $RunRoot
  }

  if (-not $installer) {
    throw ("No internal installer found under " + $RunRoot)
  }

  Write-Host ("Installer: " + $installer)
  if ($Apply) {
    & pwsh -NoProfile -ExecutionPolicy Bypass -File $installer -Apply -Open:$Open
  } else {
    Write-Host ("Would run installer: " + $installer) -ForegroundColor Yellow
  }
}

if ($RunBunInstall) {
  Write-Step "Running Bun install"
  $pkgJson = Join-Path $RunRoot "package.json"
  if (-not (Test-Path $pkgJson)) {
    Write-Host ("No package.json found at " + $RunRoot + "; skipping Bun install.") -ForegroundColor Yellow
  } else {
    $bunArgs = @("install")
    if ($FrozenLockfile) { $bunArgs += "--frozen-lockfile" }
    if ($UseBunIsolated) { $bunArgs += @("--linker", "isolated") }

    Write-Host ("bun " + ($bunArgs -join " ")) -ForegroundColor Cyan
    if ($Apply) {
      Push-Location $RunRoot
      try {
        & bun @bunArgs
      } finally {
        Pop-Location
      }
    } else {
      Write-Host ("Would run bun install in " + $RunRoot) -ForegroundColor Yellow
    }
  }
}

if ($CleanupArchive) {
  Write-Step "Cleaning downloaded archive"
  if ($Apply) {
    Remove-Item $Archive -Force
    Write-Host ("Deleted: " + $Archive) -ForegroundColor Green
  } else {
    Write-Host ("Would delete: " + $Archive) -ForegroundColor Yellow
  }
}

Write-Step "Done"
if (-not $Apply) {
  Write-Host "Dry run only. Add -Apply to write changes." -ForegroundColor Yellow
}

if ($Open -and (Test-Path $RunRoot)) {
  Start-Process $RunRoot
}
