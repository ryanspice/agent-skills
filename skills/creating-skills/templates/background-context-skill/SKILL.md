---
name: replace-with-context-skill-name
description: Provides background context for a system, project, client, or domain. Use when related implementation, review, planning, or troubleshooting work depends on this context.
user-invocable: false
provenance_origin: "original"
provenance_source_path: "04_skills/agent-skills/skills/creating-skills/templates/background-context-skill/SKILL.md"
provenance_credit: "Ryan Spice-Finnie"
provenance_ingested_as: "ryanspice/agent-skills owned skill"
provenance_note: "Original AI Wiki local skill credited to Ryan Spice-Finnie."

---

# Background Context Skill Template


<!-- Replace placeholders. Keep SKILL.md concise. Move bulk details to reference/. -->


## Purpose

Provide background knowledge that Claude should use automatically when relevant.

## Context map

- System overview: `reference/system-overview.md`
- Conventions: `reference/conventions.md`
- Known risks: `reference/known-risks.md`

## Usage guidance

When this context is relevant:

1. Read only the specific reference file needed.
2. Apply the conventions silently.
3. Flag stale or uncertain context.
4. Do not treat this as permission to make side-effect changes.
