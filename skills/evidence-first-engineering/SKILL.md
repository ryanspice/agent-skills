---
name: evidence-first-engineering
description: "Universal guardrail forcing step-by-step verification before gap claims, absence declarations, or severity labels. Applies to any repository audit, code review, or feature investigation."
version: 0.1.0
status: candidate
type: universal-agent-skill
risk: low
tags: ["evidence", "verification", "epistemics", "guardrail", "audit", "quality"]
created_at: 2026-07-21
metadata:
  review_status: staged-candidate
  reviewers: [Nemotron, Vibethinker]
  replaces: none
  conflicts_with: none
  related_skills: [pixelboats-mcp-verification-semantics]
---

# Evidence-First Engineering

Load this skill before any audit, gap analysis, code review, or feature investigation. It governs claim quality — it does not replace domain-specific skills.

## Required Claim Fields

Every material repository claim must identify:

| Field | Meaning | Example |
|---|---|---|
| **Scope** | Where the claim applies | `repo-runtime`, `repo-lab`, `external-ai-wiki` |
| **Evidence status** | How confident the claim is | `CONFIRMED_RUNTIME`, `SUPPORTED`, `INFERRED` |
| **Evidence source** | What produced the evidence | `grep`, `AST trace`, `runtime test`, `manual inspection` |
| **Limitations** | What the evidence does NOT prove | "Static reachability does not prove runtime execution" |
| **Required verification** | What else must be checked | "Runtime smoke test after user gesture" |

## Evidence Status Vocabulary

| Status | Meaning | When to use |
|---|---|---|
| `CONFIRMED_RUNTIME` | Verified by running the code | Browser console, Playwright, manual test |
| `CONFIRMED_STATIC` | Verified by AST/code analysis | Import tracing, type checking, grep with manual review |
| `SUPPORTED` | Evidence exists but is partial | File found, function exists, not yet runtime-verified |
| `INFERRED` | Reasonable deduction from available facts | Pattern match, convention, documentation |
| `REPORTED_RISK` | Reported but NOT reproduced | User report, log error, crash dump — not independently confirmed |
| `UNKNOWN` | No evidence available | Not checked, cannot determine, tooling unavailable |
| `DISPROVED` | Evidence contradicts the claim | Counter-example found, test failure, proven absent |

## Rules

1. **Grep is discovery, not proof of absence.** Keyword absence proves nothing. Trace imports, check adapters, search adapters.
2. **Static reachability does not prove runtime execution.** A file being imported does not mean its code runs, its events fire, or its resources load.
3. **File existence does not prove feature completion.** A `+page.svelte` existing does not mean the feature is done, tested, or architecturally integrated.
4. **Feature behavior does not prove architectural-stage completion.** /game being playable does not mean S6/S7 exit criteria are satisfied.
5. **Conflicting evidence must remain visibly conflicting.** Do not silently choose the most favorable interpretation. Present both sides.
6. **Never average contradictory facts into a consensus.** "Some files have it, some don't" is not "partially complete." List which files have it and which don't.
7. **"Zero", "missing", "none", "complete", "wired", "broken", "P0", and "P1" require explicit scope and evidence.** These are conclusions, not observations. Show your work.
8. **Unreproduced high-impact defects must be labeled `REPORTED_RISK`.** Do not escalate to `CONFIRMED` or `P0` without successful reproduction.
9. **State when manual or runtime verification remains required.** Static analysis has limits. Be explicit about what you did NOT verify.

## Structured Output for Audits

When returning counts or metrics, use separated fields — never a single averaged number:

```json
{
  "directories": 74,
  "top_level_svelte_routes": 57,
  "registry_entries": 68,
  "unregistered_routes": ["/lab/example-unregistered"],
  "phantom_registry_entries": ["deleted-lab-that-was-never-removed"],
  "raw_html_entries": [],
  "ignored_directories": ["node_modules", ".svelte-kit", ".tmp"],
  "repository_commit": "abc1234"
}
```

## Scope Labels

Every claim about presence or absence must prefix with one of:

- `repo-runtime` — Behavior observed in running application
- `repo-lab` — Behavior in lab/prototype route
- `repo-documentation` — Written in repo docs
- `repo-static` — Found via code analysis only
- `external-ai-wiki` — Found in AI-Wiki at `S:/OneDrive/Obsidan/AI-Wiki`
- `formal-stage-criteria` — Measured against BEDROCK_FOUNDATION.md exit gates
- `runtime-observation` — Seen during manual testing
- `historical-archive` — In archived/superseded code
