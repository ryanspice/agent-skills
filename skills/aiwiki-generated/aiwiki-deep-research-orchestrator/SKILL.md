---
name: aiwiki-deep-research-orchestrator
version: 0.1.0
status: generated
skill_type: orchestration
tags:
  - ai-wiki
  - deep-research
  - research-broker
  - skill-composition
  - evidence
  - source-weighting
provenance_origin: "original"
provenance_source_path: "04_skills/generated/aiwiki-deep-research-orchestrator/SKILL.md"
provenance_credit: "Ryan Spice-Finnie"
provenance_note: "Original AI Wiki generated skill credited to Ryan Spice-Finnie."

---

# AI Wiki Deep Research Orchestrator

## Purpose

Use this skill when a research task should combine multiple AI Wiki skills, candidate skills, local search lanes, web/current sources, and evidence ledgers.

This is not a replacement for the lighter deep-research workflow or the enterprise workflow. It is an orchestrator that chooses which skills and rigor level to apply.

## Core doctrine

Build the evidence spine before building the research cathedral.

The orchestrator should:

1. decide whether the task needs research at all;
2. search/select relevant skills;
3. choose quick / standard / deep / enterprise mode;
4. label source lanes;
5. write or update evidence artifacts only when they change the decision;
6. avoid using search hit count as consensus;
7. keep the final output Markdown-first and AI Wiki-linkable.

## Skill composition order

Use this order:

```txt
1. aiwiki-skill-copy-workflow        # find/copy relevant skills first
2. local-first-storage-architecture  # when storage/index/canonicality matters
3. deep-research-workflow-candidate  # default research structure
4. enterprise-deep-research-workflow # decision-grade rigor only
5. windows-tar-package-installer-workflow # packaging/install/run workflow
```

If the skill-copy workflow does not exist yet, the orchestrator should say that this is the missing P0 tool and proceed manually.

## Mode selection

| Mode | Use | Required artifacts |
|---|---|---|
| Quick | map / sanity check | brief + sources |
| Standard | normal decision support | report + sources + evidence matrix |
| Deep | high-cost technical/business decision | + claims ledger + limitations |
| Enterprise | client/board/high-stakes package | + validation gates + state + optional HTML/PDF |

Do not run enterprise mode for simple lookups, tiny code fixes, or basic brainstorming.

## Required lanes

For AI Wiki/local work, search lanes should be labelled:

```txt
local.skills-universal
local.skills-project
local.skills-generated
local.skills-candidates
local.project-notes
local.project-state
repo.code
web.primary
web.current
web.community
runtime.index-cache
```

Runtime/index/cache/download hits can help find paths. They do not prove preference or truth.

## Evidence rule

Search finds candidates.
Source weighting creates evidence.
Curated files decide.

Major claims in serious research must appear in an evidence matrix or claims ledger, or be labelled as inference.

## Obsidian link rule

Add typed links when installing/promoting notes:

```md
## Related
- [[deep-research-workflow-candidate]]
- [[enterprise-deep-research-workflow-candidate]]
- [[aiwiki-skill-copy-workflow]]
- [[aiwiki-skill-create-workflow]]
- [[local-storage-rd-reference]]
```

Use meaningful hubs, not generic graph confetti.

## Next implementation priority

Do not build full `Search -Mode Research` first.

Build:

```txt
P0: Search -Skills -SelectMany -CopyFullContent
P1: Search -Mode Evidence -Emit evidence-matrix
P2: New-ResearchRun scaffold
P3: Search -Mode Research
P4: Enterprise validation/HTML/PDF profile
```
