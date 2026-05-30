---
name: vibe-guard
description: Runs a three-pass pre-commit/pre-push audit for AI-assisted code: production resilience, security, and comprehension debt. Use when reviewing uncommitted changes, before commits/pushes, after AI coding sessions, or when the user asks for a vibe guard, quick safety pass, or full repo audit.
version: 0.1.0-aiwiki.1
status: candidate
type: universal-agent-skill
risk: medium
platforms: [windows, ai-wiki, mcp, claude-code, codex, trae, hermes, chatgpt]
tags: [code-review, ai-generated-code, safety, pre-push, audit]
source_name: Vibe Guard Skills
source_slug: codecoincognition-vibe-guard-skills
source_url: https://github.com/codecoincognition/vibe-guard-skills
source_path: skills/vibe-guard.md
adapted: true
review_only: true
provenance_origin: "modified"
provenance_source_path: "04_skills/generated/vibe-guard-pack-aiwiki-adapted/vibe-guard/SKILL.md"
provenance_note: "AI Wiki adaptation of the external vibe-guard skill pack."
provenance_upstream: "codecoincognition/vibe-guard-skills https://github.com/codecoincognition/vibe-guard-skills"

---
# Vibe Guard

## Purpose

Run a merged safety review before code leaves the machine. This is the orchestrator skill: it coordinates `vibe-check`, `vibe-secure`, and `vibe-explain` into one prioritized report.

This is adapted from the Claude Code `vibe-guard-skills` repo for Ryan's AI Wiki/MCP workflow. Treat the upstream slash-command wording as source material; the AI Wiki version should work across Claude Code, Codex, Trae, Hermes, ChatGPT, and repo handoff prompts.

## Trigger phrases

Use this skill when the user says or implies:

- `vibe guard`
- `run vibe guard`
- `pre-push audit`
- `before I commit` / `before I push`
- `audit my diff`
- `safety check this AI-generated code`
- `quick critical-only check`
- `full repo audit`

## Scope modes

| Mode | Scope | Passes | Use when |
|---|---|---|---|
| `default` | `git diff HEAD` / changed files | production + security + comprehension | before commit/push |
| `quick` | `git diff HEAD` / changed files | production + security only; critical findings only | mid-edit sanity pass |
| `full` | tracked source files | all three passes | repo hardening pass |

If the working tree is clean and the user asked for a default diff audit, say that no uncommitted changes were found and recommend a full scan only if useful.

## Workflow

1. Establish scope from the user's request and available repo context.
2. Run the production resilience lens from `vibe-check`.
3. Run the security lens from `vibe-secure`.
4. Unless quick mode, run the comprehension/cognitive-debt lens from `vibe-explain`.
5. Deduplicate overlapping findings.
6. Sort by severity: critical first, warnings second, cognitive debt last.
7. Give concrete fixes, but do not apply edits unless the user explicitly asks.

## Severity model

- **Critical:** directly exploitable, likely production breakage, high blast radius, secret exposure, data loss, or auth/payment/client-data risk.
- **Warning:** conditional failure, scaling risk, maintainability risk, or missing guard that will matter as usage grows.
- **Cognitive debt:** code the user/team does not yet properly own: hidden assumptions, opaque logic, magic constants, fragile coupling, or undocumented business rules.

When evidence is incomplete, mark the finding as `Needs verification` instead of pretending certainty. Obvious, but apparently necessary. 🧯

## Output shape

```txt
VIBE GUARD REPORT
Scope: <git diff HEAD | full repo | selected files>
Detected stack: <when known>

CRITICAL — Fix before pushing
- [vibe-secure] path/file.ts:42 — Finding
  Risk: ...
  Fix: ...

WARNINGS — Fix soon
- [vibe-check] path/file.ts:103 — Finding
  Fix: ...

COGNITIVE DEBT — Understand before moving on
- [vibe-explain] path/file.ts:55-89 functionName()
  What it does: ...
  Assumes: ...
  Careful: ...
  Own it: ...

SUMMARY: 0 critical · 0 warnings · 0 debt items
```

Quick mode output should be short and critical-only.

## Guardrails

- Do not mutate files during the audit.
- Do not expose secrets in reports; redact values.
- Do not claim tests are missing unless test files were in scope or repo evidence proves it.
- Prefer copy-paste PowerShell or repo-native commands only after the report.
- For Ryan's repos, respect project `.thoughts`, existing `AGENTS.md`, repo-local `.ai/skills`, and AI Wiki canonical roots.

## References

- Upstream README: `https://github.com/codecoincognition/vibe-guard-skills`
- Upstream source path: `skills/vibe-guard.md`
- Local original snapshot, when installed: `04_skills/candidates/codecoincognition-vibe-guard-skills-original/vibe-guard/SKILL.md`
