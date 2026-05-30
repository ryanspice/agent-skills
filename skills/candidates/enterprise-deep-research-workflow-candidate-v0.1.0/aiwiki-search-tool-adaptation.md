---
title: AI Wiki Search Tool Adaptation - Enterprise Deep Research
version: 0.1.0
status: candidate
---

# AI Wiki Search Tool Adaptation

## What Transfers Cleanly

The upstream enterprise research pattern is mostly a search-orchestration and validation pattern. For the AI Wiki stack, the useful transfer is:

```text
query -> lanes -> retrieval -> evidence objects -> claim ledger -> synthesis -> validation -> package
```

## Broker Modes

### `Search -Mode Research`

Best for broad research across public and private sources.

Expected behavior:

- choose search lanes,
- run multiple query variants,
- dedupe sources,
- produce `sources.json`, `evidence-matrix.md`, and `report.md`.

### `Search -Mode Evidence`

Best for smaller research tasks where the final product is an evidence matrix, not a polished report.

Expected behavior:

- retrieve top sources,
- normalize evidence objects,
- map sources to claims,
- flag gaps.

### `Search -Skills`

Critical daily workflow.

Expected behavior:

- search generated, universal, and project skills,
- show selectable results,
- allow multi-select,
- copy selected full `SKILL.md` content to clipboard,
- optionally include README / related notes.

PowerShell target shape:

```powershell
Search -Skills -Query "sprite animation walking cycle" -SelectMany -CopyFullContent
```

## Suggested Implementation Order

1. Skill search with multi-select copy.
2. Evidence object export from local search results.
3. Claim ledger generation from selected evidence.
4. Research state save/resume.
5. Web + local mixed broker mode.
6. Report assembly and validation.

## Search Result Shape

```json
{
  "resultId": "aiwiki-001",
  "engine": "elastic|rg|everything|web|git",
  "corpus": "aiwiki|repo|downloads|file-library|web",
  "pathOrUrl": "<AI_WIKI_ROOT>/...",
  "title": "Skill or note title",
  "snippet": "Matched text",
  "score": 0.87,
  "freshness": "current|recent|old|unknown",
  "contentType": "skill|note|code|pdf|web|image|spreadsheet",
  "canCopyFullContent": true
}
```

## Clipboard Bundle Shape

For copied skills, use clear separators:

```text
<!-- BEGIN AI WIKI SKILL: path/to/SKILL.md -->
...
<!-- END AI WIKI SKILL -->
```

This matters because agents need stable boundaries and the user often pastes multiple skills into one new chat.

## Anti-Bloat Rule

Do not require every note in the AI Wiki to become a research object. Keep structured evidence at the boundary of serious research runs only. The vault should stay human-readable.
