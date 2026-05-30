---
name: deepseek-research-api-substrate
version: 0.1.0
status: candidate
skill_type: provider-research-substrate
risk_tier: medium
source_date: 2026-05-30
tags:
  - deepseek
  - provider
  - reasoning
  - api-compatibility
  - deep-research
  - hermes
  - ai-wiki
provenance_origin: "original"
provenance_credit: "Ryan Spice-Finnie"
provenance_ingested_as: "ryanspice/agent-skills owned skill"
provenance_note: "Candidate skill for DeepSeek as a research API substrate, held as candidate pending deeper source and API validation."
provenance_source_path: "04_skills/agent-skills/skills/candidates/deepseek-research-api-substrate-v0.1.0/SKILL.md"

---

# DeepSeek Research API Substrate

Use this candidate when comparing or wiring DeepSeek-style reasoning APIs into AI Wiki / Hermes / Prompt Operations research workflows.

## Important clarification

DeepSeek is not an OpenAI product. Treat it as a separate provider with OpenAI-compatible API surfaces.

## Use for

- provider comparison,
- Hermes model routing,
- OpenAI-compatible SDK adapter notes,
- exposed reasoning API behavior,
- local AI Wiki research workflows using DeepSeek models,
- deciding whether a task needs ChatGPT Deep Research product flow or a custom DeepSeek-backed agent.

## Do not use for

- claiming DeepSeek current model specs without refreshing official docs,
- project-specific HurrCut video workflow decisions,
- replacing source verification,
- assuming API compatibility means identical behavior.

## Required refresh before promotion

Before promotion, verify from official DeepSeek docs:

- current model names,
- context limits,
- reasoning mode parameters,
- ignored/unsupported parameters,
- tool-calling behavior,
- pricing,
- data policy,
- SDK compatibility examples,
- terms/license constraints.

## Comparison frame

```text
ChatGPT Deep Research
= productized research workflow with source controls, plan/review UX, browsing/files/apps, citations, export/reporting, and hidden/summarized reasoning.

DeepSeek API substrate
= model/provider layer with OpenAI-compatible API behavior, reasoning controls, long context possibilities, and custom-agent integration potential.
```

## Output contract

When used, return:

1. verified DeepSeek facts,
2. stale/unverified claims,
3. API compatibility notes,
4. integration risks,
5. which local skill/workflow should consume it,
6. whether it should remain candidate or be promoted.
