---
title: AI Wiki Command Layer Notes
type: generated-skill
status: active
version: 0.7.1
updated: 2026-05-25
provenance_origin: "original"
provenance_source_path: "04_skills/generated/aiwiki-command-layer-notes/SKILL.md"
provenance_note: "Original AI Wiki generated skill."

---

# AI Wiki Command Layer Notes

## Purpose

Use and maintain the local AI Wiki command layer: `Copy -In`, `Copy-In`, `Execute`, and registry helpers.

## Rules

- `Copy -In <path> -As File` should copy a real Windows file object to the clipboard.
- `Execute -In <package> -As Demo` should route cleaned demo packages to Svelte Lab ingestion.
- Use explicit wrapper params; avoid `$args` magic and `$input` names.
- Missing paths should fail loudly.
- Duplicate staging should require `-Force` rather than silently overwriting.

## Verification

Run `Import-AiWikiCommands.ps1`, then `Test-AiWikiCommands.ps1`, then test one real `Copy -In` command.
