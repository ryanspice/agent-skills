---
name: hermes-subprocess-delegation
description: Orchestrates Hermes delegate profiles as bounded subprocess lanes. Use when a lead agent needs to fan out work through the canonical Hermes profile adapter, local llama.cpp or Gemma-style aides, Spark/code workers, Nemotron/reasoning aides, or mixed-model reviews without overloading context or relying on unavailable delegate_task-style tools.
version: 0.1.1
type: universal-agent-skill
status: active
risk: medium
platforms: [windows, hermes, codex, claude-code]
tags: [hermes, delegation, subprocess, multi-agent, local-models, context-budgeting]
provenance_origin: "original"
provenance_source_path: "04_skills/agent-skills/skills/hermes-subprocess-delegation/SKILL.md"
provenance_credit: "Ryan Spice-Finnie"
provenance_ingested_as: "ryanspice/agent-skills owned skill"
provenance_note: "Original AI Wiki local skill credited to Ryan Spice-Finnie, promoted from a PixelBoats project delegation rule into a reusable Hermes subprocess pattern."

---

# Hermes Subprocess Delegation

Use this skill when a lead agent needs separate Hermes profiles to inspect, critique, research, code, or verify a bounded slice of work.

## Core Rule

Dispatch one bounded subprocess per delegate lane through the canonical adapter:

```powershell
$adapter = (Get-Command Invoke-FuguLane.ps1 -ErrorAction Stop).Source
& $adapter -Lane <mapped-lane> -Prompt "<bounded task>" -Tag <source-tag> -OutFile <output-path>
```

Do not hand-write `hermes -p ... chat`, `Start-Job`, or `Start-Process`
launches. If a required profile is not mapped, update the adapter first. Do not
assume an in-session `delegate_task` tool exists. Do not use mixture-of-agents
when the job needs role-specific delegation, independent logs, different
context limits, or different timeouts.

## Delegate Packet

Keep each delegate prompt small and explicit:

```text
ROLE: <profile role>
TASK: <one bounded task>
CONTEXT: <short facts or exact file list>
OUTPUT: <format, max bullets/sections, no edits unless assigned>
LIMITS: <no broad scan, no secrets, no deploy/delete, timeout expectation>
```

Prefer exact file paths or pasted contracts over "read the repo." If a delegate needs repo context, ask for an inventory or review of named files only.

## Context Budgeting

Before launching a profile, account for the model's real live context, not only the profile config.

- For local llama.cpp/Gemma-style profiles, Hermes profile rules, skills, tool descriptions, and AGENTS/SOUL injection can consume most of an 8k-16k server context.
- For tiny local thinking aides, try `--ignore-rules`, an empty toolset, and low `--max-turns`.
- If Hermes still exceeds context, do not call the model broken. Mark the Hermes lane blocked by context overhead and use the model's direct helper or OpenAI-compatible endpoint when available.
- Keep Gemma/gemmable-style "second brain" prompts especially short. They should critique, reframe, or identify risks, not author the final deliverable.

Minimal low-context shape must be represented by a mapped adapter lane:

```powershell
& $adapter -Lane <low-context-lane> -Prompt "<short task>" -Tag <source-tag> -MaxTurns 1 -GrantToolsets ""
```

## Windows Launch Pattern

Use the canonical adapter. It preserves argument boundaries, enforces
leaf-lane policy, and launches console-subsystem children with
`UseShellExecute = false` plus `CreateNoWindow = true`.

```powershell
$adapter = (Get-Command Invoke-FuguLane.ps1 -ErrorAction Stop).Source
& $adapter `
  -Lane $lane `
  -Prompt $query `
  -Tag "delegate-run" `
  -OutFile $stdout `
  -TimeoutSec 900 `
  -MaxRuntimeSec 1800
```

Never use `Start-Job` for this workflow: it creates another PowerShell process
and can flash a console when called from a GUI or hidden automation host.
Avoid `Start-Process -ArgumentList @(...)` for complex prompts; it can both
flash and split the prompt into stray Hermes arguments.

## Timeout and Monitoring

Use long enough timeouts for slow profiles and local model startup, but keep tasks narrow.

- Health probes: 5-10 minutes when the model may be cold.
- Real delegate lanes: 15-30 minutes only for bounded work.
- Emit heartbeat logs every 30-60 seconds with elapsed time and stdout/stderr sizes.
- Capture stdout, stderr, exit code, profile, source tag, session id, duration, and whether output was complete.
- Kill only the child job/process you launched after its configured timeout.

Do not treat silence as failure before the timeout. Slow reasoning models may stream late.

## Role Routing

- Use Spark/code-flash/code-spark for file inventory, patch maps, routine code examples, and scoped implementation help.
- Do not rely on Spark as the final thinking authority for architecture or risk decisions.
- Use Nemotron/review-pro/large reasoning profiles for pasted interfaces, diffs, contracts, architecture risks, and decision review.
- Use Gemma/gemmable/local models as concise second-brain or skeptic aides with tight context.
- Treat every delegate output as evidence. The lead still decides, verifies, and owns the final claim.

## Safety Rules

- One primary writer owns live repo edits.
- Delegates should default to no edits unless explicitly assigned a file-writing lane.
- Never send secrets, `.env`, auth files, raw browser data, raw databases, WAL/SHM files, or unrelated personal folders.
- For active worktrees, check dirty state and user-activity gates before delegate writes.
- If a delegate cannot run, report `blocked` or `degraded`; do not invent its result.

## Output Contract

After a delegated pass, the lead should report:

```text
DELEGATES
- profile:
- task:
- status: completed | degraded | blocked | timed out
- duration:
- evidence:
- useful findings:
- lead decision:
```

Keep raw logs in a run artifact folder when they are useful, but summarize only the relevant findings in the final report.
