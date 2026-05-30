---
name: verbose-console-output
version: 0.0.1
type: universal-agent-skill-draft
status: generated-draft
risk: low
description: Designs optional verbose console output for CLI tools, scripts, and agent-run commands using clear phases, counts, elapsed time, and Vite/Webpack-inspired readability without spamming normal output.
tags: [console, cli, powershell, python, logging, verbose, ux]
provenance_origin: "original"
provenance_source_path: "04_skills/generated/verbose-console-output-v0.0.1/SKILL.md"
provenance_credit: "Ryan Spice-Finnie"
provenance_note: "Original AI Wiki generated skill credited to Ryan Spice-Finnie."

---
# Verbose Console Output

## Purpose

Use this skill when adding an optional `-Verbose`, `--verbose`, `-ShowProgress`, or similar mode to scripts, CLIs, installers, search tools, build helpers, or agent-operated utilities.

Verbose output should answer:

- What is happening now?
- How far through the known work are we?
- How many items have been processed?
- How long has it taken?
- What engine/profile/root/config is being used?
- What should the user do if zero results or failure occurs?

It must not turn normal output into soup. Default output stays compact.

## Trigger phrases

Use when the user asks for:

- verbose console output
- Vite-style CLI output
- Webpack/Vite/Nuxt-like terminal UX
- progress bars in scripts
- `x/y` processed counters
- elapsed timers
- better script logging
- loader output
- pretty terminal output for PowerShell/Python scripts

## Output modes

| Mode | Purpose | Default |
|---|---|---:|
| quiet | machine-readable or minimal output | optional |
| normal | concise human result | yes |
| verbose | phases, config, counters, timings | no |
| json | structured automation output | optional |
| debug | deep internals, commands, stack details | no |

## Style model

Borrow the useful parts of modern build tools:

- Vite: short headers, fast status lines, clean arrows, elapsed time.
- Webpack: module/count summaries when work is itemized.
- Nuxt/SvelteKit: helpful next-step hints, local paths, concise success/failure state.
- Rust/Cargo: deterministic phases and explicit errors.

Avoid decorative excess. A tool is not a nightclub flyer.

## Recommended line shapes

```txt
Search v0.1.4
  ➜ brokered local search
  [████████░░░░░░░░░░░░░░]  40% 2/5 select engine → rg · 21ms
  ➜ query: audiointel elastic linux
  ➜ profile: wiki-default
  ➜ rg: 14 result(s) in 82ms
  [██████████████████████] 100% 5/5 search complete · 109ms
```

For itemized operations:

```txt
Index v0.1.4
  [███████████░░░░░░░░░░░]  50% 342/684 files scanned · 4.12s
  ➜ chunks: 1,922
  ➜ skipped: 88 binary, 41 generated, 12 too large
```

## Requirements

- `-Verbose` / `--verbose` must be optional.
- Normal output must remain compact and copyable.
- Progress percentages must not pretend to be exact when the tool only has phase-level progress.
- Use phase progress for unknown-duration work.
- Use `x/y` counters only when the total is known.
- Always include elapsed time for long-running phases.
- Show active root/corpus/profile/engine when relevant.
- Zero-result messages should say what was already tried and what to try next.
- Errors should include the failing phase and target path, but redact secrets.

## PowerShell guidance

PowerShell may consume `-Verbose` as a common parameter. Wrapper functions/scripts should explicitly forward it to the underlying CLI.

Pattern:

```powershell
[CmdletBinding()]
param(
  [Alias('VerboseSearch', 'Progress')]
  [switch] $ShowProgress,

  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]] $RemainingArgs
)

if ($PSBoundParameters.ContainsKey('Verbose') -or $ShowProgress) {
  $PythonArgs += '--verbose'
}
```

## Python guidance

Use a small output helper rather than scattering `print()` everywhere.

Required helper concepts:

- `header(detail)`
- `phase(message, step)`
- `note(message)`
- `done(message)`
- `progress_line(label, current, total, started)`

## Guardrails

- Do not emit progress bars in JSON mode.
- Do not animate spinners in non-interactive/CI mode unless explicitly requested.
- Do not write secrets, tokens, `.env` values, or full private paths unless needed for local troubleshooting.
- Do not bury the real error under decoration.

## Promotion notes

This is a generated draft. Review against existing PowerShell authoring skills before promoting to `04_skills/universal/verbose-console-output/SKILL.md`.
