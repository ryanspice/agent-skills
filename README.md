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
