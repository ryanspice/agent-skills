---
name: deep-research-workflow-candidate
version: 0.1.0
status: candidate
source_date: 2026-05-22
skill_type: research-orchestration
recommended_agent: GPT-5.5 Thinking or Codex for repo-backed execution; Claude Code if using Claude-native skill/task mechanics.
tags:
  - ai-wiki
  - research
  - search-broker
  - source-verification
  - citations
  - resumable-workflow
provenance_origin: "modified"
provenance_source_path: "04_skills/generated/candidates/deep-research-workflow-candidate-v0.1.0/SKILL.md"
provenance_credit: "Ryan Spice-Finnie"
provenance_ingested_as: "ryanspice/agent-skills owned skill"
provenance_note: "Research workflow candidate adapted by Ryan Spice-Finnie from reviewed external deep-research skill patterns; upstream source files were not vendored."
provenance_upstream: "Weizhena/deep-research-skills https://github.com/Weizhena/deep-research-skills; 199-biotechnologies/claude-deep-research-skill https://github.com/199-biotechnologies/claude-deep-research-skill"

---

# Deep Research Workflow Candidate

Use this when a question needs more than a normal answer: many sources, conflicting claims, current facts, technical/vendor comparison, market/SEO research, legal/regulatory surface review, or a decision that could waste money/time if wrong.

Do **not** use this for simple lookups, one-source answers, tiny debugging questions, or anything where a direct terminal/code fix is obviously faster. Don’t be dumb and summon a cathedral to hammer a nail.

## Core Pattern

```text
Scope → Outline → Search/Retrieve → Evidence Matrix → Triangulate → Synthesize → Critique → Package → Verify
```

The important adaptation for the AI Wiki is:

```text
question.md
outline.yaml
fields.yaml
sources.jsonl
evidence-matrix.md
claims-ledger.md
research-state.json
report.md
```

## Decision Tree

```text
Simple current fact?              → use normal web/search
Specific AI Wiki note/skill?      → use local Search lane, maybe multi-select copy
Repo/code question?               → use repo/code search first
Complex public research?          → run this candidate workflow
Client/SEO/market research?       → run this candidate workflow with local notes + web
Long report likely?               → use resumable state from the start
```

## Modes

| Mode | Use | Target |
|---|---|---|
| `quick` | Initial exploration | 5-10 sources, short evidence table |
| `standard` | Default serious research | 10-25 sources, report + claims ledger |
| `deep` | Important decision | 20-50 sources, counterevidence + credibility scoring |
| `ultradeep` | Rare, expensive, multi-session | resumable package, no giant one-shot slop |

## Phase 1 — Scope

Create `question.md` with:

```markdown
# Research Question

## User ask

## Decision this supports

## Audience

## Known constraints

## Source lanes
- AI Wiki local notes/skills
- project repo/docs
- web/current sources
- primary docs/specs
- prior generated packages, if relevant

## Stop conditions
```

Only ask a clarifying question when the ambiguity changes the output. Otherwise proceed and make assumptions visible.

## Phase 2 — Outline + Fields

Create:

```text
outline.yaml   # items/entities/topics to investigate
fields.yaml    # facts/fields each item needs
```

Good default fields:

```yaml
fields:
  - name: summary
    purpose: What this item/source says in plain English
  - name: evidence
    purpose: Verifiable facts, numbers, dates, quotes, or claims
  - name: source_quality
    purpose: Primary/secondary/opinion, freshness, authority, bias risk
  - name: relevance_to_user
    purpose: Why this matters for the actual task
  - name: risks_or_counterevidence
    purpose: What argues against it
  - name: reusable_patterns
    purpose: Workflow/tool/skill ideas worth adapting
  - name: uncertain
    purpose: Claims that need confirmation
```

## Phase 3 — Search / Retrieve

Decompose into search angles before fetching.

For AI Wiki/search broker work, route searches through lanes:

```text
local.skill-search      → existing skills, generated candidates, project skills
local.project-notes     → AI Wiki project docs, .thoughts, inbox/proposed notes
repo.code-search        → current repo implementation details
web.primary             → official docs, upstream repos, papers, standards
web.recent              → current pricing/news/releases/regulatory state
web.community           → forums/issues only after primary sources
```

Parallelize where the tool supports it, but don’t pretend background work is happening if the current runtime cannot actually do it.

## Phase 4 — Evidence Matrix

Create `evidence-matrix.md`:

```markdown
| Claim | Sources | Confidence | Counterevidence | Use in final? |
|---|---:|---|---|---|
| ... | [1], [2] | high/medium/low | ... | yes/no |
```

Rule: **no major claim enters the final answer unless it appears in the matrix or is clearly labelled as inference.**

## Phase 5 — Triangulate

For each load-bearing claim:

- Prefer primary/official sources.
- Use at least two sources for contested claims.
- Flag stale, salesy, generated, or circular sources.
- Separate fact from synthesis.
- Record “not found” instead of inventing a source. Obvious, and yet somehow civilization keeps needing this rule.

## Phase 6 — Synthesize

Produce `report.md` with:

```markdown
# Answer

## Best current read

## Evidence

## What this changes for the project

## Recommended adaptation

## Risks / caveats

## Next concrete move
```

## Phase 7 — Critique

Before delivery, run this checklist:

```markdown
- [ ] Are current/changing facts cited?
- [ ] Did we use primary sources where possible?
- [ ] Did any source get over-trusted?
- [ ] Are uncertain claims marked?
- [ ] Are recommended tools actually implementable locally?
- [ ] Did we avoid copying upstream code without license review?
- [ ] Did we preserve a continuation checkpoint?
```

## Phase 8 — Package / Verify

For AI Wiki ingestion, write:

```text
README.md
SKILL.md
search-adaptation.md
tool-candidate.*.md
deep-research-state.schema.json
source-review.json
.thoughts or project state note when relevant
```

## AI Wiki Specific Rules

- Candidate skills live under `04_skills/generated/candidates/<skill-name>/` until tested.
- Proposed project notes can live under `00_INBOX/proposed/` first.
- Use source URLs and source review notes, but do not vendor external repos unless explicitly intended and license-reviewed.
- Search should be able to discover this by tags: `research`, `source verification`, `deep research`, `evidence matrix`, `search broker`, `candidate skill`.

## Search-Broker Adaptation Hook

This workflow should become a `Search -Mode research` lane that:

1. Expands the query into search angles.
2. Searches local skills/notes first when the task is AI Wiki/project-related.
3. Uses web/current sources for unstable facts.
4. Builds `sources.jsonl` and `evidence-matrix.md`.
5. Lets the user select multiple skill/search results and copy full content to clipboard for agent handoff.

That last point matters. Skill search without multi-select copy is just a prettier way to waste your time.
