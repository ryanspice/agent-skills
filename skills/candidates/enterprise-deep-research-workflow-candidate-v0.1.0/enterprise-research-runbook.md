---
title: Enterprise Research Runbook
version: 0.1.0
status: candidate
---

# Enterprise Research Runbook

## 0. Intake

Capture:

- user question,
- decision being supported,
- deadline / depth expectation,
- known constraints,
- sources already provided,
- whether web freshness matters,
- whether private AI Wiki / repo / email / calendar context matters.

## 1. Scope

Classify the task:

| Signal | Mode |
| --- | --- |
| basic background / quick map | Quick |
| several options / moderate uncertainty | Standard |
| money, client, architecture, job, legal-ish, medical-ish, or irreversible cost | Deep |
| board/client-grade, public claim, large migration, high ambiguity | Ultra |

Write `query-plan.md` with assumptions. Do not block on clarification unless the question is impossible or unsafe.

## 2. Plan Research Lanes

Typical lanes:

- official / primary source,
- implementation examples,
- market / competitor / ecosystem,
- risks / counterarguments,
- local AI Wiki / previous project notes,
- repo code / issues / changelog,
- user-provided files / pasted source text.

## 3. Retrieve

Use the cheapest good-enough sources first:

1. local AI Wiki search,
2. repo search,
3. file library search,
4. web search,
5. direct official docs,
6. niche/community evidence only where primary sources are weak.

Normalize findings into `sources.json` evidence objects.

## 4. Triangulate

For every major claim:

- find at least one direct supporting source,
- note whether it is official, primary, secondary, or inferred,
- look for contradictory evidence,
- mark stale or uncertain evidence clearly.

Use `claims-ledger.md`.

## 5. Synthesize

Write prose after evidence, not before. Structure the report around decisions:

- what matters,
- what changed,
- what is known,
- what is uncertain,
- what the user should do next.

## 6. Critique

Run the critique persona checklist:

- skeptical practitioner: would this survive real work?
- adversarial reviewer: where could it be wrong?
- implementation engineer: what breaks during execution?
- client/stakeholder reader: is the answer usable and defensible?

## 7. Refine

Patch gaps. If gaps are material, run delta queries. If gaps remain, state them.

## 8. Package

Minimum package for AI Wiki:

```text
report.md
claims-ledger.md
evidence-matrix.md
sources.json
limitations.md
research-state.json
```

For generated deliverables, include `.thoughts` when the research connects to an ongoing project.
