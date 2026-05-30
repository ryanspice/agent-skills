# Search / Tool Adaptation Brief v0.1.0

## Verdict

Yes: both source projects adapt well to your search stack, but the right adaptation is **workflow architecture**, not blindly importing their exact agent prompts.

## Strong Patterns to Lift

| Pattern | Why it matters | AI Wiki/Search adaptation |
|---|---|---|
| Outline + fields contract | Prevents vague research drift | `outline.yaml` + `fields.yaml` per research run |
| Per-item structured outputs | Makes parallel work mergeable | `results/<item>.json` or JSONL evidence records |
| Resume/skipping completed items | Avoids repeating expensive searches | `research-state.json` with completed items and next actions |
| Source triangulation | Reduces hallucinated confidence | `claims-ledger.md` + `evidence-matrix.md` |
| Credibility scoring | Helps rank source results | source score in search index metadata |
| Progressive file assembly | Avoids giant one-shot answer collapse | append sections/files incrementally |
| Continuation state | Supports handoff between chats/agents | `.thoughts` + `research-state.json` checkpoint |
| Anti-hallucination protocol | Forces claim/source boundaries | validation checklist before final report |

## Adapt to Local Search Broker

Proposed command shape:

```powershell
Search -Mode Research -Query "compare local AI search approaches" -Profile aiwiki -Out .\research-runs\local-search-comparison
```

Expanded broker stages:

```text
1. classify query
2. choose lanes: local skills, project notes, repo, web, docs
3. decompose into search angles
4. collect candidates
5. de-duplicate by URL/path/title/hash
6. score source quality and freshness
7. write sources.jsonl
8. build evidence-matrix.md
9. generate or hand off report.md
```

## Critical AI Wiki Feature Tie-In

Add a first-class workflow for skill search:

```powershell
Search -Skills "deep research source verification" -SelectMany -CopyFullContent
```

Expected behavior:

- Search generated/project/universal skills.
- Show ranked result cards with path, status, tags, modified date.
- Multi-select results.
- Copy selected `SKILL.md` content plus lightweight source/path headers to clipboard.
- Optionally create a handoff bundle for Codex/Trae/GPT.

This connects directly to your recent requirement: searching skills, selecting multiple, and copying selected content for agent/chat handoff.

## Do Not Lift Blindly

- Do not hardcode `~/.claude` paths into AI Wiki tools.
- Do not always generate PDF/HTML; make outputs profile-driven.
- Do not rely on model memory first for current facts.
- Do not create huge reports when a decision table is enough.
- Do not let “autonomous” become “unreviewable.” Human checkpoints still matter.

## Proposed Tool Candidates

| Tool | Purpose | Priority |
|---|---|---:|
| `Search -Mode Research` | brokered multi-lane research run | P1 |
| `Search -Skills -SelectMany -CopyFullContent` | multi-select skill handoff | P0 |
| `New-ResearchRun` | scaffold question/outline/fields/state | P2 |
| `Export-ResearchEvidence` | create evidence matrix and claims ledger | P2 |
| `Test-ResearchReport` | validate citations/placeholders/coverage | P2 |

## Minimal POC

Start with the skill-copy workflow, then research mode. The skill-copy thing has immediate daily value; the full research broker is heavier and should earn its keep.
