---
name: repo-skill-recommender
version: 0.1.0
type: universal-agent-skill
status: active
risk: medium
description: Inspects a repo and AI Wiki skills registry to recommend repo-level skill pointers, MCP roots, setup prompts, and agent handoff rules. Use when the user asks which skills belong in a repo, how to sync project skills, or how to set up repo-local AI agent context from the AI Wiki.
tags: ["repo", "skills", "mcp", "ai-wiki", "setup", "recommendation"]
provenance_origin: "modified"
provenance_source_path: "04_skills/generated/repo-skill-recommender - Copy/SKILL.md"
provenance_credit: "Ryan Spice-Finnie"
provenance_ingested_as: "ryanspice/agent-skills owned skill"
provenance_note: "Generated copy retained from the AI Wiki generated shelf and credited to Ryan Spice-Finnie as a local mutation of repo-skill-recommender."
provenance_upstream: "04_skills/generated/repo-skill-recommender/SKILL.md"

---

# Repo Skill Recommender

Use this skill when a repo needs a recommended list of AI Wiki skills, repo-local pointers, MCP roots, or setup prompts.

## Rules

1. Treat the AI Wiki as canonical.
2. Do not copy universal skills into a repo by default.
3. Prefer MCP roots that point at narrow AI Wiki folders:
   - `04_skills/universal`
   - `04_skills/projects/<project-slug>`
4. Repo-local `.ai/skills` files should usually be pointers, not duplicate canonical skills.
5. Generate a dry-run recommendation report before writing repo files.
6. For project repos, recommend project-specific canonical skills first, then universal skills as externally loaded context.
7. Treat `04_skills/candidates` as imported external source snapshots and review library, not as rejected skills.
8. Treat `04_skills/generated` as Ryan-directed generated/history/package source records.
9. Use provenance to distinguish already-promoted candidate-derived support skills from unpromoted candidates.
10. For client/production repos, check available tool/runtime compatibility before writing scripts or changing files.

## Repo inspection checklist

Inspect, if available:

- package manager files: `package.json`, `bun.lock`, `pnpm-lock.yaml`, `package-lock.json`
- framework config: `vite.config.*`, `svelte.config.*`, `next.config.*`, `tauri.conf.json`, Android/Gradle files
- agent files: `AGENTS.md`, `.ai/`, `.claude/`, `.cursor/`, `.github/copilot-instructions.md`
- docs/state: `README.md`, `.thoughts`, `docs/`, `CHANGELOG.md`
- source shape: `src/routes`, `src/lib`, `src-tauri`, `app`, `components`, `scripts`

## Output

Return:

```txt
Repo:
Detected stack:
Canonical AI Wiki skill roots:
Recommended project skills:
Recommended universal skills:
Repo-local pointer files to add:
Files not to touch:
Setup prompt:
Dry-run/apply commands:
Risks:
```

## Do not

- point agents at the whole AI Wiki vault
- install stale `.claude/skills` by default
- duplicate universal skill content into repos
- mutate repo files without explicit apply intent

<!-- AIWIKI_REPO_AUDIT_RECOMMENDER_V020_START -->
## Repo audit recommendation workflow

Use `scripts/run-repo-skill-recommendation.ps1` when setting up skills for a repo.

The script must produce a dry-run/report-only recommendation that audits the repo before recommending skills.

It should inspect:

- package manager and package scripts
- framework signals
- `src/routes` and `src/lib`
- `.ai`, `.thoughts`, and `AGENTS.md`
- WebGL/canvas evidence
- audio/SFX/music evidence
- image/UI/asset evidence
- PowerShell/package workflow evidence
- TODO/FIXME/regression evidence
- external candidate skill indexes
- skill provenance from `03_Indexes/skills/skill-provenance.json`

Recommendation rules:

1. Active canonical skills are the default working set.
2. Candidate skills are source snapshots until selected, adapted, and promoted.
3. Already-promoted candidate-derived skills should be reported as promoted support skills, not as review candidates.
4. Do not copy all candidates into the repo.
5. Generate repo-derived questions with defaults.
6. Prefer pointer mirrors to full repo-local skill copies.
7. Ask before writing repo files.
8. Use `powershell-script-authoring` for generated scripts.
9. Use `reference/repo-audit-question-model.md` for question-quality rules.
<!-- AIWIKI_REPO_AUDIT_RECOMMENDER_V020_END -->
<!-- AIWIKI_REPO_DERIVED_REPORT_MODE_START -->
## Repo-derived report mode

Default to report-only operation.

The recommender should audit the repo and write questions into a report instead of interrupting the shell with generic prompts.

Interactive questions may be added as an optional mode, but the default flow is:

1. Inspect repo files, package scripts, existing AI docs, workflows, and known project state.
2. Sample evidence with file paths.
3. Recommend a minimal active skill set.
4. Separate already-promoted candidate-derived support skills from unpromoted candidate snapshots.
5. Recommend selected future candidate reviews, not bulk promotion.
6. Ask repo-derived questions with defaults.
7. Propose pointer strategy and AGENTS/handoff strategy.
8. Do not edit repo files unless explicitly approved.

Questions should be caused by evidence. Avoid obvious generic prompts.
<!-- AIWIKI_REPO_DERIVED_REPORT_MODE_END -->
<!-- AIWIKI_CANDIDATE_PROVENANCE_RULE_START -->
## Candidate provenance rule

When recommending external candidates or promoted external-derived skills, include source provenance.

Use:

- candidate source slug
- upstream repository URL
- local candidate snapshot path
- whether the skill is already promoted, unpromoted, or deferred
- why it fits this repo evidence

Do not recommend copying all candidates into a repo. Do not register candidates as active skills unless explicitly promoted. Do not list already-promoted candidate-derived skills as if they still need promotion.
<!-- AIWIKI_CANDIDATE_PROVENANCE_RULE_END -->
