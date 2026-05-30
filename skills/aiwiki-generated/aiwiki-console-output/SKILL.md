---
title: AI Wiki Console Output
type: generated-skill
status: active
version: 0.7.1
updated: 2026-05-25
provenance_origin: "original"
provenance_source_path: "04_skills/generated/aiwiki-console-output/SKILL.md"
provenance_note: "Original AI Wiki generated skill."

---

# AI Wiki Console Output

## Purpose

Standardize local PowerShell output for AI Wiki installers, cleanup scripts, Svelte Lab helpers, and command-layer tools.

## Rules

- Prefer concise sections with `==>` step headers.
- Always print root paths, target paths, mode, receipts, and next commands.
- Avoid escaped/corrupted command examples.
- Do not claim success after failed partial operations.
- Prefer array-of-lines receipts over fragile here-strings when variables and quotes are involved.
- Avoid `Copy-Item -LiteralPath (Join-Path $path "*")`; use `Get-ChildItem -LiteralPath $path | Copy-Item ...` instead.

## Verification

Run `Test-AiWikiConsole.ps1` if present. For new scripts, manually inspect copy-paste commands before packaging.
