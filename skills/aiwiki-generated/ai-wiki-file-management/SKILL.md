---
name: ai-wiki-file-management
description: Manages Ryan's canonical AI Wiki safely, including naming, staging, promotion, MCP/Hermes skill scanning, project overlays, registry maintenance, and PowerShell-first verification. Use when working with the AI Wiki filesystem, skill shelves, inbound notes, indexes, or project skill mirrors.
version: 0.2.2
platforms: [windows, powershell, ai-wiki, obsidian, mcp, hermes]
tags: [ai-wiki, obsidian, file-management, naming, hermes, chatgpt, mcp, registry]
risk: medium
provenance_origin: "original"
provenance_source_path: "04_skills/generated/ai-wiki-file-management/SKILL.md"
provenance_credit: "Ryan Spice-Finnie"
provenance_note: "Original AI Wiki generated skill credited to Ryan Spice-Finnie."

---

# AI Wiki File Management

## Purpose

Use this skill when working with the canonical AI Wiki:

```txt
<AI_WIKI_ROOT>
```

The AI Wiki is a local-first, agent-aware knowledge vault for durable project knowledge, prompts, skills, research, context packs, handoffs, and operational notes.

## Hard rules

1. Treat `<AI_WIKI_ROOT>` as canonical.
2. Do not use `<DEV_ROOT>/ai-wiki` as canonical.
3. Do not point Hermes, MCP, or any agent at the whole AI Wiki for skill scanning.
4. Skill scanning roots must be narrow:
   - `04_skills/universal`
   - `04_skills/projects/<slug>`
   - `07_Projects/<slug>/.ai/skills` when present
5. New AI-generated durable wiki proposals go to `00_INBOX/proposed` unless the user deliberately runs a reviewed installer.
6. Durable wiki/project content is promoted only after review.
7. Do not expose secrets, `.env` files, API keys, credentials, private tokens, billing material, or client-sensitive data.
8. Use lowercase kebab-case for new folders/files, except required conventions like `SKILL.md` and `.thoughts`.
9. Preserve `.thoughts` as a no-extension Markdown state file with YAML frontmatter.
10. Use small, precise changes. Avoid broad vault rewrites.
11. Prefer PowerShell 7 via `pwsh`; keep Windows PowerShell-compatible fallbacks where practical.
12. Log promotions in `03_indexes/promotion.log` when moving reviewed content into durable locations.
13. Rebuild `03_indexes/skills/skills-registry.json` after adding, deleting, or moving skills.

## Folder Policy

- `00_inbox`: incoming unprocessed notes.
- `00_kit` or `00_tools`: local tooling, setup scripts, MCP/connector material.
- `01_raw`: raw exports, transcripts, source dumps.
- `02_wiki`: durable published knowledge; write-protected by default.
- `03_indexes`: generated indexes and manifests.
- `04_skills/universal`: reusable universal skills — canonical root.
- `04_skills/projects/<slug>`: project-specific canonical skills — PRIMARY PROJECT ROOT.
- `07_Projects/<slug>/.ai/skills`: project mirror (provenance only, NOT an active registry root).
- `DEPRECATED: 07_Projects/<slug>/skills`: project repo mirror (provenance only).
- `05_outputs`: generated reports, packs, and analysis.
- `06_clients`: client reference; sensitive.
- `00_INBOX`: staging area for proposed/reviewed/rejected content.
- `08_templates`: templates and examples.
- `09_archive` or `11_archive`: deprecated/cold storage depending on migration state.

### Two-tier root model

```
Canonical roots (indexed by rebuild_skills_registry.py):
  04_skills/universal/<skill-name>/
  04_skills/projects/<project-slug>/<skill-name>/

Mirror roots (tracked separately for provenance; never in active skill list until promoted):
  07_Projects/<project-slug>/.ai/skills/<skill-name>/
  projects/<project-slug>/skills/<skill-name>/
```

The active skill registry MUST only index canonical roots. Mirror roots feed a separate
mirror/provenance map.
- `00_INBOX/rejected`: rejected/generated clutter to keep out of durable docs.
- `08_templates`: templates and examples.
- `09_archive` or `11_archive`: deprecated/cold storage depending on migration state.

## Skill model

Use a two-layer skill model:

1. Universal skill: reusable procedure, technique, checklist, or implementation pattern.
2. Project skill: project-specific overlay that references universal skills and adds constraints.

Example:

```txt
04_skills/universal/creating-skills/SKILL.md
04_skills/projects/pixelboats/pixelboats-release-packaging/SKILL.md
<DEV_ROOT>/PixelBoats/.ai/skills/pixelboats-release-packaging/SKILL.md
```

