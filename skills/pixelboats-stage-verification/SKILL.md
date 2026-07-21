---
name: pixelboats-stage-verification
description: "Evaluate PixelBoats bedrock foundation stages (S0–S7) against formal exit criteria. Never mark a stage complete based on gameplay behavior or file existence alone."
version: 0.1.0
status: candidate
type: project-agent-skill
risk: medium
tags: ["pixelboats", "bedrock", "stages", "verification", "architecture", "exit-criteria"]
project: pixelboats
created_at: 2026-07-21
metadata:
  review_status: staged-candidate
  reviewers: [Nemotron, Vibethinker]
  replaces: none
  conflicts_with: none
  related_skills: [evidence-first-engineering, pixelboats-authority-resolution]
---

# PixelBoats Stage Verification

Load this skill before evaluating whether a bedrock foundation stage (S0–S7) is complete. It replaces "the game runs so S6 is done" with criterion-by-criterion evaluation.

## Source of Truth

```
B:/Dev/PixelBoats/BEDROCK_FOUNDATION.md
```

Every stage has a formal definition, a deliverable, and exit gates. This skill enforces evaluation against those gates — not against gameplay impressions.

## Stage Status Vocabulary

For each criterion:

| Status | Meaning |
|---|---|
| `satisfied` | Criterion met with evidence |
| `partial` | Some evidence exists, gaps remain |
| `missing` | No evidence found |
| `unknown` | Cannot determine with available tools |
| `manual-verification-required` | Needs human visual/audio/gameplay check |
| `runtime-verification-required` | Needs browser test or Playwright probe |
| `not-applicable` | Criterion does not apply to this stage |

## Evaluation Dimensions

Each stage criterion must be evaluated across ALL relevant dimensions:

1. **Behavior present** — Does the feature work when tested?
2. **Architecture adopted** — Is it on the canonical spine (A/B/C/P/D-S)?
3. **Legacy forks removed** — Are dead code paths deleted? No rival authorities?
4. **Tests passing** — Do focused tests pass?
5. **Performance proof complete** — Are frame budgets met? (S5+)
6. **Owner sign-off complete** — Has the owner visually confirmed? (All stages)

**Critical rule:** Never mark a stage complete while a required criterion is `unknown` or `manual-verification-required`.

## Stage Reference (from BEDROCK_FOUNDATION.md)

| Stage | Deliverable | Key Exit Gate |
|---|---|---|
| S0 | Freeze working tree | Commit `0909af2`, branches flattened to `main`+`master` |
| S1 | Bathymetry + sampleField | `water.sampleField` + `water.bathymetry` in packet |
| S2 | Worldgen + towns unified | `buildWorldTowns(seed)` pure pass, towngen fork removed |
| S3 | B renders from packet only | Dead 2D renderer + `USE_BP_SHADER_WATER` removed |
| S4 | Single projection | `boat-projection.ts` deleted, ship-lab on canonical P |
| S5 | D/S waterline/wake from A | `waterlineY` removed, waterline from A depth at hull pose |
| S6 | Interaction + camera follow | A queries drive interaction, camera follows via P inverse |
| S7 | Demo loop | Spawn→sail→dock via `dockGraph`, all off one packet |

## Output Format

```json
{
  "stage": "S6",
  "overall": "unverified",
  "evaluated_at": "2026-07-21T00:00:00Z",
  "repository_commit": "abc1234",
  "criteria": [
    {
      "id": "camera-follow",
      "status": "unknown",
      "dimensions": {
        "behavior_present": "unknown",
        "architecture_adopted": "partial",
        "legacy_forks_removed": "unknown",
        "tests_passing": "unknown",
        "performance_proof": "not-applicable",
        "owner_signoff": "manual-verification-required"
      },
      "evidence": [],
      "limitations": ["Camera transform wiring not yet traced"],
      "manual_checks": ["Visual confirmation of camera follow at 3+ zoom levels"]
    }
  ],
  "limitations": [
    "No runtime probes executed",
    "Owner sign-off pending for all criteria"
  ]
}
```

## Rules

1. **One criterion at a time.** Never batch-evaluate multiple criteria into one status.
2. **Behavior ≠ architecture.** A feature working in /game does not mean it's on the canonical spine.
3. **File existence ≠ completion.** A file being present does not satisfy an exit gate.
4. **Route 200 ≠ stage done.** Every stage requires multiple dimensions of evidence.
5. **Unknown stays unknown.** Don't guess. `unknown` is better than a false `satisfied`.
6. **Manual checks are real requirements.** Owner sign-off is not optional.
