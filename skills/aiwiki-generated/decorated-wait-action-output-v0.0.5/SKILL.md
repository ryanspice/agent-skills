---
name: decorated-wait-action-output
version: 0.0.5
type: universal-agent-skill-draft
status: generated-draft
risk: low
description: Designs console output for actions users must wait on, such as installs, indexing, package extraction, cleanup, builds, long scans, and agent operations, with live status, safe dry-run/apply boundaries, and clear completion states.
tags: [console, cli, powershell, python, progress, installer, long-running, ux]
provenance_origin: "modified"
provenance_source_path: "04_skills/generated/decorated-wait-action-output-v0.0.5/SKILL.md"
provenance_credit: "Ryan Spice-Finnie"
provenance_note: "Revised generated draft credited to Ryan Spice-Finnie, derived from the v0.0.1 decorated wait action output skill."
provenance_upstream: "04_skills/generated/decorated-wait-action-output-v0.0.1/SKILL.md"

---
# Decorated Wait Action Output

## Purpose

Use this skill when a script or CLI action takes long enough that the user may wonder whether it froze.

This differs from verbose output:

- **Verbose output** explains internals when requested.
- **Decorated wait output** reassures the user during long actions and avoids terminal soup.

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

## Output contract

A wait-action script should show:

1. **Identity:** tool name and version.
2. **Mode:** dry-run/apply/force/cleanup.
3. **Targets:** paths or services being touched.
4. **Progress:** one live status line when interactive; static lines when non-interactive.
5. **Elapsed time:** per phase or total.
6. **Safety boundary:** what was skipped or not deleted.
7. **Completion:** success, warnings, next commands.

## Live loader contract

For interactive terminals, update the progress bar/status on top of itself. Do not print one new progress bar per phase. Hold noisy output, especially filenames and match lists, until the final result section.

Good:

```txt
Search Local Broker installer v0.1.6
Mode: APPLY
SearchRoot:   <SEARCH_ROOT>
RuntimeRoot:  <SEARCH_ROOT>\.runtime\aiwiki-search
AI Wiki root: <AI_WIKI_ROOT>

  [████████████████░░░░░░] 75% 3/4 copy files · 1.31s
  [██████████████████████] 100% 4/4 install complete · 1.38s

Next:
  . <SEARCH_ROOT>\scripts\Load-SearchEnv.ps1
  Status -Verbose
  Search "audiointel elastic linux" -Verbose
```

Bad:

```txt
[25%] validate
[50%] extract
[75%] copy
one thousand filenames...
[100%] done
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
- also support durable static progress for logs/CI
- support `-Verbose`/`-ShowProgress`
- exit non-zero on failure when used as a tool

## Python guidance

Good long-running Python commands should:

- separate progress/log output from JSON output
- send progress to stderr when stdout must stay machine-readable
- update one status line interactively using carriage return and clear-line
- include elapsed time
- cap archive/build/media work by profile
- avoid expensive fallback scans unless explicitly requested

## Guardrails

- Do not pretend an operation is percentage-complete when only phases are known.
- Do not spam one line per file unless debug mode is active.
- Do not hide warnings at the end only; surface critical blockers early.
- Do not use decorative output as a replacement for clear errors.
- Do not expose secrets or client-sensitive paths/data unless required for local debugging.

## Promotion notes

This is a generated draft. Review alongside PowerShell script-authoring guidance before promotion.


## Smooth wait animation rule

For long-running actions, use an interpolated one-line loader when interactive:

- move quickly toward real phase changes;
- creep slowly during long waits;
- decay creep speed until it stops;
- never print filenames during the loader;
- print grouped summaries after completion.

For cleanup, indexing, archive scans, and installer work, show counts/sizes after completion rather than streaming every touched file unless `--debug` is requested.

## Path privacy rule

Human-facing output should use stable aliases for local roots, especially knowledge vaults and user folders. Prefer `..\AI-Wiki` over full drive/OneDrive paths. Keep raw paths for JSON logs and machine-readable reports only.


## v0.0.5 build-tool result output doctrine

Use the best parts of Vite/Webpack-style output for completed result blocks:

- Show one compact header: command/result status, elapsed time, engine/tool, profile/mode, root, and counts.
- Print results after the loader, never during the loader.
- Group by signal tier first when useful: primary matches first, generated/audit/index/backups lower.
- Group by directory, then file. Print each file name once.
- Collapse repeated/similar snippets from the same file. Prefer `+N more matches` over repeating the same path with tiny line changes.
- Redact local machine roots in normal output. Use stable aliases like `..\AI-Wiki`; keep raw paths only in JSON/tooling mode.
- Keep noisy machine-readable inventory, CSV, JSONL, backup, and candidate-index hits available, but visually lower-priority.
- Keep output scannable at 50+ hits: file blocks, short snippets, collapsed duplicates, and obvious summaries.

Example shape:

```txt
Search ready in 4.82s
  query    pixelboats minimap clipping
  engine   broker → rg
  profile  wiki-default
  matched  50 hits across 21 files / 8 folders
  root     ..\AI-Wiki
  tried    rg 50 in 804ms

..\AI-Wiki\07_Projects\pixelboats\
  ◼ .thoughts · 4 hits
     1. L42 PixelBoats minimap clipping...
     2. L88 Minimap persistent behavior...
     +2 more matches

  lower-signal / generated-index noise (24 hits)
..\AI-Wiki\03_Indexes\skills\
  ◼ active-skills.json · 8 hits
     16. L10 14
     +7 more matches, 3 duplicate/similar
```


## v0.0.5 additions

- Use color only when the terminal supports it or color is explicitly forced. Respect `NO_COLOR`, CI, and redirected output.
- Borrow from Vite/Webpack output: short ready state, colored success/warning accents, dim metadata, concise section headers, and grouped result blocks.
- Do not let long JSON/CSV lines corrupt display parsing. Prefer structured parser output from underlying tools when available.
- Redact local roots in normal output: AI Wiki roots become `..\AI-Wiki`, user profile becomes `%USERPROFILE%`, dev roots become `<dev>`, and browser/temp download roots become `<browser>`.
- Keep raw absolute paths in JSON/debug output only.
- Collapse repeated same-file hits and duplicate/similar snippets. Show a few representative lines plus `+N more`.
