---
name: powershell-script-authoring
description: Creates, audits, repairs, and packages Windows PowerShell/pwsh scripts for install/apply, diagnostics, TAR.GZ workflows, AI Wiki operations, repo automation, and copy-paste terminal tasks. Use when the user asks for PowerShell, a .ps1, a one-liner, a build-the-file script, a self-cleaning installer, a compatibility-safe client/prod script, or a downloadable script package.
version: 0.1.0
status: active
type: universal-agent-skill
risk: medium by default; high when scripts delete, overwrite, deploy, send data externally, change credentials, touch billing, or mutate production/client environments.
tags: ["powershell", "pwsh", "windows", "scripts", "automation", "tar-gz", "aiwiki"]
provenance_origin: "original"
provenance_source_path: "04_skills/generated/powershell-script-authoring/SKILL.md"
provenance_credit: "Ryan Spice-Finnie"
provenance_note: "Original AI Wiki generated skill credited to Ryan Spice-Finnie."

---

# PowerShell Script Authoring

## Purpose

Use this skill to produce practical Windows-first PowerShell scripts and command flows that are safe, copy-pasteable, version-aware, cleanup-aware, and compatible with the user's packaging style.

Default to **PowerShell 7+ via `pwsh`** for Ryan's own machine and AI Wiki workflows. For client, production, locked-down, older Windows, CI, or uncertain environments, detect capabilities first and write compatibility-safe code.

## Core defaults

For Ryan's local workflows, assume these known defaults unless the user says otherwise:

- browser/download source: `<DOWNLOADS_ROOT>`
- dev destination root: `<DEV_ROOT>`
- AI Wiki root: `<AI_WIKI_ROOT>`
- preferred shell command: `pwsh -NoProfile -ExecutionPolicy Bypass -File ...`
- package format: `.tar.gz` for multi-file drops
- build/test runner: project-specific, often `bun`, Gradle wrapper, Python, or repo scripts

For other users, new environments, clients, or unknown machines, ask for or detect:

- source/download directory
- repo/destination directory
- PowerShell edition/version
- whether admin rights are available
- whether production/client data is involved
- whether scripts may delete, overwrite, install, deploy, or send anything externally

Do not repeatedly ask Ryan for known defaults unless the current task contradicts them.

## Output decision rules

### Small task

For short fixes, give direct copy-paste commands or a compact inline script.

### Medium task

For a reusable script, give a **build-the-file script** first. The build script writes the `.ps1` file to a clear path, then show the exact run command.

Pattern:

```powershell
$ScriptPath = "<DOWNLOADS_ROOT>/do-thing-v0.1.0.ps1"
@'
# actual script content here
'@ | Set-Content -LiteralPath $ScriptPath -Encoding utf8NoBOM
pwsh -NoProfile -ExecutionPolicy Bypass -File $ScriptPath
```

### Large or multi-file task

For large scripts, multi-file artifacts, installers, generated docs, or packs where files must work together, create a downloadable `.tar.gz` package instead of dumping huge code into chat.

Then provide:

1. download link
2. extraction command
3. stage/dry-run command
4. apply command
5. validation command
6. cleanup notes only when not automatic

## Shell/runtime selection

Use this hierarchy:

1. If the user is Ryan/local/AI Wiki and `pwsh` is available, use `pwsh`.
2. If the user explicitly needs Windows PowerShell compatibility, target Windows PowerShell 5.1.
3. If the task is client/prod/unknown, include a version/capability check before using PS7-only features.
4. If a tool/agent/environment can check installed shells, check first.
5. If no check is possible, write compatible code or include a clear fallback.

Do not call `powershell` by default in new instructions unless Windows PowerShell 5.1 is intentionally required. `powershell` launches Windows PowerShell 5.1 even from a PS7 terminal.

## Compatibility patterns

Use PS7 conveniences when appropriate:

- `Set-Content -Encoding utf8NoBOM`
- ternary-like clarity only if it does not reduce readability
- modern .NET methods when running under PS7

Use compatibility helpers when the script may run on Windows PowerShell 5.1:

- custom UTF-8 no-BOM writer with `System.Text.UTF8Encoding($false)`
- custom relative path helper instead of `[System.IO.Path]::GetRelativePath()`
- avoid `Join-Path -AdditionalChildPath` if targeting older engines
- avoid PS7-only operators/features

When uncertain, include:

```powershell
$PSVersionTable.PSVersion
Get-Command pwsh, powershell -ErrorAction SilentlyContinue | Select-Object Name, Source, Version
```

