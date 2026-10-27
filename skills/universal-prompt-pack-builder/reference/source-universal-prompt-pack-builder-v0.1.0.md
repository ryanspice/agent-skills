---
name: universal-prompt-pack-builder
version: 0.1.0
schema_version: 1
last_updated: 2026-05-18
description: >
  A universal skill for designing, writing, reviewing, and packaging prompt packs for ChatGPT 5.5 and adjacent coding/reasoning agents. Use it to turn messy project context into ordered prompts, docs, checklists, state files, and downloadable handoff packs.
target_models:
  - ChatGPT 5.5 Thinking
  - ChatGPT / GPT coding agents
  - Codex
  - Trae
  - Claude / Claude Code
risk: medium
manual_approval_required_for:
  - destructive file operations
  - production deploys
  - credential handling
  - billing/account changes
  - irreversible migrations
  - scope expansion beyond the approved brief
---

# Universal Prompt Pack Builder Skill

## 1. Purpose

Use this skill when the user wants a **prompt pack**, **agent handoff**, **downloadable project pack**, **implementation prompt sequence**, **audit prompt sequence**, or **reusable skill**.

A prompt pack is not just a big prompt. It is a small operating manual for an AI agent:

- what to read
- what to change
- what not to touch
- what order to work in
- how to verify
- how to report uncertainty
- how to continue in the next chat

The goal is to reduce vague prompting, prevent scope creep, and make AI work repeatable instead of vibes with filenames.

---

## 2. Core Rule

**Prefer one clear engage prompt plus a small ordered pack.**

Do not create a giant unreadable super-prompt unless the user explicitly needs a single paste. For larger work, split the pack into:

1. context
2. execution prompt
3. verification prompt
4. follow-up prompt
5. human QA checklist
6. `.thoughts` state file

Keep individual prompts under **6000 characters** when practical, especially for Trae, Claude, Codex, and repo-bound agents.

---

## 3. When to Use This Skill

Use this skill for:

- feature implementation handoffs
- UI mockup/build prompts
- repo audit prompts
- regression stabilization prompts
- research-to-implementation packs
- no-code planning/audit packs
- multi-agent workflows
- packaging tasks into TAR.GZ/ZIP/Markdown downloads
- creating `.ai/skills/<skill-name>/SKILL.md` style skills
- converting loose chat notes into an execution plan

Do **not** overuse this for tiny fixes. A one-file bug can usually be solved with a direct command or short prompt. Prompt packs are for work with enough moving parts that the next agent could otherwise wander off and start building a lighthouse in a toaster.

---

## 4. Default Pack Shape

Use this structure unless the user gives a better one:

```txt
<project-or-task-slug>-prompt-pack-vX.Y.Z/
  README.md
  .thoughts
  prompt-pack.md

  prompts/
    00-engage.md
    01-main-implementation.md
    02-review-tighten-regression.md
    03-followup-or-extraction.md
    90-human-qa.md

  docs/
    brief.md
    implementation-checklist.md
    qa-acceptance.md
    file-scope.md
    risk-register.md
    continuation-notes.md

  references/
    source-notes.md
    source-screenshots-or-assets-placeholder.md

  skills/
    relevant-skill-or-guardrail.SKILL.md

  scripts/
    apply-or-verify.ps1
```

For smaller packs, collapse to:

```txt
README.md
.thoughts
prompts/00-engage.md
prompts/01-main.md
docs/checklist.md
```

For a single downloadable skill, use:

```txt
<skill-name>-SKILL-vX.Y.Z.md
```

and tell the user it can be renamed to:

```txt
.ai/skills/<skill-name>/SKILL.md
```

---

## 5. Naming and Versioning

Use Semantic Versioning.

- `v0.1.0` = first usable version
- PATCH = small fix, wording correction, checklist tweak
- MINOR = new section, new workflow, new prompt type, broader capability
- MAJOR = incompatible structure or changed operating model

File naming examples:

```txt
pixelboats-sfx-manager-ui-prompt-pack-v0.2.0.tar.gz
canopy-seo-dashboard-prompt-pack-v0.1.0.tar.gz
universal-prompt-pack-builder-SKILL-v0.1.0.md
```

Use lowercase slugs for packs. Keep project-specific names out of universal skills unless they are examples.

---

## 6. Required Inputs

Before building a pack, infer what you can from the conversation. Ask only when a missing detail is truly blocking.

Minimum input contract:

