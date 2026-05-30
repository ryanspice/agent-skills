---
title: External Skill Intake Workflow
version: 0.1.0
status: reference
---

# External Skill Intake Workflow

This reference expands the operational flow for importing external skill repositories into the AI Wiki.

## 1. Source assessment

Capture:

```txt
source_slug:
source_name:
source_url:
license:
upstream_skill_paths:
tool_assumptions:
candidate_count:
recommended_default:
```

Classify the source:

| Class | Meaning | Default action |
| --- | --- | --- |
| Portable skill repo | Mostly generic agent skills | Stage candidates |
| Tool-specific skill repo | Claude/Codex/Cursor-specific commands | Adapt to portable candidates |
| Prompt collection | Useful patterns, not skills yet | Stage as notes or source reference |
| Repo-specific rules | Only useful for one project | Stage under project skill candidates |
| Risky/unclear | Security, licensing, stale, low quality | Do not promote |

## 2. Candidate adaptation

For every candidate:

- keep the core workflow;
- translate slash commands into invocation phrases;
- remove tool-specific install assumptions from the adapted copy;
- preserve the original in `*-original`;
- keep provenance in frontmatter and manifest JSON;
- mark `review_only: true`.

## 3. Index merge rules

The global candidate index lives at:

```txt
03_indexes/skills/external-sources/external-candidate-skills.json
```

Do not use:

```txt
03_indexes/skills/external-candidate-skills.json
```

That path was a real-world footgun. Check the actual file before declaring the merge broken.

## 4. Idempotence

Installers must be safe to rerun:

- copy files with backups;
- merge candidate entries without duplicates;
- de-dupe source records;
- update `updated_at`;
- add missing `source_slug`;
- avoid rewriting active skills unless promotion is explicitly requested.

## 5. Promotion strategy

Promote the smallest useful active surface.

For a skill family with an orchestrator and leaf skills:

```txt
Promote:
  orchestrator

Keep as candidates/support:
  leaf audit skills
  tool-specific command wrappers
```

Promote leaf skills later only when direct invocation actually improves agent behavior.

## 6. Review note template

```md
---
title: <Source Name> AI Wiki Import Review
version: 0.1.0
source_slug: <source-slug>
source_url: <url>
status: proposed
created_at: YYYY-MM-DD
---

# <Source Name> AI Wiki Import Review

## Decision

Stage as external candidates first.

## Why

Explain what the upstream repo does and what adaptation was needed.

## Candidate set

- `<skill>` — description.

## Proposed AI Wiki layout

```txt
04_skills/candidates/<source-slug>-adapted/<skill>/SKILL.md
04_skills/candidates/<source-slug>-original/<skill>/SKILL.md
03_indexes/skills/external-sources/<source-slug>.json
03_indexes/skills/external-sources/external-candidate-skills.<source-slug>.patch.json
```

## Review checklist

- [ ] Names do not collide.
- [ ] Provenance is present.
- [ ] Candidate index is de-duped.
- [ ] Security wording is safe.
- [ ] Promotion plan is explicit.

## Recommendation

Promote only the orchestrator first, unless there is a strong reason to promote leaf skills.
```
