---
name: verbose-console-output
version: 0.0.5
type: universal-agent-skill-draft
status: generated-draft
risk: low
description: Designs optional verbose console output for CLI tools, scripts, and agent-run commands using clean phase status, counts, elapsed time, and Vite/Webpack-inspired readability without spamming normal output.
tags: [console, cli, powershell, python, logging, verbose, ux, progress]
provenance_origin: "modified"
provenance_source_path: "04_skills/generated/verbose-console-output-v0.0.5/SKILL.md"
provenance_credit: "Ryan Spice-Finnie"
provenance_ingested_as: "ryanspice/agent-skills owned skill"
provenance_note: "Revised generated draft credited to Ryan Spice-Finnie, derived from the v0.0.1 verbose console output skill."
provenance_upstream: "04_skills/generated/verbose-console-output-v0.0.1/SKILL.md"

---
# Verbose Console Output

## Purpose

Use this skill when adding optional `-Verbose`, `--verbose`, `-ShowProgress`, or similar modes to scripts, CLIs, installers, search tools, build helpers, or agent-operated utilities.

Verbose output should answer:

- What is happening now?
- Which root/corpus/profile/engine/config is being used?
- How far through the known work are we?
- How many items have been processed, when known?
- How long has it taken?
- What was tried if zero results or failure occurs?

Default output stays compact. JSON output stays machine-readable.

## Core console contract

For interactive terminals, progress should update **one live status line** using carriage-return/clear-line behavior. Do not print one new status line per phase unless the terminal is non-interactive, static logging is requested, or CI/log capture is active.

Result names, file paths, match snippets, and summaries should be buffered and printed **after** the final progress line. Do not interleave file names with loaders.

Good:

```txt
Search v0.1.6
  ➜ brokered local search
  [█████████████░░░░░░░░░]  60% 3/5 run broker search → 50 result(s) · 4.81s
  [██████████████████████] 100% 5/5 search complete · 4.85s

Search: pixelboats minimap clipping
Engine: broker (rg)  Profile: wiki-default  Results: 50  Time: 4.85s
Tried:  rg: 50 in 769ms
Root:   <AI_WIKI_ROOT>

1. <AI_WIKI_ROOT>\...
```

Bad:

```txt
[25%] load config
[50%] check engines
[75%] format results
1. file result
2. file result
[100%] done
```

That final done line after results is backwards. Tiny terminal crimes still count.

## Output modes

| Mode | Purpose | Default |
|---|---|---:|
| quiet | machine-readable or minimal output | optional |
| normal | concise human result | yes |
| verbose/progress | live status, phases, counts, timings | no |
| json | structured automation output | optional |
| debug | internals, commands, stack details | no |

## Style model

Borrow the useful parts of modern build tools:

- **Vite:** short headers, current action line, clean completion.
- **Webpack:** counters and summarized module/file stats when itemized.
- **Nuxt/SvelteKit:** next-step hints and local paths after completion.
- **Cargo/Rust:** deterministic phases and explicit errors.

Avoid decorative excess. A CLI is not a nightclub flyer.

## Requirements

- `-Verbose` / `--verbose` must be optional.
- Normal output must remain compact and copyable.
- Progress output should go to stderr when stdout may be consumed.
- Do not animate/progress in JSON mode.
- Use one live status line in interactive terminals.
- Use static durable lines only in non-interactive output, CI, logs, or with an explicit static-progress env flag.
- Progress percentages must not pretend to be exact when the tool only has phase-level progress.
- Use `x/y` counters only when the total is known.
- Always include elapsed time for long-running phases.
- Show active root/corpus/profile/engine when relevant, but do not spam those as separate lines during the loader.
- Zero-result messages should say what was already tried and what to try next.
- Errors should include failing phase and target path, but redact secrets.

## PowerShell guidance

PowerShell may consume `-Verbose` as a common parameter. Wrapper functions/scripts should explicitly forward it to the underlying CLI.

Pattern:

```powershell
[CmdletBinding()]
param(
  [Alias('VerboseSearch', 'Progress')]
  [switch] $ShowProgress,

  [Parameter(ValueFromRemainingArguments = $true)]
  [object[]] $RemainingArgs
)

$WantVerbose = $PSBoundParameters.ContainsKey('Verbose') -or $ShowProgress
$PythonArgs = @($Cli, $Command)
if ($WantVerbose) { $PythonArgs += '--verbose' }
$PythonArgs += @($CleanArgs)
& python @PythonArgs
```

## Python guidance

Use a small output helper rather than scattering `print()` everywhere.

Required helper concepts:

- `header(detail)` — one static heading.
- `phase(message, step)` — update the live status line.
- `done(message)` — write the final status line and newline.
- `progress_line(label, current, total, started)` — for known-count work.
- Buffer result lines and print only after `done()`.

Interactive line update pattern:

```python
sys.stderr.write("\r\x1b[2K" + status_text)
if final:
    sys.stderr.write("\n")
sys.stderr.flush()
```

Fallback to normal printed lines when stderr is not a TTY, CI is active, or a static-progress flag is set.

## Guardrails

- Do not emit progress bars in JSON mode.
- Do not spam one line per file unless debug mode is active.
- Do not hide critical errors under decoration.
- Do not expose secrets, tokens, `.env` values, or private client data.

## Promotion notes

This is a generated draft. Review against existing PowerShell authoring skills before promoting to `04_skills/universal/verbose-console-output/SKILL.md`.

## Interpolated loader behavior

For interactive terminals, progress should not jump abruptly between phases. Use a small interpolator:

- `phase(target)` sets the next target percentage.
- the visible bar eases quickly toward the target instead of jumping.
- during long waits, the bar may creep forward very, very slowly.
- each idle creep step should decay until the bar effectively stops.
- never let idle creep reach 100%; only completion may do that.
- when the next phase lands, move quickly to that phase target.

This creates a responsive Vite-like loader without lying about exact progress.

## Result output after loader

Hold filenames, result paths, match snippets, and noisy per-file details until the loader is complete. The terminal flow should be:

```txt
Header
Live status line, updated in place
Final 100% status line

Result summary
Grouped results
Next hints
```

## Safe path display

Normal human output should avoid leaking full local machine paths. Prefer display aliases:

- `<AI_WIKI_ROOT>\...` -> `..\AI-Wiki\...`
- `<AI_WIKI_ROOT>\...` -> `..\AI-Wiki\...`
- user profile paths -> `%USERPROFILE%\...`

Raw paths may remain available in JSON/debug output for automation.

## Group repeated directories

When many results share the same directory, group them:

```txt
..\AI-Wiki\projects\pixelboats\ (3 matches)
  1. .thoughts:42:1
     current issue snippet...
  2. feature-matrix.md:8:1
     matching snippet...
```

Do not repeat a long directory prefix on every row unless the output is explicitly machine-oriented.


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
