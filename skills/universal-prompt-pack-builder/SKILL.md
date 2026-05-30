---
name: universal-prompt-pack-builder
version: 0.2.0
type: universal-agent-skill
status: active
risk: medium
description: Creates, audits, packages, and improves reusable prompt packs, agent handoffs, downloadable project packs, asset packs, .thoughts state files, and verification checklists. Use when the user asks for a prompt pack, handoff pack, agent prompt sequence, visual asset prompt pack, or reusable AI workflow pack.
tags: ["prompt-pack", "handoff", "agent-workflow", "tar-gz", "asset-pack", "thoughts"]
provenance_origin: "modified"
provenance_source_path: "04_skills/generated/universal-prompt-pack-builder/SKILL.md"
provenance_credit: "Ryan Spice-Finnie"
provenance_ingested_as: "ryanspice/agent-skills owned skill"
provenance_note: "Generated skill revised by Ryan Spice-Finnie from a local source reference preserved in the skill reference folder."
provenance_upstream: "04_skills/generated/universal-prompt-pack-builder/reference/source-universal-prompt-pack-builder-v0.1.0.md"

---

# Universal Prompt Pack Builder Skill

## 1. Purpose

Use this skill when the user wants a **prompt pack**, **agent handoff**, **downloadable project pack**, **implementation prompt sequence**, **audit prompt sequence**, **reusable skill**, **asset pack**, or **visual production pack**.

A prompt pack is not just a big prompt. It is a compact operating manual for an AI agent:

- what to read
- what to change
- what not to touch
- what order to work in
- how to verify
- how to report uncertainty
- how to continue in the next chat
- how to handle source images, assets, crops, previews, and extraction rules when visual deliverables are involved

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
7. asset/design manifests when visuals are part of the deliverable

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
- asset pack cleanup / extraction / refinement
- sprite sheet, icon, texture, or UI asset production guidance
- design description and bounding-box-driven visual extraction workflows

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

## 5. Visual / Asset Pack Extension

When the task includes screenshots, concept art, UI designs, asset packs, sprite sheets, textures, or extracted visual pieces, extend the pack like this:

```txt
<project-or-task-slug>-asset-pack-vX.Y.Z/
  README.md
  .thoughts

  prompts/
    00-engage.md
    01-design-analysis.md
    02-asset-extraction-and-cleanup.md
    03-ui-asset-generation.md
    04-preview-and-manifest-pass.md
    90-human-qa.md

  docs/
    brief.md
    visual-spec.md
    cropping-spec.md
    extraction-rules.md
    qa-acceptance.md
    style-guide.md
    ui-asset-inventory.md

  references/
    source-designs/
    source-screenshots/
    moodboard/

  manifests/
    design-descriptions.md
    asset-manifest.md
    asset-manifest.csv
    bounding-boxes.json

  previews/
    contact-sheet.png
    ui-assets-preview.png
    sprite-sheet-preview.png

  assets/
    raw/
    extracted/
    cleaned/
    ui/
    sprites/
    textures/
    icons/
```

Use this extension whenever the pack needs to do more than “make some images.” It should document **what each source design contains**, **what should be cut from it**, **how the crop should be interpreted**, and **how the outputs should be previewed and verified**.

---

## 6. Naming and Versioning

Use Semantic Versioning.

- `v0.1.0` = first usable version
- PATCH = small fix, wording correction, checklist tweak
- MINOR = new section, new workflow, new prompt type, broader capability
- MAJOR = incompatible structure or changed operating model

File naming examples:

```txt
pixelboats-sfx-manager-ui-prompt-pack-v0.2.0.tar.gz
canopy-seo-dashboard-prompt-pack-v0.1.0.tar.gz
universal-prompt-pack-builder-SKILL-v0.2.0.md
pixelboats-asset-pack-v0.4.39.tar.gz
```

Use lowercase slugs for packs. Keep project-specific names out of universal skills unless they are examples.

---

## 7. Required Inputs

Before building a pack, infer what you can from the conversation. Ask only when a missing detail is truly blocking.

