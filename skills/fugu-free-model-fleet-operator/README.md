# Fugu Free-Model Fleet Operator

This is the owned AI Wiki source skill for maintaining exact free-model routes across Fugu, Hermes, OpenCode, and T3 Code.

## Source of truth

The repository source is 04_skills/agent-skills/skills/fugu-free-model-fleet-operator. The AI Wiki registry consumes this repo-backed path directly. The separate universal copy under 04_skills/universal is retained as prior shelf material and must not become a second independently edited roster.

Current model IDs and provider entitlement are intentionally not embedded here. Read the newest sanitized snapshot under <AI_WIKI_ROOT>/05_Outputs/fugu-free-model-fleet/ and refresh live catalog/provider state before selecting a route.

## Layout

- SKILL.md — concise operator playbook.
- reference/ — operational contract, Luna handoff, and receipt schema.
- templates/ — reusable Luna prompt and report shape.
- examples/evals/ — happy-path, ambiguity, safety, regression, and composability cases.
- scripts/ — secret-free snapshot generator with explicit path bindings.

## Validate and rebuild

From this repository:

    pnpm run check
    pnpm run aiwiki:rebuild-indexes -- --apply

Validate the individual skill with the AI Wiki validator:

    python <AI_WIKI_ROOT>/04_skills/agent-skills/skills/creating-skills/scripts/validate_skill.py <AI_WIKI_ROOT>/04_skills/agent-skills/skills/fugu-free-model-fleet-operator

## Snapshot

Use PowerShell 7 and pass the current paths explicitly or bind them through environment variables documented in templates/luna-light-engage.md. The snapshot script writes only under the requested output root and never reads credential values.

    pwsh -NoProfile -ExecutionPolicy Bypass -File .\skills\fugu-free-model-fleet-operator\scripts\Invoke-FuguFreeModelFleetSnapshot.ps1 -AiWikiRoot <AI_WIKI_ROOT> -OutputRoot <AI_WIKI_ROOT>\05_Outputs\fugu-free-model-fleet

Use RefreshFuguCatalog only when an explicit live catalog refresh is intended. Do not commit generated snapshots, receipts, profile material, or .env files to this repository.
