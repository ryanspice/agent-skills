# Generated PowerShell Failure Patterns

Generated: 2026-05-18T12:30:32.083140+00:00

These are durable failures found while building the AI Wiki skill shelf. Treat them as guardrails for generated scripts.

## Parser-safe strings

Avoid `$Var:` inside double-quoted strings. PowerShell reads it like a scoped variable.

Use format strings:

`("{0}: {1}" -f $SourceSlug, $Count)`

or brace the variable:

`${SourceSlug}: $Count`

## JSON construction

Do not build JSON by manually escaping quotes inside strings.

Create real arrays/objects and serialize them with `ConvertTo-Json`, or use Python for larger JSON/index work.

## Object construction

Avoid clever inline conditional values inside PowerShell object or hashtable literals when generating scripts.

Precompute values first:

`$RunStatus = if ($Apply) { "applied" } else { "dry-run" }`

then assign:

`status = $RunStatus`

When PowerShell object construction keeps failing, switch to a tiny Python helper for JSON/index generation. Boring wins.

## Validation command shape

Validate a single skill folder only when that folder contains `SKILL.md`.

Validate the AI Wiki root with:

`python validate_skill.py <AI_WIKI_ROOT> --scan --registry`

Do not call the validator on the AI Wiki root without `--scan`.

## Dry-run behavior

Dry runs must not require cloned external repos, generated indexes, existing candidate records, network success, or write side effects.

For importers:
1. Dry run explains what it would do.
2. Apply clones or updates sources.
3. Indexes are written only after real records exist.
4. Combined indexes are rebuilt from disk.
5. Deduplicate by local candidate folder/slug.

## Copy/install behavior

Before copy, delete, archive, promote, or mirror operations:

1. Print current location, script root, PowerShell edition/version, source, destination, and mode.
2. Fail fast on null or empty source/destination.
3. Use `Join-Path` and `-LiteralPath`.
4. Back up before overwrite/delete.
5. Dry-run first for broad operations.
6. Copy folder contents intentionally.
7. Never run illustrative anti-patterns as final copy-paste commands.