Minimum input contract:

```yaml
project: ""
goal: ""
artifact_type: "implementation | audit | planning | UI mockup | research | skill | asset pack | mixed"
target_agent: "ChatGPT 5.5 | Trae | Codex | Claude | mixed"
source_of_truth:
  - repo path, uploaded tar, screenshot, spec, existing file, docs, chat notes
allowed_scope:
  - files/routes/modules/assets allowed to change
non_goals:
  - explicit exclusions
verification:
  - commands to run
  - manual QA checks
risk_tier: "low | medium | high"
delivery_format: "markdown | tar.gz | zip | folder"
```

Additional input contract for visual / asset tasks:

```yaml
visual_inputs:
  - source_design_images
  - prior asset pack
  - reference screenshots
asset_types:
  - sprites
  - icons
  - UI assets
  - textures
  - preview sheets
extraction_mode: "crop | regenerate from design | mixed"
background_rule: "transparent | solid mask color | preserve original"
bounding_box_requirement: true
preview_requirement: true
```

If the user does not specify an agent, default to **ChatGPT 5.5 for reasoning/planning** and include adaptation notes for Trae/Codex/Claude when relevant.

---

## 8. Agent Routing Block

Every substantial pack should include a route block near the top of `README.md` or `prompt-pack.md`.

```yaml
route:
  task_class: "implementation | audit | design | research | stabilization | packaging | asset extraction"
  artifact_class: "repo changes | no-code report | static UI | production patch | prompt pack | asset pack"
  target_surface: "specific route/module/file/app area"
  budget_profile: "small | medium | large"
  risk_tier: "low | medium | high"
  preferred_agent: "ChatGPT 5.5 | Codex | Trae | Claude"
  approval_gate: "none | before writes | before destructive ops | before deploy"
  fallback_route: "what to do if blocked"
```

This prevents the next agent from guessing the job class. Guessing is where the goblins live.

---

## 9. `.thoughts` Contract

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

## Assets Expected to Produce

## Next Chat Checkpoint
```

Rules:

- Keep it factual.
- Mark uncertainty explicitly.
- Do not bury secrets in it.
- Update it after implementation or review passes.
- Use it to stop future agents from repeating already-settled debates.

---

## 10. Prompt Types

### 10.1 Engage Prompt

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

Do not start coding or generating assets until you have identified:

- the target files
- the allowed scope
- non-goals
- verification commands
- known risks
- any asset extraction rules or bounding-box requirements

Then execute the main prompt. If the repo or source designs contradict this pack, trust the source-of-truth materials and report the mismatch.

Do not scaffold a new project unless the prompt explicitly says this is a scaffold task.
Do not add dependencies unless the pack explicitly allows them or they are strongly justified.
Do not touch secrets, credentials, billing, deployment, or destructive operations without explicit approval.
```

### 10.2 Main Implementation Prompt

```md
# Main Implementation Prompt

## Goal

<state the concrete outcome>

## Context

<brief context, current behavior, desired behavior>

## Source of Truth

Use these files/docs/screenshots/designs as source of truth:

- <file/doc/image>

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

### 10.3 Asset Extraction / Cleanup Prompt

Use this when the pack needs sprites, icons, textures, cropped UI pieces, or cleaned visual assets.

```md
# Asset Extraction and Cleanup Prompt

## Goal

Extract, regenerate, or clean the required assets from the provided source designs and create production-usable outputs.

## Source of Truth

Use:

