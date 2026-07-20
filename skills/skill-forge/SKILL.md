---
name: spiceflow-skill-forge
description: Derive, create, evaluate, stage, improve, and package reusable AI skills from repeated workflows, conversation history, repository evidence, scripts, templates, handoffs, and MCP capabilities. Use when Ryan wants a new skill, wants to extract a pattern from prior work, improve an existing skill, add AI Wiki-compatible metadata, or build reusable operating behavior for multiple harnesses.
---

# SpiceFlow Skill Forge

**Turn repeated successful work into a small, testable operating contract.**

## Trigger conditions

Create or revise a skill when at least one is true:

- the same workflow has been requested more than once;
- a repeated failure has a stable recovery method;
- a package, script, or handoff pattern should become reusable;
- a project needs explicit source authority, scope, or acceptance rules;
- multiple agents need the same operating contract;
- an MCP exposes durable capabilities worth standardizing;
- a skill already exists but has drifted, become vague, or lacks evaluations.

Do not create a skill for a one-off answer that is better kept as a note, template, command, or project task.

## Evidence sources

Rank sources in this order:

1. current repository instructions, tests, source, and architecture records;
2. current user instruction and explicit acceptance criteria;
3. successful scripts, packages, and handoffs;
4. repeated conversation patterns and corrections;
5. personal preferences that materially affect execution;
6. external examples and model memory.

Separate observed patterns from inferred preferences.

## Skill anatomy

A durable skill should include:

- frontmatter with a precise name and trigger-rich description;
- purpose and non-purpose;
- precedence and source authority;
- trigger conditions;
- bounded workflow;
- safety and stop conditions;
- output contract;
- evaluation prompts with pass criteria;
- `mcp-skill.json` when stored in the AI Wiki;
- project scope and mirrors when project-specific.

Avoid biographies, generic values, duplicated platform documentation, and enormous prompts that merely restate everything known about Ryan.

## Derivation workflow

1. Name the repeated problem, not the desired personality.
2. Collect three or more concrete examples when available.
3. Extract the invariant decisions, checks, and recovery behavior.
4. Identify what should remain a template, script, or MCP adapter instead of prose.
5. Write the smallest skill that changes behavior.
6. Create adversarial and ordinary evals.
7. Stage it as `proposed`.
8. Run it in at least two real tasks.
9. Revise from failures.
10. Promote only when the skill is stable and non-duplicative.

## AI Wiki placement

Canonical conventions:

```text
Universal:
<AI_WIKI_ROOT>\04_skills\universal\<skill>\SKILL.md

Project:
<AI_WIKI_ROOT>\skills\projects\<project-slug>\<skill>\SKILL.md

Candidate:
<AI_WIKI_ROOT>\04_skills\candidates\<source>\<skill>\SKILL.md

Generated:
<AI_WIKI_ROOT>\04_skills\generated\<skill>\SKILL.md

Inbound proposal staging:
<AI_WIKI_ROOT>\06_Inbound\proposed\...
```

Active registry and mirror conventions:

```text
03_indexes\skills\skills-registry.json
03_indexes\skills\skill-mirrors.json
projects\<project-slug>\.ai\skills\<skill>\SKILL.md
projects\<project-slug>\skills\<skill>\SKILL.md
```

Do not install into `.claude/skills` by default. Stage first. Promote only through an explicit reviewed operation.

## MCP metadata

Each durable canonical skill should have `mcp-skill.json` containing:

- identity and version;
- lifecycle status;
- scope and project slug;
- canonical path;
- entrypoint;
- tags and triggers;
- required capability aliases;
- mirrors;
- provenance;
- validation status.

Capability aliases must describe intent, such as `knowledge.search` or `project.test`, rather than hard-coding one server’s temporary tool name.

## Skill quality test

A good skill:

- changes the agent’s next action;
- is clear about when not to activate;
- points to scripts and templates instead of duplicating them;
- survives use by Claude, Codex, Hermes, Kun, or a future harness;
- can be verified by evals;
- leaves the user with more agency;
- does not leak personal context into unrelated tasks.

## Output

Return the proposed skill path, status, source evidence, generated files, evaluation result, and one promotion or revision action.


## Growth & Feedback (promotion contract, 2026-07-20)

This skill is **dynamic** — a generated v0.3.0 snapshot with one canonical growth loop, not a frozen copy. Do not hand-edit it in place.

- **Friction or gap noticed in use:** log it via the AI Wiki MCP `append_log` (lightweight, no review burden).
- **Concrete growth request:** stage a proposal via `stage_inbound_note` into `AI-Wiki/00_INBOX/proposed` naming this skill, the trigger, and the wanted change.
- **Repeated feedback** on the same theme triggers a **skill-forge derivation**: a versioned update candidate (semver bump, provenance hash chain back to the v0.3.0 archive) staged as an inbound proposal.
- **Promotion is owner-gated:** candidates land only through the pnpm-validated `agent-skills` workflow. Derived indexes may rebuild automatically after validation; canonical content never self-promotes.
- Every harness adapter (Claude, Codex, Hermes, Kun) points at this one loop — no per-harness forks of skill content. Provenance: `PROVENANCE.md`.
