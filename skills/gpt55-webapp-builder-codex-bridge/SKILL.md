---
name: gpt55-webapp-builder-codex-bridge
description: Guides ChatGPT web-app sessions into a Codex-like human-in-the-loop builder workflow using reviewable scripts, PowerShell, Python, clipboard handoff, TAR.GZ bundles, manifests, hashes, cleanup, and approval gates. Use when the user wants GPT-5.5/ChatGPT to act like a builder, coding agent, package generator, repo helper, or Codex/Trae/Cursor-style bridge without direct local execution.
version: 0.1.0
platforms: [windows, chatgpt, ai-wiki, mcp, codex, trae, hermes]
tags: [builder-workflow, codex-bridge, powershell, python, clipboard, tar, human-in-the-loop, safety]
risk: medium-by-default; high when scripts mutate repos, delete files, call network APIs, touch secrets, or run native helpers
provenance_origin: "original"
provenance_source_path: "04_skills/generated/gpt55-webapp-builder-codex-bridge/SKILL.md"
provenance_credit: "Ryan Spice-Finnie"
provenance_ingested_as: "ryanspice/agent-skills owned skill"
provenance_note: "Original AI Wiki generated skill credited to Ryan Spice-Finnie."

---

# GPT-5.5 Web App Builder / Codex Bridge

## Purpose

Use ChatGPT web as the reasoning, planning, code-generation, review, and packaging layer while external scripts and the human operator bridge the parts the web app cannot directly do.

This skill does **not** pretend the browser is Codex. It turns the browser session into a **Codex bridge**:

```txt
ChatGPT Web = planner / reviewer / code generator
Clipboard = human-mediated transfer bus
PowerShell = Windows execution harness
Python = deterministic utility/orchestration layer
TAR.GZ = portable package / rollback / handoff format
Manifest + hashes = trust checkpoint
Human = final permission boundary
```

## Core rule

Never turn model output into invisible execution.

Every side-effecting operation must be:

1. previewable,
2. scoped to an explicit path,
3. runnable by the user or a constrained executor,
4. reversible or backed up when practical,
5. reportable with stdout/stderr, changed files, and verification notes.

If a script deletes, overwrites, installs, publishes, sends, pushes, calls paid APIs, touches credentials, or runs outside the workspace, require a higher-friction approval step. Do not be cute. Cute is how the repo becomes soup.

## When to use

Use this skill when the user asks to:

- use ChatGPT/GPT-5.5 like Codex, Trae, Cursor, or a builder agent
- generate a script/package that applies repo changes locally
- make a Windows-first PowerShell handoff workflow
- package files as TAR.GZ for import into a repo or AI Wiki
- copy generated prompts/scripts/context through the clipboard
- produce self-cleaning temp scripts or cleanup helpers
- abstract browser limitations through human-run commands
- create reviewable install/apply scripts with dry-run and backup behavior
- build a human-in-the-loop local execution bridge
- design a web app that orchestrates tools safely

Do **not** use this skill for ordinary one-off coding answers unless the answer needs a repeatable apply/handoff workflow.

## Default assumptions for Ryan

- Windows 11 first.
- PowerShell 7 command examples use `pwsh -NoProfile -ExecutionPolicy Bypass`.
- Downloads and generated artifacts often land in `<DOWNLOADS_ROOT>`.
- Canonical AI Wiki root is `<AI_WIKI_ROOT>`.
- Generated skills live under `04_skills/generated/<skill>/SKILL.md`.
- Repo-local `.ai/skills` copies are mirrors/pointers, not canonical sources.
- Prefer TAR.GZ packages with README, CHANGELOG, `.thoughts`, manifests, hashes, and verification notes for larger handoffs.
- Prefer targeted PowerShell scripts over huge pasted edits when work is file-heavy.

## Workflow

### 1. Classify the requested builder mode

Pick one mode before generating scripts.

| Mode | Use when | Output |
|---|---|---|
| **Prompt-only** | The user needs a Trae/Codex/Hermes prompt | One paste-ready prompt + checklist |
| **Clipboard bridge** | The user needs to move text/context/scripts between ChatGPT and local tools | Clipboard-safe command/script |
| **Single apply script** | Small targeted repo edits or setup | One `.ps1` with dry-run/apply/backup |
| **Package handoff** | Multi-file feature, skill, docs, assets, route, or lab | TAR.GZ + installer/apply script |
| **Tool architecture** | Designing a builder web app or MCP/native helper | Architecture plan + contracts + risk gates |
| **Review loop** | User pasted logs/output from a local run | Diagnose, tighten, produce next command/script |

### 2. Decide the permission/risk tier

| Tier | Examples | Required behavior |
|---|---|---|
| **Read-only** | Inspect files, list archive contents, summarize logs | No confirmation needed after user request |
| **Local write** | Generate files in repo/workspace, copy skill to AI Wiki generated shelf | Dry-run or clear preview, explicit target path |
| **Destructive** | Delete/replace files, force overwrite, cleanup downloads | Backup or reversible path, `-Force` style switch |
| **Network/API** | Install packages, call model APIs, fetch remote files | Explain endpoint/source, avoid secrets in logs |
| **Credential/system** | Tokens, registry, native messaging host, system PATH, services | Hard stop unless explicitly requested in same turn |

