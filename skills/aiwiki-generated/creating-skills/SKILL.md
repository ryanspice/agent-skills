---
name: creating-skills
description: Creates, improves, audits, splits, validates, and packages portable agent skills for Ryan's AI Wiki/MCP-first workflow, repo .ai/skills overlays, and optional tool mirrors. Use when the user asks to make a skill, convert prompts/research/transcripts/screenshots into a skill, improve SKILL.md routing, build templates/scripts/references, rebuild a skill registry, or split a mega-skill into composable skills.
version: 0.1.3
platforms: [windows, ai-wiki, mcp, hermes, chatgpt, claude-code, codex, trae]
tags: [skills, ai-wiki, mcp, hermes, prompt-packs, validation, packaging]
provenance_origin: "original"
provenance_source_path: "04_skills/generated/creating-skills/SKILL.md"
provenance_credit: "Ryan Spice-Finnie"
provenance_note: "Original AI Wiki generated skill credited to Ryan Spice-Finnie."

---

# Creating Skills

## Purpose

Turn repeated workflows, prompts, transcripts, research, screenshots, repo notes, examples, and project conventions into durable portable agent skills.

For Ryan's workflow, the canonical install target is the AI Wiki skill shelf:

```txt
<AI_WIKI_ROOT>/04_skills/universal/<skill-name>/SKILL.md
```

Tool-specific copies, such as Claude Code, Codex, Trae, Hermes local folders, or repo `.ai/skills`, are mirrors or project overlays unless the user explicitly says otherwise.

## Core rule

Do not dump all source material into `SKILL.md`.

Create a concise live playbook. Move deep background into `reference/`, reusable structures into `templates/`, deterministic repeat work into `scripts/`, and examples/evals into `examples/`.

## When to use

Use this skill when the user asks to:

- make a skill
- create a skill from prompts, transcripts, screenshots, repo notes, or research
- improve or audit an existing `SKILL.md`
- split a mega-skill into composable skills
- generate skill templates, references, validators, or install scripts
- package a skill for AI Wiki, MCP, repo `.ai/skills`, Claude Code, claude.ai, Codex, Trae, or mixed-agent use
- rebuild or inspect the AI Wiki skills registry

Do not create a skill for a one-off answer unless the user is intentionally building a reusable workflow.

## Intake

Ask only blocking questions. Otherwise choose safe defaults and state assumptions.

Minimum useful inputs:

- repeated task/workflow
- target surface: AI Wiki/MCP, repo `.ai/skills`, Hermes, Claude Code, claude.ai, Codex, Trae, API, or mixed
- trigger phrases or expected slash/menu usage
- source material: notes, transcript, repo docs, screenshots, examples, specs
- whether the skill may cause side effects
- expected output shape
- available scripts/tools/APIs
- validation or eval criteria

Default assumptions for Ryan:

- canonical root: `<AI_WIKI_ROOT>`
- universal skills: `04_skills/universal`
- project skills: `04_skills/projects/<slug>/<skill-name>/SKILL.md` or project `.ai/skills` overlays when operating inside a repo
- staged proposed wiki edits: `00_INBOX/proposed`
- PowerShell 7 `pwsh` first; Windows PowerShell-compatible fallback where practical
- MCP should read narrow skill roots, not the whole vault

## Skill design workflow

### 1. Decide if this is a skill

Make a skill when the task is repeated, procedural, preference-heavy, domain-specific, or benefits from reference files/scripts.

Good candidates:

- recurring prompt-pack generation
- repo-specific release packaging
- repeated audit/checklist workflows
- document generation with known house style
- transform/extract/validate tasks
- project handoff workflows

Weak candidates:

- one-off summary
- generic advice
- broad "be better at everything" prompts
- workflows with no stable trigger or repeat value

### 2. Split for composability

Prefer focused skills that chain together over an omnibus skill.

Split when parts have different:

- triggers
- risk levels
- tool permissions
- target artifacts
- update cadence
- reusable value
- project scope

Example split:

```txt
creating-skills
prompt-pack-builder
ai-wiki-file-management
pixelboats-release-packaging
webgl2-mobile-performance-pass
```

### 3. Draft frontmatter first

Required:

```yaml
---
name: lowercase-hyphen-name
description: Does X. Use when Y, Z, or the user mentions A/B/C.
---
```

Recommended for AI Wiki/MCP skills:

```yaml
version: 0.1.0
platforms: [windows, ai-wiki, mcp]
tags: [domain, workflow, validation]
risk: low
```

Name rules:

- lowercase letters, numbers, hyphens only
- max 64 characters
- no XML tags
- no vendor/model words unless the skill is specifically a mirror/adaptor for that tool

Description rules:

