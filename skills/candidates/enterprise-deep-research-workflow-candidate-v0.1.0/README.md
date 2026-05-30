---
title: Enterprise Deep Research Workflow Candidate README
version: 0.1.0
status: candidate
created: 2026-05-22
---

# Enterprise Deep Research Workflow Candidate

This package imports an AI Wiki candidate skill adapted from the enterprise-style deep research pattern seen in `199-biotechnologies/claude-deep-research-skill` and its DeepWiki explanation.

It is meant to sit beside the lighter `deep-research-workflow-candidate` package. The lighter candidate is for reusable outline/deep-dive workflow design. This enterprise candidate is for decision-grade research, evidence tracking, source credibility, validation, and resumable report assembly.

## Installed Files

```text
00_INBOX/proposed/enterprise-deep-research-skills-ingest-v0.1.0.md
03_Indexes/skill-candidates/enterprise-deep-research-workflow-candidate-v0.1.0.json
04_skills/generated/candidates/enterprise-deep-research-workflow-candidate-v0.1.0/
  SKILL.md
  README.md
  enterprise-research-runbook.md
  aiwiki-search-tool-adaptation.md
  evidence-matrix-template.md
  claims-ledger-template.md
  research-state.schema.json
  validation-gates.md
  source-review.json
```

## Suggested Promotion Path

Keep this in generated candidates until the search stack can do at least:

- skill search,
- multi-select skill copying,
- evidence object export,
- local source deduping,
- continuation state files.

Then promote a cleaned version to:

```text
04_skills/universal/deep-research/enterprise-deep-research-workflow/SKILL.md
```

## Practical First Implementation

Do not start by building an all-singing research super-agent.

Start with:

```powershell
Search -Skills -Query "deep research" -SelectMany -CopyFullContent
```

Then add:

```powershell
Search -Mode Evidence -Query "..." -Emit evidence-matrix
```

The rest can grow from there without turning the vault into a schema bureaucracy machine.