## Script safety rules

All non-trivial scripts should include:

- `param(...)` for inputs
- `$ErrorActionPreference = "Stop"`
- clear dry-run/stage/apply mode when writing files
- backups before overwriting durable content
- `-LiteralPath` for paths that may include special characters
- `Join-Path` instead of string path concatenation
- explicit `Write-Host` status output
- non-zero failure on real errors
- no secret printing
- no broad delete/mirror operations without excludes and backups

For destructive or production/client actions:

- default to dry-run
- require explicit `-Apply`, `-Confirm`, or equivalent
- show target path/account/environment before action
- include backup or rollback path when practical
- do not hide risk behind a friendly installer

## Cleanup and self-delete

Installer/apply scripts should clean up after themselves when safe:

- remove temporary extraction/staging folders after success when not needed
- delete the archive they just extracted when that archive was generated for one-time application
- optionally self-delete if saved as a local installer/apply script
- include `-NoSelfDelete` escape hatch for debugging
- never self-delete before reporting success/failure
- never delete user source files unless the script created them or the user clearly requested cleanup

Recommended parameter:

```powershell
[switch]$NoSelfDelete
```

Self-delete pattern should be best-effort and last:

```powershell
if (-not $NoSelfDelete -and $PSCommandPath) {
  try {
    Remove-Item -LiteralPath $PSCommandPath -Force -ErrorAction SilentlyContinue
  } catch {}
}
```

## TAR.GZ apply workflow

For package apply scripts:

1. locate archive in known source dirs such as `<DOWNLOADS_ROOT>` and `$env:USERPROFILE/Downloads`
2. extract to a temp/staging folder
3. validate expected files exist
4. back up touched destination files
5. copy or mirror only intended paths
6. preserve local dev state
7. run validation/build commands
8. clean temporary files and optionally archive/script

Never use broad `robocopy /MIR` unless the preserve/exclude list is explicit and appropriate. For repos, preserve things like:

- `.git`
- `node_modules`
- `.gradle`
- `build`
- `dist` when local-only
- `local.properties`
- lockfiles unless the package intentionally updates them
- platform/generated folders the user named as protected

## Vite-like output style

Scripts should feel like useful build tools, not silent mystery meat.

Recommended sections:

```text
==> Checking environment
==> Preparing paths
==> Backing up touched files
==> Applying changes
==> Validating
PASS: ...
WARN: ...
FAIL: ...

Summary:
  Source: ...
  Destination: ...
  Backup: ...
  Changed: ...
  Validation: ...
```

Prefer concise, high-signal output. Do not spam every file unless requested or useful.

## PowerShell syntax guardrails

Avoid common breakages:

- Do not use Bash escaping like `\"` inside PowerShell strings.
- Avoid `$Var:` inside interpolated strings; use `${Var}:` or `("{0}:" -f $Var)`.
- Avoid fragile backtick line continuations inside generated scripts when possible.
- Be careful with Markdown fences/backticks inside here-strings.
- Prefer single-quoted here-strings `@' ... '@` for generated script bodies.
- Use `curl.exe`, not `curl`, when real curl behavior matters.
- Use `robocopy` exit-code handling if used; robocopy codes below 8 are usually not fatal.
- Normalize UTF-8/no-BOM and LF/CRLF intentionally when validators care.

## Response contract

When answering a PowerShell request, produce in this order:

1. the copy-paste command or build-the-file script
2. what it does
3. verification command
4. cleanup/rollback notes only if relevant

For large deliverables, provide a downloadable `.tar.gz` and keep chat concise.

## References

Read these when relevant:

- `reference/powershell-patterns.md`
- `reference/package-apply-patterns.md`
- `reference/compatibility-matrix.md`
- `templates/build-file-script-template.ps1`
- `templates/tar-gz-apply-template.ps1`

<!-- AIWIKI_POWERSHELL_PATH_GUARD_START -->
## Critical path and working-directory guardrails

For any PowerShell that copies, deletes, installs, promotes, stages, mirrors, archives, rewrites, or mutates project/wiki/client/prod files, generate scripts with explicit path preflight.

Do not rely on the terminal current directory.

Required pattern:

