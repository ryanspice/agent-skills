---
name: aiwiki-skill-registry-mcp-workflow
description: Use this skill to manage AI Wiki skill registry scans, candidate intake, MCP contracts, MCP server wrappers, and safe PixelBoats skill discovery without crawling the whole vault.
version: 0.1.0
status: active
type: generated-workflow-skill
risk: medium
tags: ["ai-wiki", "skills", "mcp", "registry", "pixelboats", "powershell", "python"]
created_at: 2026-05-20
provenance_origin: "original"
provenance_source_path: "04_skills/generated/aiwiki-skill-registry-mcp-workflow/SKILL.md"
provenance_credit: "Ryan Spice-Finnie"
provenance_ingested_as: "ryanspice/agent-skills owned skill"
provenance_note: "Original AI Wiki generated skill credited to Ryan Spice-Finnie."

---

# AI Wiki Skill Registry MCP Workflow

Use this skill when working on AI Wiki skill discovery, candidate intake, active skill registries, or MCP tooling.

## Current baseline

The AI Wiki has a filtered skill scan policy at:

```text
03_indexes/skills/skill-scan-policy.json
```

The active registry layer currently writes:

```text
03_indexes/skills/active-skills.json
03_indexes/skills/project-skills/pixelboats-active-skills.json
03_indexes/skills/skill-registry-validation-report.json
03_indexes/skills/mcp/aiwiki-skills-mcp-contract.v0.1.5.json
00_INBOX/proposed/aiwiki-skills-mcp-validation-review-v0.1.5.md
```

## Operating model

Do not crawl the whole vault by default.

Default active discovery reads:

```text
04_skills/generated
04_skills/universal
04_skills/projects
```

Candidate discovery is explicit and separate:

```text
04_skills/candidates
03_indexes/skills/external-sources/external-candidate-skills.json
```

## Exclusion policy

Always exclude:

```text
*.bak-*
archive/
deprecated/
candidate-import-snapshots/
generated-duplicates/
nested duplicate folders like <slug>/<slug>/SKILL.md
```

## Path output rules

For terminal, screenshot, video, and MCP-adjacent output:

- Hide personal/local path segments by default.
- Prefer labels like `...\Obsidan\AI-Wiki` and `...\Temp\some-preview-folder`.
- Store registry paths as relative paths.
- Do not rely on Ctrl-click terminal links.
- Print copy-paste PowerShell open commands when useful.
- Do not auto-open generated files unless an explicit `-Open` flag is passed.
- Use `-OpenWith` or `$env:AIWIKI_OUTPUT_OPEN_WITH` for the opener.

## MCP endpoint intent

Minimum tool set:

```text
aiwiki.skills.list
aiwiki.skills.search
aiwiki.skills.read
aiwiki.skills.projects.list
aiwiki.skills.projects.read
aiwiki.skills.candidates.search
aiwiki.skills.candidates.read
aiwiki.skills.validate
```

Guardrails:

- Resolve reads through indexes, not arbitrary absolute paths.
- Return relative paths by default.
- Candidate reads require explicit candidate tool usage.
- Candidate original snapshots require an explicit opt-in field.
- Keep default responses compact.

## PixelBoats itinerary

C is on the itinerary after MCP local server/wrapper validation.

PixelBoats follow-up should use these project skills first:

```text
pixelboats-game-dev-orchestrator
pixelboats-webgl2-water-shader-lab
pixelboats-map-minimap-fog-of-war
pixelboats-hud-ux-playtest
pixelboats-performance-budget-loop
```

Suggested PixelBoats run:

1. List active PixelBoats skills.
2. Read the five new project skills.
3. Search candidates for `shader water webgl mobile performance`.
4. Produce one focused prompt for the next PixelBoats pass.
5. Avoid promoting more candidates unless a gap is proven.

## Do not

- Do not promote all external candidates.
- Do not execute imported hooks.
- Do not expose raw filesystem traversal through MCP.
- Do not let candidate imports leak into active default skill listings.
- Do not turn PixelBoats into a fake studio bureaucracy.