Do not duplicate whole universal skill content into project overlays. Reference it and add project-specific deltas.

## Registry rules

The canonical registry is:

```txt
03_indexes/skills/skills-registry.json
```

It should be an object with metadata plus a `skills` array, not a single skill object.

Expected shape:

```json
{
  "schema_version": "1.0.0",
  "generated_at": "2026-05-18T00:00:00-04:00",
  "ai_wiki_root": "<AI_WIKI_ROOT>",
  "skill_roots": ["04_skills/universal", "04_skills/projects"],
  "skills": [
    {
      "slug": "creating-skills",
      "name": "creating-skills",
      "version": "0.1.2",
      "type": "universal-agent-skill",
      "status": "active",
      "path": "04_skills/universal/creating-skills/SKILL.md",
      "descriptor": "04_skills/universal/creating-skills/mcp-skill.json",
      "description": "..."
    }
  ]
}
```

Rebuild after changes:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File "<AI_WIKI_ROOT>/04_skills/universal/creating-skills/scripts/rebuild-skills-registry.ps1" -AiWikiRoot "<AI_WIKI_ROOT>"
```

Fallback:

```powershell
python "<AI_WIKI_ROOT>/04_skills/universal/creating-skills/scripts/rebuild_skills_registry.py" --ai-wiki-root "<AI_WIKI_ROOT>"
```

## Naming

Use lowercase kebab-case:

- `feature-matrix.md`
- `adaptive-audio.plan.md`
- `project-next-handoff.handoff.md`
- `ai-wiki-file-index.llm.md`
- `inventory.manifest.json`

Avoid:

- spaces
- `final`
- `misc`
- random timestamps unless the file is an output artifact
- duplicate `.md.md`

## Promotion workflow

1. Create or stage content in `00_INBOX/proposed`.
2. Review manually.
3. Move accepted content into `02_wiki`, `04_skills`, `04_skills/projects`, or the relevant project folder.
4. Move rejected content into `00_INBOX/rejected` or archive.
5. Append a promotion log line to `03_indexes/promotion.log`.
6. Rebuild relevant indexes/registries.

## Hermes / MCP rules

- External skill dirs are for loading skills, not for scanning the whole vault.
- Prefer absolute paths.
- Prefer read-only MCP tools by default:
  - `vault_search`
  - `vault_read`
  - `graph_neighbors`
  - `context_pack`
- Use write tools only for staging into inbound/proposed unless the user deliberately invokes an installer.
- Use launchers to set the working directory:
  - `haiwiki.ps1`
  - `hdev.ps1`
  - `hpixelboats.ps1`
  - `hhere.ps1`

## Obsidian environment rules

### `.gitignore` (Obsidian- and vault-aware)

Obsidian respects `.gitignore` natively (Settings → Files → Enable gitignore, enabled by default).
Place a `.gitignore` at the vault root to hide generated files from the file tree, graph view, and search.
Use the ready-made template: `templates/obsidian-vault-gitignore`.

**OneDrive independence:** `.gitignore` only controls Obsidian and (if/when) `git init` is done later. It does NOT stop OneDrive from syncing already-synced folders. To stop OneDrive syncing `node_modules`: right-click the vault folder → OneDrive → Choose folders → deselect the `node_modules` subfolder. Two layers, independent.

See `references/obsidian-gitignore-patterns.md` for the full coverage map and MCP interaction notes.

### `.obsidian/app.json` (local-only alternative)

If `.gitignore` is not yet available (e.g., Git initialization deliberately delayed),
Obsidian also reads `.obsidian/app.json` in the vault itself:

```json
{
  "userIgnoreFilters": ["node_modules/", ".git/", "dist/", "build/", ".idea/", ".vscode/"]
}
```

Restart Obsidian after editing. Local-only; does not sync via OneDrive or Git.

### Skill scanning roots

Never point Hermes, MCP, or any agent at the whole AI Wiki for skill discovery.
Use narrow roots:

| Root | Purpose |
|---|---|
| `04_skills/universal` | Universal skill shelf |
| `04_skills/projects/<slug>` | Project-specific shelf (auto-mirrored) |
| `07_Projects/<slug>/.ai/skills` | Repo-local project overlay |
Use narrow roots:

| Root | Purpose |
|---|---|
| `04_skills/universal` | Universal skill shelf |
| `04_skills/projects/<slug>` | Project-specific shelf (auto-mirrored) |
| `07_Projects/<slug>/.ai/skills` | Repo-local project overlay |

## Verification

```powershell
$AiWikiRoot = "<AI_WIKI_ROOT>"