### 3. Produce the smallest safe artifact

Prefer this order:

1. direct code block for tiny fixes,
2. copy-paste PowerShell for small deterministic edits,
3. downloadable script for longer automation,
4. TAR.GZ package for multi-file work,
5. architecture spec before native helpers or server executors.

Do not dump a giant script into chat when a downloadable file is more reliable.

### 4. Make scripts boring and inspectable

Generated PowerShell should normally include:

```txt
param(...)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
preflight paths
DryRun/WhatIf behavior
backup before overwrite
literal paths, not wildcard footguns
clear status output
try/finally temp cleanup
exit code handling
verification commands
```

Generated Python should normally use:

```txt
pathlib
json
hashlib
shutil
tarfile with safe extraction filters where available
subprocess.run(argv, shell=False)
tempfile.TemporaryDirectory
explicit encoding='utf-8'
```

### 5. Use TAR.GZ as a handoff contract

For multi-file packages, include:

```txt
package-root/
  SKILL.md or source files
  README.md
  CHANGELOG.md
  .thoughts
  manifest.json
  hashes.sha256
  scripts/
  reference/
  templates/
  examples/evals/
```

Before telling the user to run an installer, provide:

- archive path,
- destination path,
- whether it overwrites anything,
- backup path if applicable,
- dry-run command,
- apply command,
- verification command.

### 6. Use clipboard as a human transfer bus

Clipboard access is useful, but it is not magic IPC.

Use clipboard for:

- copying generated prompts,
- copying script output back into ChatGPT,
- moving compact manifests/log summaries,
- staging one command for the user to inspect and run.

Avoid clipboard for:

- secrets,
- silent polling,
- huge binary/base64 payloads,
- hidden execution instructions.

If generating clipboard commands, prefer explicit names such as:

```powershell
Set-Clipboard -Value $PromptText
Get-Clipboard -Raw
```

### 7. Treat self-deleting scripts as cleanup, not security

Self-deleting or self-cleaning behavior is acceptable for temporary installers and scratch helpers, but it is only hygiene.

Prefer parent-driven cleanup:

```txt
wrapper creates temp dir -> writes temp script -> runs child -> captures output -> deletes temp dir
```

Do not claim deletion securely erases secrets. If secrets are involved, do not write them to disk unless the user explicitly asks and the script explains the risk.

### 8. Normalize local run results

When the user returns terminal output, ask ChatGPT to interpret it in this shape:

```json
{
  "ok": false,
  "command": "...",
  "cwd": "...",
  "exitCode": 1,
  "stdoutSummary": "...",
  "stderrSummary": "...",
  "changedFiles": [],
  "likelyCause": "...",
  "nextAction": "..."
}
```

Then produce the next smallest correction. Do not spiral into a redesign because one semicolon had a bad evening.

## Output patterns

### For a generated command

```markdown
## Run this

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File "<DOWNLOADS_ROOT>\script.ps1" -DryRun
```

## Then apply

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File "<DOWNLOADS_ROOT>\script.ps1" -Apply
```

## Verify

```powershell
bun test
bun run build
```
```

### For a package

```markdown
## Package

- Archive: `...tar.gz`
- Installer: `...ps1`
- Destination: `...`
- Backup: created only if destination exists and `-Force` is used

## Dry-run

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File "...install.ps1" -DryRun
```

## Apply

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File "...install.ps1" -Force -CleanTemp
```
```

## Safety gates

Hard-stop and ask for explicit confirmation when the next action would:

- delete or overwrite outside the named workspace,
- use broad paths like `C:\`, user profile root, or `<AI_WIKI_ROOT>` without a narrow child path,
- read or write secrets,
- install global packages,
- modify PATH, registry, services, shell startup, or browser native messaging hosts,
- publish, push, email, bill, deploy, or expose anything publicly,
- run a script downloaded from a non-reviewed source.

## Reference files

Read these when the task needs more depth:

- `reference/research-summary.md` - research findings behind this workflow.
- `reference/architecture-patterns.md` - web app, server executor, MCP, native helper, and browser-only patterns.
- `reference/safety-and-trust-boundaries.md` - approval gates, prompt injection, archive safety, logging, secrets.
- `reference/windows-script-patterns.md` - PowerShell/Python/TAR/clipboard/self-cleanup patterns.
- `reference/install-surfaces.md` - AI Wiki, repo mirror, MCP, Codex/Trae/Hermes placement rules.

## Templates

Use these as copy sources:

- `templates/builder-handoff-prompt.md`
- `templates/human-run-script-request.md`
- `templates/package-manifest.template.json`
- `templates/powershell-apply-wrapper.ps1.tmpl`
- `templates/tool-result-envelope.template.json`

## Evals

Before promoting changes to this skill, test at least:

1. a harmless package generation request,
2. an ambiguous “run this everywhere” request,
3. an archive extraction request,
4. a clipboard handoff request,
5. a dangerous credential/system request.

Expected behavior: choose the smallest safe bridge, show path/risk clearly, generate dry-run first for writes, and refuse or escalate high-risk hidden execution.