```yaml
project: ""
goal: ""
artifact_type: "implementation | audit | planning | UI mockup | research | skill | mixed"
target_agent: "ChatGPT 5.5 | Trae | Codex | Claude | mixed"
source_of_truth:
  - repo path, uploaded tar, screenshot, spec, existing file, docs, chat notes
allowed_scope:
  - files/routes/modules allowed to change
non_goals:
  - explicit exclusions
verification:
  - commands to run
  - manual QA checks
risk_tier: "low | medium | high"
delivery_format: "markdown | tar.gz | zip | folder"
```

If the user does not specify an agent, default to **ChatGPT 5.5 for reasoning/planning** and include adaptation notes for Trae/Codex/Claude when relevant.

---

## 7. Agent Routing Block

Every substantial pack should include a route block near the top of `README.md` or `prompt-pack.md`.

```yaml
route:
  task_class: "implementation | audit | design | research | stabilization | packaging"
  artifact_class: "repo changes | no-code report | static UI | production patch | prompt pack"
  target_surface: "specific route/module/file/app area"
  budget_profile: "small | medium | large"
  risk_tier: "low | medium | high"
  preferred_agent: "ChatGPT 5.5 | Codex | Trae | Claude"
  approval_gate: "none | before writes | before destructive ops | before deploy"
  fallback_route: "what to do if blocked"
```

This prevents the next agent from guessing the job class. Guessing is where the goblins live.

---

## 8. `.thoughts` Contract

Use `.thoughts`, not `.thoughts.md`, unless the user or repo already standardizes otherwise.

`.thoughts` is the mutable state file. It should be readable Markdown with YAML frontmatter.

```md
---
schema_version: 1
project: "<project>"
pack_version: "0.1.0"
repo_version: "unknown"
last_updated: "YYYY-MM-DD"
status: "draft | ready | in-progress | blocked | verified"
current_phase: ""
risk_tier: "low | medium | high"
preferred_agent: "ChatGPT 5.5"
next_action: ""
source_commit: "unknown"
---

# .thoughts

## Current Goal

## Current State

## Non-Negotiables

## Approved Scope

## Decisions

## Known Issues / Risks

## Verification Commands

## Manual QA Checklist

## Files Expected to Change

## Next Chat Checkpoint
```

Rules:

- Keep it factual.
- Mark uncertainty explicitly.
- Do not bury secrets in it.
- Update it after implementation or review passes.
- Use it to stop future agents from repeating already-settled debates.

---

## 9. Prompt Types

### 9.1 Engage Prompt

Use this as the first prompt in most packs.

```md
# Engage Prompt

You are working from the attached prompt pack.

First, read:

1. README.md
2. .thoughts
3. docs/brief.md
4. docs/file-scope.md
5. prompts/01-main-implementation.md

Do not start coding until you have identified:

- the target files
- the allowed scope
- non-goals
- verification commands
- known risks

Then execute the main prompt. If the repo contradicts this pack, trust the repo and report the mismatch.

Do not scaffold a new project unless the prompt explicitly says this is a scaffold task.
Do not add dependencies unless the pack explicitly allows them or they are strongly justified.
Do not touch secrets, credentials, billing, deployment, or destructive operations without explicit approval.
```

### 9.2 Main Implementation Prompt

```md
# Main Implementation Prompt

## Goal

<state the concrete outcome>

## Context

<brief context, current behavior, desired behavior>

## Source of Truth

Use these files/docs/screenshots as source of truth:

- <file/doc>

## Allowed Scope

You may edit:

- <path>

You may add:

- <path>

You must not edit:

- <path>

## Requirements

- <requirement>
- <requirement>

## Non-Goals

- <non-goal>
- <non-goal>

## Engineering Guardrails

- Use existing project conventions.
- Prefer minimal dependencies.
- Keep changes small and reviewable.
- Preserve existing behavior unless explicitly changing it.
- Do not silence errors with broad catches or TODO-only fixes.
- Do not fake verification.

## Verification

Run or describe:

```powershell
<commands>
```

## Output Required

Report:

- files changed
- what changed
- verification result
- remaining risks
- recommended next step
```

### 9.3 Review / Tighten / Regression Prompt

```md
# Review, Tighten, and Regression Prompt

Review the previous implementation against the prompt pack.

Check:

- requirement coverage
- file scope violations
- obvious regressions
- accessibility/readability
- performance risks
- unnecessary dependencies
- dead code or fake wiring
- tests/build/lint status

Make only targeted fixes. Do not redesign the feature.

Output:

- issues found
- fixes made
- verification run
- remaining manual QA
```

### 9.4 No-Code Audit Prompt

```md
# No-Code Audit Prompt

This is a no-code audit. Do not edit files.

Read the source materials and produce:

1. severity-ranked findings
2. affected files/modules
3. evidence
4. recommended fix strategy
5. implementation order
6. risks and unknowns

Use severity levels:

- P0: blocks core behavior or release
- P1: serious regression/risk
- P2: polish/quality issue
- P3: optional improvement

Do not propose a rewrite unless the current design makes targeted fixes impractical.
```