1. Accept explicit roots such as AiWikiRoot, RepoRoot, SourceDir, and DestinationDir, or derive them from known user defaults only when durable context already defines them.
2. Print a Vite-like preflight banner with current location, PSScriptRoot, PowerShell version, source path, destination path, and mode.
3. Fail fast if source/destination variables are null, empty, unresolved, or unexpected.
4. Use Resolve-Path -LiteralPath where the path must already exist.
5. Use Test-Path -LiteralPath before destructive or copy actions.
6. Use Push-Location and Pop-Location with try/finally when a command must run from a specific root.
7. Prefer Join-Path and -LiteralPath.
8. Back up before overwriting or deleting.
9. Dry-run first for broad file operations.
10. For client, production, billing, deploy, or external side-effect work, check the actual environment/tool/runtime when accessible before assuming compatibility.
11. Prefer pwsh -NoProfile -ExecutionPolicy Bypass for PowerShell 7+ workflows.
12. Never demonstrate dangerous anti-patterns as runnable final lines.

Copy contents intentionally. Do not copy a folder into an already-existing destination folder unless nesting is explicitly desired.

For medium scripts, provide a build-the-file command that writes a ps1, then a separate command to run it.

For large or multi-file work, provide a downloadable tar.gz package and short install/apply commands.

If examples/ exists, SKILL.md must mention examples/evals and explain when to read them.
<!-- AIWIKI_POWERSHELL_PATH_GUARD_END -->

<!-- AIWIKI_POWERSHELL_FAILURE_PATTERNS_START -->
## Generated PowerShell failure patterns to avoid

These rules come from real AI Wiki installer/importer failures. Apply them when generating PowerShell for AI Wiki, repo setup, package installers, candidate imports, cleanup scripts, or any filesystem automation.

### Parser-safe string rules

Avoid `$Var:` inside double-quoted strings. PowerShell reads it like a scoped variable.

Bad:
`"$SourceSlug: $Count"`

Good:
`("{0}: {1}" -f $SourceSlug, $Count)`

Also acceptable:
`${SourceSlug}: $Count`

### Object and JSON construction rules

Do not build JSON arrays by manually escaping quotes inside strings.

Bad:
`"[\"aiwiki/pointer\", \"status/$Status\"]"`

Good:
Create a real array, then use `ConvertTo-Json`.

Precompute conditional values before object literals.

Bad:
`status = if ($Apply) { "applied" } else { "dry-run" }`

Good:
`$RunStatus = if ($Apply) { "applied" } else { "dry-run" }`
then:
`status = $RunStatus`

When script generation has repeatedly failed, prefer `[pscustomobject]` records with precomputed fields over clever `[ordered]@{}` blocks. Boring wins.

### Validation command rules

Do not validate the AI Wiki root as if it were a single skill folder.

Bad:
`python validate_skill.py <AI_WIKI_ROOT> --registry`

Good:
`python validate_skill.py <AI_WIKI_ROOT> --scan --registry`

Use single-skill validation only when the target path is an actual skill folder containing `SKILL.md`.

### Dry-run and missing-source rules

Dry run should not require cloned repos, generated indexes, or existing candidate records.

For external source harvesters:
1. Dry run may report that clone/cache is missing.
2. Apply clones or updates the source.
3. Indexes are written only after real records exist.
4. Combined indexes are rebuilt from disk, not noisy import logs.
5. Deduplicate by local candidate folder/slug before writing indexes.

### Copy/delete/install guardrails

Before copy, delete, archive, promote, or mirror operations:

1. Print preflight: current location, script root, PowerShell version, source path, destination path, mode.
2. Fail fast on null/empty source or destination variables.
3. Use `Test-Path -LiteralPath` and `Join-Path`.
4. Back up before overwrite/delete.
5. Prefer dry-run first.
6. Copy folder contents intentionally; do not accidentally nest a source folder inside an existing destination folder.
7. Keep Git source caches until the repo recommendation/setup pass is complete.
8. Do not run illustrative anti-patterns as final copy-paste commands.
<!-- AIWIKI_POWERSHELL_FAILURE_PATTERNS_END -->
<!-- AIWIKI_PYTHON_FOR_INDEX_JSON_RULE_START -->
## Use Python for complex indexes

For registry rebuilds, candidate indexes, mirror maps, provenance maps, and other nested JSON outputs, prefer a tiny Python helper over fragile generated PowerShell object construction.

PowerShell remains the wrapper/orchestrator.

Use Python when:
- nested object construction is needed
- arrays of objects must be serialized
- previous generated PowerShell has failed around `[pscustomobject]`, `[ordered]`, inline `if`, or JSON quote escaping
- idempotent index rebuilds matter

This is not cleverness. It is damage control.
<!-- AIWIKI_PYTHON_FOR_INDEX_JSON_RULE_END -->