- third person
- max 1024 characters
- describes what the skill does and when to use it
- includes practical trigger language
- avoids vague labels like `helper`, `tools`, `workflow`, or `assistant`

### 4. Choose the right freedom level

- High freedom: writing, review, strategy, research synthesis.
- Medium freedom: templates, examples, structured outputs, configurable steps.
- Low freedom: fragile operations, build/deploy, file conversion, validation, repeatable transforms.

Use scripts for low-freedom work when possible.

### 5. Use the default layout

```txt
skill-name/
  SKILL.md
  mcp-skill.json
  reference/
  templates/
  examples/
  scripts/
```

Keep `SKILL.md` focused on:

- purpose and trigger
- workflow
- decision points
- risk gates
- where to look for deeper reference
- expected outputs
- validation loop

### 6. Add reference files only when useful

Use `reference/` for:

- research notes
- transcript-derived patterns
- style guides
- API docs
- source summaries
- security/risk notes
- troubleshooting
- examples too large for `SKILL.md`

In `SKILL.md`, explicitly say when to read each reference file.

Useful references in this skill:

- `reference/skill-authoring-principles.md`
- `reference/transcript-patterns.md`
- `reference/anti-patterns.md`
- `reference/security-and-trust.md`
- `reference/evaluation-patterns.md`
- `reference/install-surfaces.md`
- `reference/skill-quality-rubric.md`
- `reference/ai-wiki-mcp-integration.md`

### 7. Add scripts for deterministic repetition

Use `scripts/` for:

- frontmatter validation
- file inventory
- registry rebuilding
- package assembly
- filename normalization
- transforms/extraction
- report generation

Scripts should:

- avoid network calls unless required
- fail loudly with useful messages
- use clear parameter names
- avoid secrets
- write outputs predictably
- support PowerShell 7 and Windows path realities
- have dry-run where side effects matter

Preferred validation commands:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File ./install.ps1
python ./scripts/validate_skill.py ./skill-name
python ./scripts/rebuild_skills_registry.py --ai-wiki-root "<AI_WIKI_ROOT>"
```

### 8. Handle AI Wiki/MCP risk

For AI Wiki/MCP workflows:

- Treat `<AI_WIKI_ROOT>` as canonical.
- Point MCP/Hermes at narrow skill roots such as `04_skills/universal` and project-specific skill roots.
- Do not scan the whole vault as a skill directory.
- Default MCP tools are read-oriented: `vault_search`, `vault_read`, `graph_neighbors`, `context_pack`.
- Use `stage_inbound_note` only when explicitly approved or as a proposed-edit staging tool.
- Stage proposed durable edits in `00_INBOX/proposed`.
- Do not mutate `02_wiki` directly during skill creation.

For side-effect skills:

- require explicit user intent before deploy/send/delete/publish/billing/credential work
- avoid broad pre-approved shell tools
- prefer dry-run, preview, backup, and verification steps

For Claude Code mirrors only:

```yaml
disable-model-invocation: true
```

Use for high-risk skills.

```yaml
user-invocable: false
```

Use for background context skills.

### 9. Build evals before bloat

Create at least three eval scenarios:

1. happy path
2. messy/ambiguous input
3. safety or edge case

For serious skills, add:

4. composability/splitting case
5. regression case from a previous failure

Each eval should include:

- query
- optional files
- expected behavior
- failure signs

### 10. Improve after real use

After each useful failure, ask:

> Is this a one-time correction, or should the skill know this forever?

If forever, update the smallest durable surface:

- `SKILL.md` for central workflow changes
- `reference/` for deeper context
- `templates/` for output structure
- `scripts/` for repeatable operations
- `examples/` for evals/regressions
- `mcp-skill.json` for routing/registry metadata

## Creating from transcripts, screenshots, or research

Extract:

- repeated steps
- trigger phrases
- decision rules
- examples
- reusable tools/scripts
- warnings and anti-patterns
- stable terminology
- evaluation scenarios
- install surfaces
- side-effect boundaries

Discard:

- filler
- anecdotes that do not change behavior
- marketing claims
- long quotes
- one-off facts that will go stale

## Required output when delivering a skill

```markdown
# Result

## Skill
- Name:
- Purpose:
- Target surface:
- Invocation:
- Risk level:

## Files
[tree]

## Key design choices
- ...

## Validation
- ...

## Install / use
- ...

