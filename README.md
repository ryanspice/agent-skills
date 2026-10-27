## Agent Skills

This repository publishes reusable agent skills.

Current contents:

- `skills/tauri-sveltekit-svelte`
- `skills/vibe-guard`
- AI Wiki skill shelf content ingested directly under `skills/`

Ryan's AI Wiki now consumes this repository directly at
`04_skills/agent-skills/skills`. The retired local-created shelf is kept only
as historical provenance; this repo is the owned source and distribution
surface. Each skill document includes provenance and credit fields:

- `provenance_origin: "original"` for original Ryan/AI Wiki-created or
  pre-existing repository skills.
- `provenance_origin: "modified"` for skills adapted, revised, copied, or
  derived from another skill/source/reference.
- `provenance_credit: "Ryan Spice-Finnie"` for Ryan-created and locally
  mutated AI Wiki skills.
- `provenance_ingested_as: "ryanspice/agent-skills owned skill"` for the repo
  ownership lane.

See `skills/provenance.json` and `skills/README.md` for the full file and
skill index.

## Checks

```powershell
npm run check
npm test
npm run build
```

All three commands run the dependency-free skill validator.

## AI Wiki Integration

The AI Wiki consumes this repo from:

```text
S:\OneDrive\Obsidan\AI-Wiki\04_skills\agent-skills
```

Use the status helper after cloning or pulling inside the wiki:

```powershell
npm run aiwiki:status
```

Rebuild the AI Wiki skill indexes from the repo-backed source:

```powershell
npm run aiwiki:rebuild-indexes -- --apply
```

To preview linking repo skills into Codex as local junctions:

```powershell
npm run aiwiki:link-codex -- --all
```

Add `--apply` to create the junctions. Add `--replace` only when replacing
existing local Codex skill folders is intentional.

## Duplicate normalization policy (phase 1)

Active default exposure now runs through an explicit duplicate policy in:

- `scripts/skill-dedup-policy.json`

The rebuild script uses this policy to:

- keep repo-backed skills ahead of universal/project overlays,
- prefer highest semver when multiple repo-owned variants are present,
- suppress obvious copy-derived duplicates by default (e.g., `- Copy`),
- apply explicit per-name overrides (`repo-skill-recommender`, `vibe-guard`).

The current adjudication table used by AI-Wiki-visible docs is maintained at:

- `skill-duplicate-adjudication.md` (repo snapshot)
- `S:\\OneDrive\\Obsidan\\AI-Wiki\\03_indexes\\skills\\skill-duplicate-adjudication.md` (generated)

A metadata policy summary is also persisted in `skills/provenance.json`:

- `duplicate_policy.version`
- `duplicate_policy.ref`
- `skills[].selected_by_default`
- `skills[].selection_reason`

Run `npm run aiwiki:rebuild-indexes -- --apply` after any intentional policy update
to refresh AI-Wiki outputs with the canonical adjudication policy.
