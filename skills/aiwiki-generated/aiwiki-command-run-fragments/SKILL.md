---
name: aiwiki-command-run-fragments
version: 0.1.7
status: generated
skill_type: powershell-snippets
tags:
  - ai-wiki
  - powershell
  - run
  - search
  - elasticsearch
  - everything
  - tar
  - cleanup
  - spinner
  - eta
provenance_origin: "original"
provenance_source_path: "04_skills/generated/aiwiki-command-run-fragments/SKILL.md"
provenance_note: "Original AI Wiki generated skill."

---

# AI Wiki Command Run Fragments

## Purpose

Standardize short PowerShell command fragments for AI Wiki package/research workflows, with visible progress, ETA history, and hidden search service startup.

## Commands

```powershell
Use-Run
Use-Search
Search
Reindex
Index
Clean
Run
Test-Elastic
Start-Elastic
Stop-Elastic
Restart-Elastic
Start-Everything
Start-SearchServices
Status-SearchServices
```

## Reload after upgrade

```powershell
"Use-Run","Use-Search","Use-AiWikiRun","Use-AiWikiSearch","Search","Reindex","Index","Clean","Run","Test-Elastic","Start-Elastic","Stop-Elastic","Restart-Elastic","Start-Everything","Start-SearchServices","Status-SearchServices" |
  ForEach-Object { Remove-Item "Function:\$_" -ErrorAction SilentlyContinue }

. "<AI_WIKI_ROOT>\04_skills\generated\aiwiki-command-run-fragments\scripts\Load-AiWikiCommandFragments.ps1"
```

## Normal use

```powershell
Use-Run -WithSearch
Status-SearchServices
Start-Elastic
Search "deep research skill copy"
Reindex
```

## Search service behavior

`Start-Elastic` avoids blank visible CMD windows by starting Elastic hidden/backgrounded where possible. It shows progress in the current terminal and writes logs to:

```txt
04_skills/generated/aiwiki-command-run-fragments/.runtime/search-services/
```

Startup order:

1. existing reachable Elastic;
2. Windows Elastic/Elasticsearch service;
3. Docker Elastic/Elasticsearch container;
4. direct `elasticsearch.bat` under `<SEARCH_ROOT>\.runtime`, hidden;
5. `<SEARCH_ROOT>\scripts\Start-Elastic*.ps1`, hidden fallback.

`Search`, `Index`, and `Reindex` call `Start-SearchServices` first, then continue with fallback lanes if Elastic or Everything are unavailable.

## Rules

- Long commands must show visible progress in the current terminal.
- Do not spawn unexplained visible blank shells.
- If Elastic cannot start, continue with `rg`/available lanes rather than blocking.
- No `-Apply` means dry-run.
- Prefer TAR-only packages with internal installers.
- Avoid copying `node_modules`.

## v0.1.8 polish notes

- Use `Use-Run -WithSearch -Quiet` for normal day-to-day use.
- Explicit status remains available through `Status-SearchServices`.
- Explicit startup remains available through `Start-SearchServices` and `Start-Elastic`.
- `Search`, `Index`, and `Reindex` support `-NoServiceStart` if services are already known-good.
- Avoid passing installer `-Open` unless you actually need to inspect generated files.

## v0.1.9 output polish notes

- Child `Search`, `Reindex`, `Index`, and `Clean` calls suppress the repeated `Loaded Search environment` banner.
- Output is compressed to remove repeated blank lines.
- Use `-Raw` when debugging the underlying `<SEARCH_ROOT>` output:

```powershell
Search -Raw "deep research skill copy"
Reindex -Raw
```

- Use `-NoServiceStart` when Elastic/Everything are already known-good:

```powershell
Search -NoServiceStart "deep research skill copy"
Reindex -NoServiceStart
```

## v0.2.0 pretty output notes

Search output is now parsed and color-coded by default.

Use raw mode when debugging the underlying `<SEARCH_ROOT>` output:

```powershell
Search -Raw "deep research skill copy"
Reindex -Raw
```

Quiet mode now suppresses the `<SEARCH_ROOT>` loader banner:

```powershell
Use-Run -WithSearch -Quiet
```

Verbose service diagnostics are still available:

```powershell
Use-Run -WithSearch -VerboseServices
Status-SearchServices
Start-SearchServices
```
