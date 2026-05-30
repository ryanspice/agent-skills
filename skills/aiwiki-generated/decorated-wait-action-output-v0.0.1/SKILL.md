---
name: decorated-wait-action-output
version: 0.0.1
type: universal-agent-skill-draft
status: generated-draft
risk: low
description: Designs console output for actions users must wait on, such as installs, indexing, package extraction, cleanup, builds, long scans, and agent operations, with reassuring status, safe dry-run/apply boundaries, and clear completion states.
tags: [console, cli, powershell, python, progress, installer, long-running, ux]
provenance_origin: "original"
provenance_source_path: "04_skills/generated/decorated-wait-action-output-v0.0.1/SKILL.md"
provenance_note: "Original AI Wiki generated skill."

---
# Decorated Wait Action Output

## Purpose

Use this skill when a script or CLI action takes long enough that the user may wonder whether it is frozen.

This is different from verbose output. Verbose output explains internals. Decorated wait output keeps the user oriented during a wait.

Use for:

- installers
- package extraction
- archive scanning
- indexing
- cleanup scripts
- build/test commands
- downloads
- migrations
- large file scans
- agent-run multi-step local workflows

## Trigger phrases

Use when the user asks for:

- loading bar
- progress while waiting
- Vite-like install output
- decorated console output
- long-running action UX
- progress for indexing/build/install/delete
- `x out of y` counters
- elapsed timer
- not frozen output

## Output contract

A wait-action script should show:

1. **Identity:** tool name and version.
2. **Mode:** dry-run/apply/force/cleanup.
3. **Targets:** paths or services being touched.
4. **Progress:** known phases and item counts when available.
5. **Elapsed time:** per phase or total.
6. **Safety boundary:** what was skipped or not deleted.
7. **Completion:** success, warnings, next commands.

## Example

```txt
Search Local Broker installer v0.1.4
Mode: APPLY
SearchRoot:   <SEARCH_ROOT>
RuntimeRoot:  <SEARCH_ROOT>\.runtime\aiwiki-search
AI Wiki link: <AI_WIKI_ROOT>
AI Wiki root: <AI_WIKI_ROOT>

  ➜ validating package
  [█████░░░░░░░░░░░░░░░░░] 25% 1/4 extract archive · 319ms
  [███████████░░░░░░░░░░░] 50% 2/4 copy files · 1.24s
  [████████████████░░░░░░] 75% 3/4 update env · 1.31s
  [██████████████████████] 100% 4/4 install complete · 1.38s

Next:
  . <SEARCH_ROOT>\scripts\Load-SearchEnv.ps1
  Status -Verbose
  Search "audiointel elastic linux" -Verbose
```

## When to use real counters

Use `x/y` counters only when the total is known:

```txt
[██████████░░░░░░░░░░░░]  48% 481/1000 files scanned · 8.2s
```

Use phase progress when the total is unknown:

```txt
[█████████░░░░░░░░░░░░░]  40% 2/5 select engine → broker · 14ms
```

## Dry-run/apply policy

For destructive or mutating scripts:

- default to dry-run when practical
- require `-Apply` for mutation
- print targets before mutation
- print counts and size estimates before deletion when possible
- log destructive actions
- never run broad deletes against canonical knowledge roots without explicit allowlists

## PowerShell guidance

Good long-running PowerShell scripts should:

- set `$ErrorActionPreference = 'Stop'`
- print mode, roots, and target paths before action
- use `Write-Progress` only when it helps interactive terminals
- also print durable progress lines because `Write-Progress` is ephemeral
- support `-Verbose`/`-ShowProgress`
- exit non-zero on failure when used as a tool

## Python guidance

Good long-running Python commands should:

- separate progress/log output from JSON output
- send progress to stderr when stdout must stay machine-readable
- include elapsed time
- cap archive/build/media work by profile
- avoid expensive fallback scans unless explicitly requested

## Guardrails

- Do not pretend an operation is percentage-complete when only phases are known.
- Do not spam one line per file unless debug mode is active.
- Do not hide warnings at the end only; surface critical blockers early.
- Do not use decorative output as a replacement for clear errors.

## Promotion notes

This is a generated draft. Review alongside PowerShell script-authoring guidance before promotion.