### 9.5 Verifier Prompt

```md
# Verifier Prompt

Verify the current work without assuming the previous agent was correct.

Check:

- acceptance criteria
- build/test commands
- manual QA checklist
- changed files
- non-goals
- regression risks

If verification cannot be run, state exactly why and provide the closest useful substitute.

Return:

- PASS / PARTIAL / FAIL
- evidence
- unresolved risks
- next concrete action
```

### 9.6 Continuation Prompt

```md
# Continuation Prompt

Continue from this pack and the current repo state.

First read:

- .thoughts
- docs/continuation-notes.md
- latest verification output

Do not repeat completed work unless verification shows it failed.
Focus on the next listed action.

Update `.thoughts` after the pass.
```

---

## 10. README Requirements

Every pack README should answer:

- What is this pack for?
- Which agent/model should use it?
- What should be read first?
- What order should prompts be run in?
- What files may be edited?
- What is explicitly out of scope?
- How should the work be verified?
- What should happen if blocked?

Suggested README skeleton:

```md
# <Pack Name>

Version: vX.Y.Z
Date: YYYY-MM-DD
Recommended agent: ChatGPT 5.5 / Codex / Trae / Claude

## Purpose

## Prompt Order

1. `prompts/00-engage.md`
2. `prompts/01-main-implementation.md`
3. `prompts/02-review-tighten-regression.md`
4. `prompts/90-human-qa.md`

## Source of Truth

## Allowed Scope

## Non-Goals

## Verification

## Expected Output

## Continuation Notes
```

---

## 11. Docs to Include

### `docs/brief.md`

Use for human-readable intent.

Include:

- outcome
- user-visible behavior
- technical constraints
- success criteria

### `docs/file-scope.md`

Use for repo safety.

Include:

- allowed files
- likely files
- forbidden files
- new file rules
- deletion rules

### `docs/implementation-checklist.md`

Use for agent execution.

Use checkboxes. Keep them concrete.

### `docs/qa-acceptance.md`

Use for verification.

Include:

- automated commands
- manual QA
- visual QA if needed
- performance checks if needed
- accessibility checks if UI

### `docs/risk-register.md`

Use for anything likely to go sideways.

Include:

```md
| Risk | Impact | Mitigation | Owner |
|---|---:|---|---|
```

---

## 12. Prompt Pack Quality Bar

A good prompt pack is:

- ordered
- scoped
- testable
- specific about source-of-truth files
- explicit about non-goals
- honest about unknowns
- portable across chats
- useful even if the next model has no prior conversation context

A bad prompt pack:

- says “make it better”
- hides critical constraints in prose soup
- has no file scope
- has no verification
- asks for build + audit + redesign + deploy in one prompt
- includes stale context without saying what is stale
- tells the agent to “be creative” where correctness matters
- forgets human QA for visual/audio/game/UI work

---

## 13. Handling Screenshots, Assets, and Tars

When screenshots are part of the source of truth:

- store them in `references/`
- describe them in `docs/visual-spec.md`
- include visible layout, typography, controls, states, and exclusions
- do not assume the image alone is enough

When a TAR/ZIP is provided:

- inspect the file list
- identify source-of-truth docs first
- extract relevant prompts/specs/matrices
- produce a pack that references the extracted structure
- avoid blindly copying duplicate or stale docs

For visual UI packs, include:

```txt
docs/visual-spec.md
docs/interaction-model.md
docs/accessibility-notes.md
docs/qa-acceptance.md
references/<image>.png
```

---

## 14. Model / Agent Guidance

### ChatGPT 5.5

Best for:

- reasoning-heavy planning
- pack creation
- architecture decisions
- synthesis across messy notes
- verifier/reviewer passes

Prompt style:

- provide context and constraints
- ask for structured output
- request assumptions and risks
- use follow-up prompts for refinement

### Codex

Best for:

- repo edits
- tests
- targeted implementation
- code verification

Prompt style:

- file scope matters
- include exact commands
- require changed-file summary
- require tests/build result

### Trae

Best for:

- interactive repo work
- multi-file implementation
- quick iteration in an existing codebase

Prompt style:

- keep prompts compact
- include exact target paths
- say “do not scaffold” when working inside an existing repo
- include allowed/non-goal file scope

### Claude / Claude Code

Best for:

- careful review
- refactoring plans
- codebase understanding
- explanation and critique

Prompt style:

