---
name: replace-with-research-skill-name
description: Converts research, transcripts, source notes, or examples into a reusable workflow. Use when the user asks to make a skill from research material, pasted notes, uploaded transcripts, or prior prompt iterations.
provenance_origin: "original"
provenance_source_path: "04_skills/agent-skills/skills/creating-skills/templates/research-backed-skill/SKILL.md"
provenance_credit: "Ryan Spice-Finnie"
provenance_ingested_as: "ryanspice/agent-skills owned skill"
provenance_note: "Original AI Wiki local skill credited to Ryan Spice-Finnie."

---

# Research-Backed Skill Template


<!-- Replace placeholders. Keep SKILL.md concise. Move bulk details to reference/. -->


## Purpose

Turn dense source material into a concise reusable skill.

## Source handling

Extract durable operational patterns:

- trigger phrases
- repeated steps
- decision rules
- constraints
- examples
- errors to avoid
- validation scenarios
- scripts/tools worth saving

Do not paste raw research into `SKILL.md`. Store summaries in `reference/`.

## Workflow

1. Inventory the sources.
2. Separate stable rules from one-off context.
3. Draft concise frontmatter.
4. Create the main workflow.
5. Move long notes to `reference/source-summary.md`.
6. Add examples or templates only if they materially improve reuse.
7. Add evals.

## Additional resources

- For source summaries, read `reference/source-summary.md`.
- For examples, read `reference/examples.md`.
- For evals, read `reference/evals.md`.
