## Agent Skills

This repository publishes reusable agent skills.

Current contents:

- `skills/tauri-sveltekit-svelte`
- `skills/vibe-guard`
- `skills/aiwiki-generated`

The `skills/aiwiki-generated` tree mirrors Ryan's current AI Wiki
`04_skills/generated` route. Each exported skill document includes provenance
and credit fields:

- `provenance_origin: "original"` for original Ryan/AI Wiki generated or
  pre-existing repository skills.
- `provenance_origin: "modified"` for skills adapted, revised, copied, or
  derived from another skill/source/reference.
- `provenance_credit: "Ryan Spice-Finnie"` for generated and locally mutated
  AI Wiki skills.

See `skills/provenance.json` and `skills/README.md` for the full file and
skill index.

## Checks

```powershell
npm run check
npm test
npm run build
```

All three commands run the dependency-free skill validator.