- strong boundaries
- ask for severity-ranked findings
- ask for minimal changes unless rewrite is approved

---

## 15. Verification Defaults

For coding packs, include commands in the project’s native tooling order.

Default preference:

```powershell
bun install
bun run check
bun run test
bun run build
```

If the project uses npm/pnpm/yarn/Gradle/etc., use the project’s actual scripts instead.

For Windows-first apply scripts, prefer PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File ".\scripts\apply-pack.ps1"
```

For Android/Gradle packs, avoid overloading the machine by default. Prefer sane worker counts over “use everything and pray.”

---

## 16. Security and Safety Rules

Never include secrets in prompt packs.

Redact:

- API keys
- tokens
- connection strings
- private certs
- passwords
- billing identifiers when not needed
- customer/private personal data

For risky operations, require approval:

- delete data
- overwrite production files
- deploy
- transfer ownership
- modify billing
- change DNS
- run destructive migrations
- disable auth/security checks

---

## 17. Packaging Rules

When producing a downloadable pack:

- generate a versioned folder
- include README and `.thoughts`
- include prompt order
- include verification instructions
- include continuation notes
- compress as `.tar.gz` unless user asks otherwise
- provide the download link at the end

For single-file skills:

- create a versioned Markdown file
- include YAML frontmatter
- include usage instructions
- tell user where to place it

Example final response:

```md
Done — I made the universal prompt-pack skill.

Use it as:

`/.ai/skills/universal-prompt-pack-builder/SKILL.md`

Download: <link>
```

Do not paste the whole file in chat unless the user asks.

---

## 18. Pack Creation Process

When asked to create a prompt pack:

1. Identify task class.
2. Identify target agent/model.
3. Extract source of truth.
4. Separate goals from non-goals.
5. Define file scope.
6. Define verification.
7. Decide pack size.
8. Write ordered prompts.
9. Write README.
10. Write `.thoughts`.
11. Add docs/checklists/references.
12. Package and link.

If context is incomplete but not blocking, make practical assumptions and write them into the pack.

If context is blocking, ask only the minimum question needed.

---

## 19. Output Contract for This Skill

When using this skill, produce one of these:

### A. Single-file skill

```txt
<skill-name>-SKILL-vX.Y.Z.md
```

### B. Markdown prompt pack

```txt
<prompt-pack-name>-vX.Y.Z.md
```

### C. TAR.GZ prompt pack

```txt
<prompt-pack-name>-vX.Y.Z.tar.gz
```

### D. Repo-ready folder structure

```txt
.ai/skills/<skill-name>/SKILL.md
prompts/
docs/
.thoughts
```

Always include a concise summary and a download link.

---

## 20. Final Checklist

Before delivering a pack, confirm:

- [ ] It has a clear goal.
- [ ] It has prompt order.
- [ ] It has allowed scope.
- [ ] It has non-goals.
- [ ] It has verification.
- [ ] It has continuation notes.
- [ ] It has `.thoughts` if substantial.
- [ ] It avoids secrets.
- [ ] It avoids fake certainty.
- [ ] It tells the next agent what to do if blocked.
- [ ] It is downloadable if the user asked for a file.

---

## 21. Universal One-Paste Prompt

Use this when the user wants a fast prompt-pack generation request for ChatGPT 5.5:

```md
You are ChatGPT 5.5. Create a practical prompt pack for the task below.

Build the pack as if another AI agent will use it without access to this conversation.

Include:

- README.md
- .thoughts
- prompts/00-engage.md
- prompts/01-main.md
- prompts/02-review-tighten-regression.md
- prompts/90-human-qa.md
- docs/brief.md
- docs/file-scope.md
- docs/implementation-checklist.md
- docs/qa-acceptance.md
- docs/risk-register.md

Rules:

- Use SemVer.
- Keep prompts ordered and scoped.
- Separate goals from non-goals.
- Include exact file paths when known.
- Do not invent repo details.
- Mark assumptions clearly.
- Include verification commands.
- Include manual QA where automation is not enough.
- Do not include secrets.
- Do not ask follow-up questions unless a missing detail blocks the pack.

Task:

<PASTE TASK HERE>

Known constraints:

<PASTE CONSTRAINTS HERE>

Source of truth:

<PASTE FILES / SCREENSHOTS / TAR CONTENTS / NOTES HERE>

Target agent:

<ChatGPT 5.5 | Trae | Codex | Claude | mixed>

Delivery format:

<Markdown | TAR.GZ | ZIP | folder tree>
```

---

## 22. Default Tone

Be practical, direct, and specific. A good prompt pack should feel like a competent tech lead wrote it after cleaning up the whiteboard, not like a motivational poster learned YAML.