- manifests/design-descriptions.md
- manifests/asset-manifest.md or .csv
- manifests/bounding-boxes.json
- docs/cropping-spec.md
- references/source-designs/*

## Required Behavior

- Follow the listed bounding boxes for each asset.
- If a simple crop would produce a broken or incomplete result, regenerate that asset cleanly based on the source design rather than shipping a bad crop.
- Preserve the design language, palette, and style of the source image.
- Remove backgrounds according to the background_rule.
- Keep assets centered and padded consistently.
- Preserve transparency cleanly with no checkerboard artifacts.
- For pixel art, preserve pixel integrity and avoid blur or anti-aliased mush.
- For UI assets, preserve sharp edges, spacing logic, and intended alignment.

## Output Required

Produce:

- cleaned asset files
- updated preview sheets
- updated manifest entries
- notes for any assets that required regeneration instead of direct crop
```

### 10.4 UI Asset Generation Prompt

Use this for buttons, panels, tabs, frames, meters, icons, HUD pieces, separators, cards, overlays, pivots, and other reusable interface pieces.

```md
# UI Asset Generation Prompt

Create reusable UI assets that match the source designs and project style.

Include, when relevant:

- panels / cards
- buttons / tabs / toggles
- sliders / meters / knobs
- separators / dividers / borders
- icon buttons / state icons
- HUD frames / command bars / overlays
- modal backplates / tooltip shells
- list rows / table headers / inspector shells

Rules:

- Match the design language of the supplied mockups.
- Favor reuse and modularity.
- Preserve transparent backgrounds unless a mask color is required.
- Include preview placements showing how the UI assets fit together.
- Document intended use, padding, and likely slice/stretch behavior where relevant.
```

### 10.5 Review / Tighten / Regression Prompt

```md
# Review, Tighten, and Regression Prompt

Review the previous implementation or asset pass against the prompt pack.

Check:

- requirement coverage
- file scope violations
- obvious regressions
- accessibility/readability
- performance risks
- unnecessary dependencies
- dead code or fake wiring
- tests/build/lint status
- incorrect crops
- misaligned or uncentered assets
- missing transparency cleanup
- preview sheets that do not reflect the actual final assets

Make only targeted fixes. Do not redesign the feature unless the pack explicitly allows it.

Output:

- issues found
- fixes made
- verification run
- remaining manual QA
```

### 10.6 No-Code Audit Prompt

```md
# No-Code Audit Prompt

This is a no-code audit. Do not edit files.

Read the source materials and produce:

1. severity-ranked findings
2. affected files/modules/assets
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

### 10.7 Verifier Prompt

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
- preview correctness
- manifest accuracy
- bounding-box coverage if applicable

If verification cannot be run, state exactly why and provide the closest useful substitute.

Return:

- PASS / PARTIAL / FAIL
- evidence
- unresolved risks
- next concrete action
```

### 10.8 Continuation Prompt

```md
# Continuation Prompt

Continue from this pack and the current repo or asset-pack state.

First read:

- .thoughts
- docs/continuation-notes.md
- latest verification output
- manifests/design-descriptions.md
- manifests/asset-manifest.md

Do not repeat completed work unless verification shows it failed.
Focus on the next listed action.

Update `.thoughts` after the pass.
```

---

## 11. README Requirements

Every pack README should answer:

- What is this pack for?
- Which agent/model should use it?
- What should be read first?
- What order should prompts be run in?
- What files/assets may be edited?
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

## 12. Docs to Include

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
- asset QA if visuals are included

### `docs/risk-register.md`

Use for anything likely to go sideways.

Include:

```md
| Risk | Impact | Mitigation | Owner |
|---|---:|---|---|
```

### `docs/visual-spec.md`

Use when images or UI matter.

Include:

- high-level design summary
- art direction
- palette/material cues
- layout observations
- reusable visual motifs
- exclusions and things not to invent

### `docs/cropping-spec.md`

Use when assets are being extracted or rebuilt.

Include:

- coordinate system definition
- bbox format
- padding rules
- transparency rules
- regeneration rules when crop quality fails
- output naming rules
- preview sheet rules

---

## 13. Design Description Contract

When a pack includes source designs, create `manifests/design-descriptions.md` and describe each design in a structured way. This is not fluff. It is the translation layer between “nice image” and “usable asset workflow.”

Recommended per-design template:

```md
## Design: <design_id>

- File: `<filename>`
- Role: `main mockup | source concept | UI board | sprite reference | texture source`
- Canvas size: `<width>x<height>`
- Style summary: `<1-3 paragraphs or bullets>`
- Visual themes: `<naval / sci-fi / pixel / glass / tactical / etc>`
- Dominant palette: `<hexes or color words>`
- Lighting/material notes: `<metal / glow / paper / soft shadow / etc>`
- Layout summary: `<major regions, left-to-right or top-to-bottom>`
- Notable objects/components:
  - `<component>`
  - `<component>`
- Reusable assets likely extractable:
  - `<asset idea>`
  - `<asset idea>`
- Exclusions / do not infer:
  - `<warning>`
```

If the pack involves multiple designs, describe all of them. These descriptions help future agents understand what should be extracted, regenerated, or ignored.

---

## 14. Bounding Box Contract

When crops matter, include a machine-usable bounding-box manifest. Use `manifests/bounding-boxes.json` and mirror a readable summary in `asset-manifest.md`.

Recommended schema:

```json
[
  {
    "asset_id": "ui-button-primary-01",
    "source_design_id": "sfxmgr-main-screen",
    "source_file": "sfxmgr-main-screen.png",
    "label": "Primary rectangular action button",
    "category": "ui/button",
    "bbox_px": { "x": 120, "y": 840, "w": 220, "h": 64 },
    "padding_px": { "top": 8, "right": 8, "bottom": 8, "left": 8 },
    "background_rule": "transparent",
    "cleanup_rule": "remove surrounding mockup background; preserve internal glow",
    "regenerate_if": [
      "crop cuts off shadow or border",
      "source area is occluded",
      "result is not reusable as a standalone asset"
    ],
    "anchor": "center",
    "expected_output": {
      "format": "png",
      "target_size_hint": "2x source or preserve native",
      "transparent": true
    },
    "notes": "Keep bevel and metallic lip. No checker artifacts."
  }
]
```

Rules:

- Use absolute pixel coordinates from the source image.
- Optionally include normalized coordinates, but pixel coordinates are the primary contract.
- Include padding so the crop is not too tight.
- Include cleanup and regeneration notes.
- If the original design only partially shows an asset, the crop should be treated as a reference, not a forced bad extraction.
- Include anchor notes when the asset will be aligned or placed by another system.

Yes: putting the bbox and extraction notes into the description/manifests makes the later AI pass more reliable. That is the point.

---

## 15. Asset Manifest Contract

Create `manifests/asset-manifest.md` or `.csv` with one row per asset.

Recommended fields:

```md
| asset_id | label | category | source_design_id | bbox | output_path | background | extraction_mode | status | notes |
|---|---|---|---|---|---|---|---|---|---|
```

Useful values:

- `category`: `sprite`, `icon`, `ui/panel`, `ui/button`, `ui/tab`, `ui/frame`, `texture`, `preview`, `sheet`
- `background`: `transparent`, `mask-pink`, `preserve`
- `extraction_mode`: `direct-crop`, `crop+cleanup`, `regenerate-from-design`, `new-companion-asset`
- `status`: `pending`, `extracted`, `cleaned`, `regenerated`, `verified`

This manifest makes it obvious what exists, what still needs work, and which assets are cuts versus rebuilt pieces.

---

## 16. Preview and Presentation Rules

A good asset pack should not just dump files into a folder and run away.

Include preview artifacts such as:

- `previews/contact-sheet.png` for all extracted assets
- `previews/ui-assets-preview.png` for panels/buttons/tabs/icons in context
- `previews/sprite-sheet-preview.png` for sprite groups and spacing
- `previews/textures-preview.png` if texture assets are included

Preview rules:

- Previews must reflect the **final** cleaned/regenerated outputs, not stale source crops.
- Group related assets together.
- Show scale and spacing clearly.
- If there are UI assets, show at least one composition example so humans can tell what the pieces are for.
- If there are sprite assets, show them on neutral and contrasting backgrounds to reveal transparency errors.

---

## 17. Prompt Pack Quality Bar

A good prompt pack is:

- ordered
- scoped
- testable
- specific about source-of-truth files
- explicit about non-goals
- honest about unknowns
- portable across chats
- useful even if the next model has no prior conversation context
- structured enough that visual extraction and cleanup are reproducible

A bad prompt pack:

- says “make it better”
- hides critical constraints in prose soup
- has no file scope
- has no verification
- asks for build + audit + redesign + deploy in one prompt
- includes stale context without saying what is stale
- tells the agent to “be creative” where correctness matters
- forgets human QA for visual/audio/game/UI work
- treats bad crops as acceptable final assets

---

## 18. Handling Screenshots, Assets, and Tars

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
- if it is an asset pack, audit whether previews, crops, manifests, and output folders actually match the design sources

For visual UI packs, include:

```txt
docs/visual-spec.md
docs/interaction-model.md
docs/accessibility-notes.md
docs/qa-acceptance.md
manifests/design-descriptions.md
manifests/asset-manifest.md
manifests/bounding-boxes.json
references/<image>.png
```

---

## 19. Model / Agent Guidance

### ChatGPT 5.5

Best for:

- reasoning-heavy planning
- pack creation
- architecture decisions
- synthesis across messy notes
- verifier/reviewer passes
- design description and extraction planning

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
- generating helper manifests/scripts

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
- audit-style visual review

Prompt style:

- strong boundaries
- ask for severity-ranked findings
- ask for minimal changes unless rewrite is approved

---

## 20. Verification Defaults

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

For asset packs, verify:

- manifests exist and match files
- expected asset count matches delivered count
- preview sheets show final assets
- transparency is clean
- crops are not clipped or misaligned
- pixel-art assets preserve source pixel quality
- UI assets are centered and reusable

---

## 21. Security and Safety Rules

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

## 22. Packaging Rules

When producing a downloadable pack:

- generate a versioned folder
- include README and `.thoughts`
- include prompt order
- include verification instructions
- include continuation notes
- include manifests when visuals are involved
- include previews when assets are involved
- compress as `.tar.gz` unless user asks otherwise
- provide the download link at the end

For single-file skills:

- create a versioned Markdown file
- include YAML frontmatter
- include usage instructions
- tell user where to place it

Example final response:

```md
Done — I made the updated universal prompt-pack skill.

Use it as:

`/.ai/skills/universal-prompt-pack-builder/SKILL.md`

Download: <link>
```

Do not paste the whole file in chat unless the user asks.

---

## 23. Pack Creation Process

When asked to create a prompt pack:

1. Identify task class.
2. Identify target agent/model.
3. Extract source of truth.
4. Separate goals from non-goals.
5. Define file scope.
6. Define verification.
7. Decide pack size.
8. If visuals are involved, write design descriptions.
9. If assets are involved, define asset manifest and bounding boxes.
10. Write ordered prompts.
11. Write README.
12. Write `.thoughts`.
13. Add docs/checklists/references.
14. Add previews/manifests if needed.
15. Package and link.

If context is incomplete but not blocking, make practical assumptions and write them into the pack.

If context is blocking, ask only the minimum question needed.

---

## 24. Output Contract for This Skill

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

### E. Asset-pack-ready folder structure

```txt
assets/
previews/
manifests/
docs/
prompts/
.thoughts
```

Always include a concise summary and a download link.

---

## 25. Final Checklist

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
- [ ] If visual work is involved, it has design descriptions.
- [ ] If extraction is involved, it has bounding boxes or an equivalent crop contract.
- [ ] If assets are involved, it has previews and a manifest.
- [ ] It is downloadable if the user asked for a file.

---

## 26. Universal One-Paste Prompt

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

If visuals or assets are involved, also include:

- docs/visual-spec.md
- docs/cropping-spec.md
- manifests/design-descriptions.md
- manifests/asset-manifest.md
- manifests/bounding-boxes.json
- previews/contact-sheet.png

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
- If visual extraction is needed, document the source designs and add bounding boxes for intended crops.
- If a crop would be bad, specify regeneration from design rather than shipping a broken asset.

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

## 27. Default Tone

Be practical, direct, and specific. A good prompt pack should feel like a competent tech lead cleaned up the whiteboard, audited the folder, and left the next agent instructions that are actually usable.
