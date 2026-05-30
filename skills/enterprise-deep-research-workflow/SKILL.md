---
name: enterprise-deep-research-workflow
version: 0.2.0
status: promoted
source_date: 2026-05-30
skill_type: enterprise-research-orchestration
recommended_agent: GPT-5.5 Thinking / Deep Research for public synthesis; Codex or local Hermes for AI Wiki/repo-backed execution.
tags:
  - ai-wiki
  - enterprise-research
  - deep-research
  - evidence-matrix
  - claims-ledger
  - validation-gates
  - source-verification
provenance_origin: "modified"
provenance_credit: "Ryan Spice-Finnie"
provenance_ingested_as: "ryanspice/agent-skills owned skill"
provenance_promoted_from: "skills/candidates/enterprise-deep-research-workflow-candidate-v0.1.0/SKILL.md"
provenance_note: "Promoted enterprise research workflow skill based on Ryan Spice-Finnie AI Wiki research operations adaptation."
provenance_upstream: "Promoted from skills/candidates/enterprise-deep-research-workflow-candidate-v0.1.0 after Prompt Operations deep research review."
risk_tier: medium
provenance_source_path: "04_skills/agent-skills/skills/enterprise-deep-research-workflow/SKILL.md"

---

# Enterprise Deep Research Workflow

Use this skill for high-stakes, citation-backed research that needs more than normal web lookup or quick file search.

## Use for

- major technology, vendor, hiring, business, SEO, or product decisions,
- research needing current web evidence plus local AI Wiki / project notes,
- client-facing or C-suite-facing reports,
- deep project archaeology across notes, repos, files, docs, and web sources,
- turning many skills / notes / pasted sources into a coherent brief.

Do not use for quick facts, tiny code fixes, simple definitions, or casual brainstorming.

## Minimum evidence by mode

| Mode | Use | Minimum evidence | Output |
|---|---|---:|---|
| Quick | fast map | 5 sources/docs | concise brief |
| Standard | decision support | 10 sources/docs | structured memo |
| Deep | important choice | 15+ sources/docs | report + evidence matrix |
| Ultra | client/board/research-grade | 25+ sources/docs | package + ledger + appendix |

## Enterprise research contract

Every serious run should produce:

```text
research-state.json
query-plan.md
sources.jsonl
evidence-matrix.md
claims-ledger.md
limitations.md
report.md
handoff.md
```

## Evidence object

```json
{
  "id": "src-001",
  "kind": "web|file|repo|email|calendar|local-search|manual",
  "title": "Source title",
  "locator": "url, file path, git ref, message id, or search result pointer",
  "retrievedAt": "2026-05-30T00:00:00-04:00",
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

## Quality gates

Before final output:

- no unsupported major claim,
- no stale-source assumption for current facts,
- no fake citations or placeholder URLs,
- every high-impact recommendation has evidence or clearly labelled inference,
- conflicting evidence is acknowledged,
- facts, interpretations, assumptions, and recommendations are separated,
- local/private sources are cited or described separately from public web sources,
- generated artifacts do not expose secrets,
- report has a continuation checkpoint.

## AI Wiki Search adaptation

Target command shapes:

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

## Anti-theatre rule

Enterprise mode is not “write more.” It is “make the claim/evidence chain reviewable.”
