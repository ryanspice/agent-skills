---
name: windows-tar-package-installer-workflow
description: Use this skill when creating or applying downloadable project packages for Ryan's Windows workflow (single `.tar.gz` artifact + one internal installer script + one copy-paste PowerShell block).
version: 0.1.0
status: generated
type: generated-agent-skill
risk: medium
tags: ["windows", "powershell", "tar-gz", "installer", "packaging", "ai-wiki"]
created_at: 2026-05-22
provenance_origin: "original"
provenance_source_path: "04_skills/agent-skills/skills/windows-tar-package-installer-workflow/SKILL.md"
provenance_credit: "Ryan Spice-Finnie"
provenance_ingested_as: "ryanspice/agent-skills owned skill"
provenance_note: "Original AI Wiki local skill credited to Ryan Spice-Finnie."

---

# Windows TAR package installer workflow

## Purpose

Use this skill when creating or applying downloadable project packages for Ryan's Windows workflow.

The preferred pattern is:

- provide a single `.tar.gz` artifact;
- include one internal installer script in the archive;
- give one copy-paste PowerShell block that extracts the TAR and runs the internal installer;
- put generated project/code output under `<DEV_ROOT>` when practical;
- keep downloads and temporary extraction under `<DOWNLOADS_ROOT>`;
- avoid separate `.ps1` download links unless the fix is tiny and script-only.

## Default roots

```powershell
$DownloadsRoot = "<DOWNLOADS_ROOT>"
$DevRoot = "<DEV_ROOT>"
$AiWikiRoot = "<AI_WIKI_ROOT>"
```

## Standard package shape

```txt
package-name-v0.1.0.tar.gz
package-name-v0.1.0/
  README.md
  install-package-name-v0.1.0.ps1
  cleanup-package-name-v0.1.0.ps1      # optional
  scripts/
  docs/
  src/                                 # optional
```

## Standard copy-paste installer block

```powershell
cd <DOWNLOADS_ROOT>

$Archive = "<DOWNLOADS_ROOT>\package-name-v0.1.0.tar.gz"
$Work = "<DOWNLOADS_ROOT>\package-name-v0.1.0"

if (Test-Path $Work) { Remove-Item $Work -Recurse -Force }
tar -xzf $Archive -C "<DOWNLOADS_ROOT>"

pwsh -NoProfile -ExecutionPolicy Bypass -File "$Work\install-package-name-v0.1.0.ps1" -Apply -Open
```

## Parameterized reusable wrapper

Use `scripts/Install-TarPackage.ps1` from this skill when a package should be installed to a categorized `<DEV_ROOT>` location.

Example:

```powershell
$Installer = "<AI_WIKI_ROOT>\04_skills\generated\windows-tar-package-installer-workflow\scripts\Install-TarPackage.ps1"

pwsh -NoProfile -ExecutionPolicy Bypass -File $Installer `
  -Archive "<DOWNLOADS_ROOT>\webos-shell-v0.2.0.tar.gz" `
  -ProjectName "webos-shell" `
  -Category "webos" `
  -InstallToDev `
  -RunInternalInstaller `
  -Apply `
  -Open
```

This extracts to temp, prunes dependency/build folders, mirrors package contents to `<DEV_ROOT>\<Category>\<ProjectName>`, then optionally runs the internal installer.

## Categories

Use short category names when useful:

```txt
android
webos
pixelboats
ai-wiki
tools
client
experiments
```

Default output with category:

```txt
<DEV_ROOT>\<Category>\<ProjectName>
```

Default output without category:

```txt
<DEV_ROOT>\<ProjectName>
```

## Dependency / node_modules rule

Do not ship, mirror, or preserve `node_modules` in generated TAR packages unless there is a very specific reason.

For Bun projects:

- prefer committing `bun.lock`;
- prefer `bun install --frozen-lockfile` for reproducible installs;
- prefer `bun install --linker isolated` when pnpm-like isolation is useful;
- avoid manually symlinking `node_modules` unless a package manager officially owns that layout.

Bun's isolated linker creates a central package store in `node_modules/.bun` with top-level symlinks, which is the closest Bun-native equivalent to pnpm-style dependency layout.

## Safety rules

- Never overwrite `.git` unless explicitly requested.
- Exclude `node_modules`, `.svelte-kit`, `.next`, `dist`, `build`, `out`, `target`, `.gradle`, `.venv`, `venv`, `__pycache__`, and dependency caches from mirrors.
- Use `-Apply` for writes; default scripts may dry-run.
- Use `-Open` to open the output folder.
- Use `-CleanupArchive` only after successful extraction/install.
- Keep AI Wiki canonical notes in the AI Wiki, not inside `<DEV_ROOT>`.
