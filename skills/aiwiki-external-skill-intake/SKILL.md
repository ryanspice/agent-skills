---
name: aiwiki-external-skill-intake
description: Imports and adapts external agent-skill repositories into Ryan's AI Wiki as review-only candidates with provenance, safe manifests, de-duped indexes, and optional promotion. Use when the user wants to incorporate an external skills repo, promote candidate skills, repair external-candidate indexes, or build a reusable skill-import package.
version: 0.1.0
status: active
type: generated-agent-skill
risk: medium
tags: ["ai-wiki", "skills", "external-candidates", "provenance", "promotion", "mcp", "powershell"]
canonical_path: 04_skills/generated/aiwiki-external-skill-intake/SKILL.md
created_at: 2026-05-20
provenance_origin: "original"
provenance_source_path: "04_skills/generated/aiwiki-external-skill-intake/SKILL.md"
provenance_credit: "Ryan Spice-Finnie"
provenance_ingested_as: "ryanspice/agent-skills owned skill"
provenance_note: "Original AI Wiki generated skill credited to Ryan Spice-Finnie."

---

# AI Wiki External Skill Intake

Use this skill when importing an external skill repository into Ryan's AI Wiki.

The default posture is **candidate-first, promotion-later**. External skill repos are review material until deliberately promoted. Do not dump external skills into `04_skills/universal`, `.claude/skills`, repo-local `.ai/skills`, or project folders by default.

## Canonical paths

Use these paths unless the user explicitly overrides them:

```txt
<AI_WIKI_ROOT>
04_skills/candidates/<source-slug>-adapted/<skill>/SKILL.md
04_skills/candidates/<source-slug>-original/<skill>/SKILL.md
03_indexes/skills/external-sources/<source-slug>.json
03_indexes/skills/external-sources/external-candidate-skills.<source-slug>.patch.json
03_indexes/skills/external-sources/external-candidate-skills.json
00_INBOX/proposed/<source-slug>-aiwiki-review-v<version>.md
```

For generated helper skills like this one, install under:

```txt
04_skills/generated/<skill-slug>/SKILL.md
```

## Intake workflow

1. Identify the upstream source.
   - `source_slug`
   - `source_name`
   - `source_url`
   - upstream paths for each skill
   - license/status if known

2. Stage adapted candidates.
   - Write adapted `SKILL.md` files under `04_skills/candidates/<source-slug>-adapted/<skill>/`.
   - Add `mcp-skill.json` when the skill should be discoverable by MCP-style tooling.
   - Strip tool-specific assumptions unless intentionally preserved as provenance.

3. Preserve original snapshots.
   - Store upstream originals under `04_skills/candidates/<source-slug>-original/<skill>/`.
   - Do not edit original snapshots except for safe filename/path normalization.

4. Write source manifests.
   - Write a source manifest to `03_indexes/skills/external-sources/<source-slug>.json`.
   - Write a patch file to `03_indexes/skills/external-sources/external-candidate-skills.<source-slug>.patch.json`.

5. Merge the global candidate index.
   - Correct path:
     `03_indexes/skills/external-sources/external-candidate-skills.json`
   - Add missing `source_slug` to candidate rows.
   - De-dupe by `source_slug`, `source_url`, `slug`, `local_candidate_path`, and `promotion_target`.
   - Back up the index before modifying it.

6. Write a review note.
   - Put it in `00_INBOX/proposed/`.
   - Include the decision, candidate set, layout, review checklist, and promotion recommendation.

7. Promote only after review.
   - Prefer promoting a single orchestrator skill first.
   - Keep leaf skills as candidate/support references unless they clearly need direct loading.
   - Rebuild/refresh the active skills registry only after promotion.

## Candidate row requirements

Every candidate entry should include:

```json
{
  "slug": "example-skill",
  "name": "Example Skill",
  "status": "candidate",
  "review_only": true,
  "adapted": true,
  "source_slug": "example-source",
  "source_url": "https://example.com/repo",
  "source_path": "skills/example.md",
  "local_candidate_path": "04_skills/candidates/example-source-adapted/example-skill/SKILL.md",
  "local_original_snapshot_path": "04_skills/candidates/example-source-original/example-skill/SKILL.md",
  "promotion_target": "04_skills/universal/example-skill/SKILL.md",
  "description": "What it does. Use when..."
}
```

## Review gates

Before promotion, check:

- Names do not collide with active skills.
- The adapted skill has portable wording and is not locked to one agent unless that is intentional.
- Security-related skills do not leak secrets or provide exploit walkthroughs.
- The candidate has source provenance.
- The candidate index has exactly one row per candidate.
- Repo-local setup will use pointers/MCP roots, not copied full skills.
- Registry rebuild is planned only after promotion.

## PowerShell habits

Generated installers and fix scripts should:

- default to dry-run unless `-Apply` is passed;
- use `-NoProfile -ExecutionPolicy Bypass` in command examples;
- create destination folders before extracting/copying;
- back up overwritten files;
- be re-runnable without duplicating index entries;
- print the exact paths used;
- fail early when a required file or wiki root is missing.

## Useful commands

Verify candidate rows for one source:

```powershell
$Index = "<AI_WIKI_ROOT>\03_indexes\skills\external-sources\external-candidate-skills.json"
$SourceSlug = "codecoincognition-vibe-guard-skills"

$json = Get-Content $Index -Raw | ConvertFrom-Json
$json.candidates |
  Where-Object source_slug -eq $SourceSlug |
  Select-Object slug, name, status, review_only, local_candidate_path, promotion_target |
  Format-Table -AutoSize
```

Check active-skill collisions:

```powershell
$Wiki = "<AI_WIKI_ROOT>"
"vibe-guard","vibe-check","vibe-secure","vibe-explain" | ForEach-Object {
  $Path = Join-Path $Wiki "04_skills\universal\$_"
  [pscustomobject]@{
    Skill = $_
    ExistsInUniversal = Test-Path $Path
    Path = $Path
  }
}
```

Repair a candidate index after a bad merge:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File "<AI_WIKI_ROOT>\04_skills\generated\aiwiki-external-skill-intake\scripts\repair-external-candidate-index.ps1" `
  -SourceSlug "codecoincognition-vibe-guard-skills" `
  -SourceUrl "https://github.com/codecoincognition/vibe-guard-skills" `
  -Apply
```

## Do not

- Do not point agents at the whole AI Wiki vault.
- Do not copy all candidate skills into a repo.
- Do not promote external candidates just because an import succeeded.
- Do not keep `.claude/skills` or any tool-specific folder as the AI Wiki canonical source.
- Do not rerun import installers after the index is correct unless intentionally refreshing from upstream.
- Do not leave duplicate candidate rows or missing `source_slug` values.
