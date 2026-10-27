---
title: Enterprise Deep Research Workflow Candidate
version: 0.1.0
status: candidate
source_family: deep-research / enterprise research automation
source_reviewed:
  - https://github.com/199-biotechnologies/claude-deep-research-skill
  - https://deepwiki.com/199-biotechnologies/claude-deep-research-skill
created: 2026-05-22
intended_location: 04_skills/agent-skills/skills/candidates/enterprise-deep-research-workflow-candidate-v0.1.0
promote_to: 04_skills/universal/deep-research/enterprise-deep-research-workflow
risk_tier: medium
provenance_origin: "modified"
provenance_source_path: "04_skills/agent-skills/skills/candidates/enterprise-deep-research-workflow-candidate-v0.1.0/SKILL.md"
provenance_credit: "Ryan Spice-Finnie"
provenance_ingested_as: "ryanspice/agent-skills owned skill"
provenance_note: "Enterprise research workflow candidate adapted by Ryan Spice-Finnie from reviewed external deep-research architecture patterns."
provenance_upstream: "199-biotechnologies/claude-deep-research-skill https://github.com/199-biotechnologies/claude-deep-research-skill; DeepWiki architecture view https://deepwiki.com/199-biotechnologies/claude-deep-research-skill"

---

# Enterprise Deep Research Workflow Candidate

Use this candidate when a user asks for high-stakes, citation-backed research that needs more than a normal web lookup or a quick file search.

This is an AI Wiki adaptation candidate, not a direct vendor copy. It captures the transferable pattern:

1. scope the question and decide depth,
2. plan research lanes,
3. retrieve from multiple sources,
4. store evidence as structured objects,
5. triangulate major claims,
6. synthesize into a report,
7. critique with explicit failure checks,
8. refine and package outputs.

## When to Use

Use this workflow for:

- major technology, vendor, hiring, business, SEO, or product decisions,
- research that needs current web evidence plus local AI Wiki / project notes,
- comparing options where bad evidence would waste money or time,
- creating client-facing or C-suite-facing reports,
- deep project archaeology across notes, repos, files, docs, and web sources,
- turning many skills / notes / pasted sources into a coherent brief.

Do not use this workflow for quick facts, tiny code fixes, simple definitions, or casual brainstorming.

## Modes

| Mode | Use | Minimum Evidence | Output |
| --- | --- | ---: | --- |
| Quick | fast map of a topic | 5 sources or local docs | concise brief |
| Standard | practical decision support | 10 sources / docs | structured memo |
| Deep | important technical / business choice | 15+ sources / docs | report + evidence matrix |
| Ultra | board/client/research-grade package | 25+ sources / docs | report + ledger + appendix |

## Research Contract

Every serious run should produce these artifacts, even if some are compact:

- `research-state.json` — resumable task state.
- `query-plan.md` — decomposed lanes and assumptions.
- `sources.json` — source metadata, URLs/paths, timestamps, credibility notes.
- `evidence-matrix.md` — claims mapped to supporting and conflicting evidence.
- `claims-ledger.md` — major claims, confidence, citations, open risks.
- `report.md` — final synthesis.
- `limitations.md` — what is uncertain, stale, missing, or inferred.

## Evidence Object

A retrieved item should be normalized before synthesis:

```json
{
  "id": "src-001",
  "kind": "web|file|repo|email|calendar|local-search|manual",
  "title": "Source title",
  "locator": "url, file path, git ref, message id, or search result pointer",
  "retrievedAt": "2026-05-22T00:00:00-04:00",
  "publishedAt": null,
  "authority": "primary|official|expert|secondary|forum|unknown",
  "credibilityScore": 0,
  "freshnessScore": 0,
  "usefulnessScore": 0,
  "summary": "What this source actually supports.",
  "claimsSupported": [],
  "claimsContradicted": [],
  "limitations": []
}
```

## Quality Gates

Before final output, check:

- no unsupported major claim,
- no stale-source assumption for current facts,
- no fake citations or placeholder URLs,
- every high-impact recommendation has evidence or a clearly labelled inference,
- conflicting evidence is acknowledged,
- the final answer distinguishes facts, interpretations, assumptions, and recommendations,
- local / private sources are cited or described separately from public web sources,
- generated artifacts do not expose secrets.

## AI Wiki Search Adaptation

This should become a search broker mode:

```powershell
Search -Mode Research -Query "compare candidate skills for deep research" -Profile wiki-default
Search -Skills -Query "deep research" -SelectMany -CopyFullContent
Search -Mode Evidence -Query "PixelBoats tavern NPC audio architecture" -Emit evidence-matrix
```

Required search/tool features:

- skill result multi-select,
- copy selected skill content to clipboard,
- structured evidence export,
- run-state file for continuation,
- source deduping across `rg`, Everything, Elastic, Git, and web,
- mode-aware freshness / QDF hints,
- explicit stale-content warnings.

## Reporting Style

For user-facing output, prefer:

1. answer first,
2. evidence summary,
3. decision matrix,
4. risks / limits,
5. next concrete action.

Avoid performative “research theatre.” A 40-page report that does not change the next decision is expensive wallpaper.
