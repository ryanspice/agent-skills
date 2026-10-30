---
name: deep-research-workflow
version: 0.2.0
status: promoted
source_date: 2026-05-30
skill_type: research-orchestration
recommended_agent: GPT-5.5 Thinking, Codex for repo-backed execution, or a local Hermes/DeepSeek profile when local AI Wiki search is required.
tags:
  - ai-wiki
  - research
  - deep-research
  - search-broker
  - source-verification
  - citations
  - resumable-workflow
provenance_origin: "modified"
provenance_credit: "Ryan Spice-Finnie"
provenance_ingested_as: "ryanspice/agent-skills owned skill"
provenance_promoted_from: "skills/candidates/deep-research-workflow-candidate-v0.1.0/SKILL.md"
provenance_note: "Promoted research workflow skill based on Ryan Spice-Finnie AI Wiki research operations adaptation."
provenance_upstream: "Promoted from skills/candidates/deep-research-workflow-candidate-v0.1.0 after Prompt Operations deep research review."
provenance_source_path: "04_skills/agent-skills/skills/deep-research-workflow/SKILL.md"

---

# Deep Research Workflow

Use this skill when a question needs more than a normal answer: many sources, conflicting claims, current facts, technical/vendor comparison, market/SEO research, legal/regulatory surface review, or a decision that could waste money/time if wrong.

Do **not** use this for simple lookups, one-source answers, tiny debugging questions, or anything where a direct terminal/code fix is faster.

## Core pattern

```text
Scope -> Plan -> Search/Retrieve -> Evidence Matrix -> Triangulate -> Synthesize -> Critique -> Package -> Verify
```

## Mode selection

| Mode | Use | Target |
|---|---|---|
| quick | initial exploration | 3-8 sources, short evidence table |
| standard | default serious research | 8-20 sources, report + claims ledger |
| deep | important decision | 15-40 sources, counterevidence + credibility scoring |
| ultradeep | rare multi-session work | resumable package, no giant one-shot slop |

## Required artifacts

For standard or deeper work, create:

```text
question.md
query-plan.md
sources.jsonl
evidence-matrix.md
claims-ledger.md
limitations.md
report.md
research-state.json
```

For quick mode, a compact source table is enough.

## Source lanes

Route by task:

```text
local.skills          -> existing skills, generated candidates, project skills
local.project-notes   -> AI Wiki project docs, .thoughts, inbox/proposed notes
repo.code             -> current repo implementation details
repo.docs             -> README, ADRs, package docs
web.primary           -> official docs, upstream repos, papers, standards
web.recent            -> current pricing/news/releases/regulatory state
web.community         -> forums/issues only after primary sources
manual.user-provided  -> pasted text, uploaded files, screenshots
```

## Evidence rule

Search finds candidates. Source weighting creates evidence. Curated files decide.

No major claim enters the final answer unless it appears in the evidence matrix or is clearly labelled as inference.

## Claim validation

Before synthesis:

- Prefer primary/official sources.
- Use at least two independent sources for contested claims.
- Flag stale, salesy, generated, or circular sources.
- Separate fact from interpretation.
- Record “not found” instead of inventing a source.
- Cite current/changing facts.
- Preserve local/private source boundaries.

## Output style

Answer first, then evidence.

Use:

```markdown
# Answer

## Best current read

## Evidence summary

## Decision matrix

## Risks / caveats

## Next concrete move
```

## Stop rule

If the evidence no longer changes the decision, stop researching and make the next action explicit.