## Suggested next iteration
- ...
```

If packaging, include:

- skill folder
- `mcp-skill.json` when AI Wiki/MCP is involved
- README
- CHANGELOG
- install/apply script
- validator or registry builder when structural correctness matters
- `.thoughts` for continuation state

## Red flags

Stop and tighten the design if the skill:

- has a vague description
- pastes research wholesale into `SKILL.md`
- tries to solve unrelated workflows
- has no evals
- adds broad tool permissions
- writes directly into durable wiki pages without staging or explicit installer intent
- has scripts with unclear parameters
- duplicates universal skill content into project overlays

<!-- AIWIKI_CREATING_SKILLS_POWERSHELL_RULE_START -->
## PowerShell generation rule

When creating, improving, or packaging a skill that includes PowerShell:

1. Apply the powershell-script-authoring conventions.
2. Include path/location preflight before critical actions.
3. Make script roots explicit; do not assume the shell is already in the correct folder.
4. Prefer dry-run/apply mode for broad changes.
5. Back up before overwrites/deletes.
6. Use pwsh -NoProfile -ExecutionPolicy Bypass for PowerShell 7+ workflows.
7. For client/prod/unknown environments, check compatibility if the tool/agent has access to inspect the environment.
8. For copy operations, copy directory contents intentionally; do not accidentally nest a source folder inside an existing destination folder.
9. If a generated script is large, provide it as a downloadable file/package instead of dumping excessive code into chat.
<!-- AIWIKI_CREATING_SKILLS_POWERSHELL_RULE_END -->

<!-- AIWIKI_CREATING_SKILLS_POWERSHELL_LESSONS_START -->
## PowerShell skill generation lessons

When creating or revising a skill that includes PowerShell scripts:

1. Apply the `powershell-script-authoring` rules.
2. Include parser-safety checks for `$Var:`, escaped quote strings, inline `if` values inside object literals, and validation command shape.
3. Prefer generated downloadable scripts for long automation instead of giant fragile chat blocks.
4. Use `pwsh -NoProfile -ExecutionPolicy Bypass`, not `powershell`.
5. Require dry-run/apply mode for repo, AI Wiki, package, archive, and cleanup scripts.
6. For AI Wiki validation, use `--scan --registry` when validating the vault root.
7. Rebuild candidate indexes from actual folders on disk, not from noisy import logs.
8. Keep candidate skills out of the active registry until explicitly promoted.
<!-- AIWIKI_CREATING_SKILLS_POWERSHELL_LESSONS_END -->
<!-- AIWIKI_LAYOUT_CHANGE_BUNDLE_RULE_START -->
## Layout change bundle rule

When changing AI Wiki skill layout, update all affected surfaces in the same pass:

1. canonical folder rules
2. registry rebuild scripts
3. validation commands
4. mirror and pointer policy
5. skill-mirrors.json
6. provenance indexes
7. README/index notes
8. installer/apply scripts

Do not migrate paths without updating rebuild and validation logic. That creates stale shelves and fake confidence.
<!-- AIWIKI_LAYOUT_CHANGE_BUNDLE_RULE_END -->

<!-- AIWIKI_CREATING_SKILLS_NUMBERED_LAYOUT_START -->
## Canonical vs. mirror roots

Use the numbered AI Wiki layout.

Canonical active registry roots:

```txt
04_skills/universal/<skill>/SKILL.md
04_skills/projects/<project-slug>/<skill>/SKILL.md
```

Project-local pointer mirrors:

```txt
07_Projects/<project-slug>/.ai/skills/<skill>/SKILL.md
```

Mirror files are provenance/discovery pointers only. They must carry:

```yaml
type: pointer
status: mirror
canonical_path: <full canonical path>
```

Do not duplicate the full canonical skill body into a project mirror.

Staging/inbox policy:

```txt
00_INBOX/proposed   # durable edits waiting for review
00_INBOX/generated  # raw generated/test/program outputs
00_INBOX/imports    # harvested/imported source material
```

Do not use `07_inbound`; it is deprecated in favor of the `00_INBOX` / `07_Projects` split.
<!-- AIWIKI_CREATING_SKILLS_NUMBERED_LAYOUT_END -->

<!-- AIWIKI_EXTERNAL_REPO_CANDIDATE_POLICY_START -->
## External repo candidate policy

External repo candidates under  4_skills/candidates/<source-slug> should be exact upstream git clones when possible.

Rules:

1. Keep the candidate clone updateable with git pull --ff-only.
2. Do not place AI Wiki adaptation notes, manifests, or generated files inside the clone.
3. Store source metadata in  3_indexes/skills/external-sources/<source-slug>.json.
4. Store pack metadata in  3_indexes/skills/packs/<pack-name>.json.
5. Store Ryan/AI adapted drafts in  4_skills/generated/<pack-or-skill>.
6. Promote reviewed active skills into  4_skills/universal or  4_skills/projects.
7. Do not index  4_skills/candidates or  4_skills/generated as active skill roots.

Original upstream is evidence. Generated/adapted is workspace. Universal/projects are active canon.
<!-- AIWIKI_EXTERNAL_REPO_CANDIDATE_POLICY_END -->
