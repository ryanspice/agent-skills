---
name: vibe-explain
description: Maps comprehension and cognitive debt in AI-assisted code by identifying opaque blocks, hidden assumptions, fragile coupling, magic constants, temporal coupling, and unowned logic. Use when the user needs to understand code before modifying, shipping, or accepting AI-generated work.
version: 0.1.0-aiwiki.1
status: candidate
type: universal-agent-skill
risk: medium
platforms: [windows, ai-wiki, mcp, claude-code, codex, trae, hermes, chatgpt]
tags: [code-review, ai-generated-code, safety, pre-push, audit]
source_name: Vibe Guard Skills
source_slug: codecoincognition-vibe-guard-skills
source_url: https://github.com/codecoincognition/vibe-guard-skills
source_path: skills/vibe-explain.md
adapted: true
review_only: true
provenance_origin: "modified"
provenance_source_path: "04_skills/generated/vibe-guard-pack-aiwiki-adapted/vibe-explain/SKILL.md"
provenance_credit: "Ryan Spice-Finnie"
provenance_ingested_as: "ryanspice/agent-skills owned skill"
provenance_note: "AI Wiki adaptation credited to Ryan Spice-Finnie, based on the external vibe-guard skill pack."
provenance_upstream: "codecoincognition/vibe-guard-skills https://github.com/codecoincognition/vibe-guard-skills"

---
# Vibe Explain

## Purpose

Find code the user does not fully own yet. The goal is not to shame complexity; the goal is to make risky logic understandable enough to maintain. 🧠

## Trigger phrases

Use this skill when the user asks for:

- `vibe-explain`
- cognitive debt map
- explain this AI code
- what do I not understand here
- ownership pass
- hidden assumptions review
- simplify without breaking behavior

## Scope modes

- **Default:** changed files or selected code.
- **Quick:** only sensitive/high-risk paths if requested.
- **Full:** tracked source files, excluding generated/vendor/build output.

## What to flag

### Black boxes

Non-obvious functions, opaque transform chains, hidden side effects, unclear state mutation, or code that works but does not communicate intent.

### Complexity barriers

Branch depth over 3, stacked transformations, uncommented regex/bitwise math, implicit recursive termination, multi-phase async flows, and state machines with no state model.

### Hidden assumptions

Magic numbers/strings, required ordering, undocumented preconditions, implicit caller guarantees, required setup state, and shape assumptions not asserted at boundaries.

### Fragility signals

Code likely to break from innocent changes: coupled fallbacks, hidden dependency order, parallel implementations, duplicated logic that can drift, or framework lifecycle assumptions.

### Naming opacity

Generic names on non-trivial values, boolean names that do not read as questions, implementation-shaped names, and names that hide business rules.

### Architectural/design intent gaps

Code that does not say why the approach exists, what tradeoff it accepts, what alternative was rejected, or what user/business rule it encodes.

### Implicit module contracts

Functions that require sorted/enriched/normalized inputs without asserting or documenting the contract.

### Temporal coupling and async ordering

Initialization races, teardown assumptions, cold-start sensitivity, incidental promise ordering, and cleanup that fails under error paths.

### Dead code and AI over-generation

Unused exports, speculative abstractions, duplicate fallback paths, helpers with no second consumer, and “future proofing” that only future-breaks your Friday night.

## For each finding

Return:

```txt
[vibe-explain] path/file.ts:55-89 functionName()
What it does: 3-5 sentence plain-English walkthrough.
Assumes: key preconditions.
Careful: what breaks if changed casually.
Own it: one concrete action: rename, extract, assert, test, comment, or delete.
```

## Debt score

Score lightly but usefully:

- raw ratio: flagged blocks / reviewed meaningful blocks
- severity-adjusted: auth/payment/client-data/compliance areas weigh more than small utility code
- label: Low, Medium, High

Do not pretend this is a scientific metric. It is a triage smell-o-meter. Useful, not sacred.

## Guardrails

- Do not demand comments for obvious code.
- Do not reward abstraction for its own sake.
- Prefer one ownership action per block.
- If code is good but dense, explain it and suggest a naming/comment/test improvement only if it materially reduces future risk.

## References

- Upstream source path: `skills/vibe-explain.md`
- Local original snapshot, when installed: `04_skills/candidates/codecoincognition-vibe-guard-skills-original/vibe-explain/SKILL.md`
