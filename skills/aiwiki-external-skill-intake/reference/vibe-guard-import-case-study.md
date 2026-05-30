---
title: Vibe Guard Import Case Study
version: 0.1.0
source_slug: codecoincognition-vibe-guard-skills
status: reference
---

# Vibe Guard Import Case Study

This case study records the concrete workflow from importing `codecoincognition/vibe-guard-skills`.

## Source

```txt
source_slug: codecoincognition-vibe-guard-skills
source_name: Vibe Guard Skills
source_url: https://github.com/codecoincognition/vibe-guard-skills
```

## Candidate set

```txt
vibe-guard    orchestrator for production/security/comprehension checks
vibe-check    production resilience pass
vibe-secure   security pass
vibe-explain  comprehension/cognitive debt pass
```

## Staged paths

```txt
04_skills/candidates/codecoincognition-vibe-guard-skills-adapted/<skill>/SKILL.md
04_skills/candidates/codecoincognition-vibe-guard-skills-original/<skill>/SKILL.md
03_indexes/skills/external-sources/codecoincognition-vibe-guard-skills.json
03_indexes/skills/external-sources/external-candidate-skills.codecoincognition-vibe-guard-skills.patch.json
00_INBOX/proposed/vibe-guard-skills-aiwiki-review-v0.1.0.md
```

## Things that went wrong

### 1. `tar -C` does not create the destination folder

Bad:

```powershell
tar -xzf .\package.tar.gz -C .\package --strip-components 1
```

Good:

```powershell
New-Item -ItemType Directory -Force -Path .\package | Out-Null
tar -xzf .\package.tar.gz -C .\package --strip-components 1
```

### 2. Verification used the wrong index path

Wrong:

```txt
03_indexes/skills/external-candidate-skills.json
```

Right:

```txt
03_indexes/skills/external-sources/external-candidate-skills.json
```

### 3. Re-running the installer duplicated candidate rows

Fix by de-duping on:

```txt
source_slug
source_url
slug
local_candidate_path
promotion_target
```

### 4. Candidate rows were missing `source_slug`

Repair rows by matching `source_url`, then add `source_slug`.

## Clean final state

Expected candidate verification output:

```txt
vibe-guard
vibe-check
vibe-secure
vibe-explain
```

Each row should have:

```txt
status: candidate
review_only: True
source_slug: codecoincognition-vibe-guard-skills
```

## Promotion recommendation

Promote only `vibe-guard` first. Keep `vibe-check`, `vibe-secure`, and `vibe-explain` as candidate/supporting references until direct loading is justified.
