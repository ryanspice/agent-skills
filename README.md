## Agent Skills

This repository publishes reusable agent skills.

Current contents:

- `skills/tauri-sveltekit-svelte`
- `skills/vibe-guard`
- AI Wiki skill shelf content ingested directly under `skills/`

Ryan's current AI Wiki `04_skills/generated` route has been ingested directly
into this repository instead of being kept under a separate generated-export
folder. The AI Wiki path remains source provenance; this repo is the owned
distribution surface. Each ingested skill document includes provenance and
credit fields:

- `provenance_origin: "original"` for original Ryan/AI Wiki generated or
  pre-existing repository skills.
- `provenance_origin: "modified"` for skills adapted, revised, copied, or
  derived from another skill/source/reference.
- `provenance_credit: "Ryan Spice-Finnie"` for generated and locally mutated
  AI Wiki skills.
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

To preview linking repo skills into Codex as local junctions:

```powershell
npm run aiwiki:link-codex -- --all
```

Add `--apply` to create the junctions. Add `--replace` only when replacing
existing local Codex skill folders is intentional.