Get-Location
Get-ChildItem -LiteralPath "$AiWikiRoot/04_skills/universal" -Recurse -Filter SKILL.md
Get-ChildItem -LiteralPath "$AiWikiRoot/04_skills/projects" -Recurse -Filter SKILL.md -ErrorAction SilentlyContinue
python "$AiWikiRoot/04_skills/universal/creating-skills/scripts/validate_skill.py" "$AiWikiRoot" --scan
python "$AiWikiRoot/04_skills/universal/creating-skills/scripts/rebuild_skills_registry.py" --ai-wiki-root "$AiWikiRoot"
```

<!-- AIWIKI_FILE_MANAGEMENT_PATH_PREFLIGHT_START -->
## Critical path preflight for AI Wiki scripts

Before running scripts that mutate the AI Wiki, require explicit roots and print the target paths.

Required checks:

- Confirm AiWikiRoot exists.
- Print current location and PSScriptRoot.
- Confirm whether the action is stage-only, dry-run, or apply.
- Confirm canonical paths before promotion:
  - 04_skills/universal/<skill>/SKILL.md
  - 04_skills/projects/<project>/<skill>/SKILL.md
- Confirm mirror paths are pointers, not canonical sources.
- Back up touched files before overwrite/delete.
- Rebuild 03_indexes/skills/skills-registry.json after canonical skill changes.
- Validate with creating-skills/scripts/validate_skill.py --scan --registry.
<!-- AIWIKI_FILE_MANAGEMENT_PATH_PREFLIGHT_END -->
<!-- AIWIKI_04_SKILLS_CANONICAL_RULE_START -->
## Canonical skill shelf rule

`04_skills` is the canonical home for AI Wiki skills.

Use:

- `04_skills/universal` for active universal skills
- `04_skills/projects/<project-slug>` for active project skills
- `04_skills/candidates/<source-slug>` for imported external candidate snapshots

Treat root-level `04_skills/projects/<project-slug>` as legacy placeholder/pointer paths only.

Treat `07_Projects/<project-slug>/.ai/skills` and `projects/<project-slug>/skills` as pointer mirror surfaces unless a tool explicitly requires full local copies.
<!-- AIWIKI_04_SKILLS_CANONICAL_RULE_END -->

<!-- AIWIKI_NUMBERED_VAULT_LAYOUT_RULE_START -->
## Current numbered vault layout

Use this layout as the active source of truth:

```txt
00_INBOX/
  proposed/
  generated/
  imports/
  reviewed/
  rejected/

03_Indexes/
  skills/
    skills-registry.json
    skill-mirrors.json

04_skills/
  universal/
  projects/
  candidates/

07_Projects/
  <project-slug>/
    .thoughts
    context/
    handoffs/
    .ai/
      skills/
        <skill>/
          SKILL.md
```

Canonical skill roots:

```txt
04_skills/universal/<skill>/SKILL.md
04_skills/projects/<project-slug>/<skill>/SKILL.md
```

Project-local skill pointers:

```txt
07_Projects/<project-slug>/.ai/skills/<skill>/SKILL.md
```

Deprecated as canonical roots:

```txt
skills/projects/
projects/
07_inbound/
07_Projects/<project-slug>/skills/
```

`skills-registry.json` indexes canonical roots only. `skill-mirrors.json` tracks pointer mirrors only.
<!-- AIWIKI_NUMBERED_VAULT_LAYOUT_RULE_END -->

<!-- AIWIKI_EXTERNAL_REPO_CANDIDATE_POLICY_START -->
## External repo candidate policy

External repo candidates under  4_skills/candidates/<source-slug> should be exact upstream git clones when possible.

Rules:

1. Keep the candidate clone updateable with git pull --ff-only.
2. Do not place AI Wiki adaptation notes, manifests, or generated files inside the clone.
3. Store source metadata in  3_indexes/skills/external-sources/<source-slug>.json.
4. Store pack metadata in  3_indexes/skills/packs/<pack-name>.json.
5. Store Ryan/AI adapted drafts in  4_skills/generated/<pack-or-skill>.
6. Promote reviewed active skills into  4_skills/universal or  4_skills/projects.
7. Do not index  4_skills/candidates or  4_skills/generated as active skill roots.

Original upstream is evidence. Generated/adapted is workspace. Universal/projects are active canon.
<!-- AIWIKI_EXTERNAL_REPO_CANDIDATE_POLICY_END -->
