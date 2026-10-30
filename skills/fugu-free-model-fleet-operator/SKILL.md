---
name: fugu-free-model-fleet-operator
description: Maintains and upgrades exact free-model routes across Fugu, Hermes, OpenCode, and T3 Code with catalog refresh, staged configuration, fail-closed canaries, receipts, and rollback. Use when refreshing free models, updating the Fugu fleet, adding Hermes profiles, reconciling OpenCode providers, or making T3 Code model setup repeatable.
version: 0.2.0
status: active
type: universal-agent-skill
risk: high
platforms: [windows, ai-wiki, mcp, fugu, hermes, opencode, t3]
tags: [fugu, free-models, hermes, opencode, t3, routing, verification]
provenance_origin: "original"
provenance_source_path: "04_skills/agent-skills/skills/fugu-free-model-fleet-operator/SKILL.md"
provenance_credit: "Ryan Spice-Finnie"
provenance_ingested_as: "ryanspice/agent-skills owned skill"
provenance_note: "Reviewed and promoted from the AI Wiki free-model fleet refresh workflow."
---

# Fugu Free-Model Fleet Operator

Use this skill for a recurring, cross-surface provider refresh. The goal is an operationally verified fleet, not a list of model names.

## Use when

- refreshing the current free-model catalog;
- updating Fugu lanes or Hermes free profiles;
- reconciling OpenCode provider/model entries;
- preparing supported T3 Code model selections;
- snapshotting the fleet so a later Luna Light run can resume safely.

This skill does not authorize paid fallback, billing changes, public publication, deployment, direct T3 userdata edits, or broad cleanup.

## First read

Read these in order:

1. The current Fugu policy identified by the snapshot or FUGU_POLICY_PATH.
2. The newest secret-free snapshot under <AI_WIKI_ROOT>/05_Outputs/fugu-free-model-fleet/.
3. reference/operational-contract.md.
4. reference/luna-light-runbook.md when delegating.
5. The current files and receipts named by the snapshot.

The snapshot is evidence, not authority. Refresh live catalogs and provider state before selecting a route.

## Hard invariants

- Dispatch only through the current Invoke-FuguLane.ps1 adapter. Never bypass it with raw Hermes, Claude, Codex, or provider processes.
- Treat catalog listing, account entitlement, authenticated inference, tool support, child execution, and task acceptance as separate gates.
- Use exact provider and model identities. Never silently substitute a different model or open a paid wallet.
- Treat openrouter/free as random routing and noncritical-only unless the owner explicitly changes that boundary.
- Keep OpenRouter-hosted models, direct NVIDIA NIM models, Kimi Code membership, MiMo Token Plan, and OpenAI/Codex subscription routes as distinct provider identities.
- Never edit T3 live userdata or secrets directly. Use the supported UI or application boundary.
- Hermes profile .env files may be checked for presence, never printed, hashed into public reports, or committed.
- Never hand-edit the generated fugu-fleet.json; regenerate it from the authoritative adapter and validated profiles.
- Re-hash and semantically compare the generated manifest after adapter inventory, validation, or catalog commands because read-only-looking checks may refresh derived state.
- Preserve unrelated dirty work, old receipts, disabled routes, and rollback backups.

## Operating modes

Select one mode explicitly:

- Snapshot: read-only inventory plus a versioned, secret-free report.
- Plan: reconcile live catalog, route identities, profiles, and ownership boundaries; make no durable config edits.
- Stage: create bounded backups and prepare changes without enabling new routes.
- Apply: make only approved Fugu/Hermes/OpenCode changes; T3 changes remain on the supported UI boundary.
- Verify: run exact no-fallback/no-child canaries, inspect receipts, and classify failures.
- Rollback: disable new routes, restore only staged files, regenerate derived manifests, and prove one known-good route.

## Required order

1. Discover binaries, versions, paths, dirty state, protected T3 paths, and file hashes.
2. Refresh or read the current sanitized provider catalog and provider-state ledger.
3. Reconcile one authoritative Fugu lane map with Hermes profile defaults and the generated fleet manifest.
4. Stage Hermes profiles and OpenCode configuration with explicit provider/model IDs and model-specific limits.
5. Run static checks and Fugu dry runs.
6. Run exact provider canaries with -NoFallback -NoChildren; do not enable children yet.
7. Update T3 only through its supported UI/application surface when separately authorized.
8. Regenerate the manifest, record hashes and receipts, and run the acceptance checklist.
9. Leave new routes disabled when any gate is unknown, stale, unavailable, or mismatched.

## Luna Light handoff

Use reference/luna-light-runbook.md and templates/luna-light-engage.md. Luna may perform bounded implementation and verification through the adapter, but the root operator owns integration, protected-boundary decisions, final checks, and the final report. If Luna is not an eligible current Fugu route, stop and report that fact rather than inventing a dispatch path.

## Output contract

Return a compact evidence packet containing:

- snapshot path and timestamp;
- files changed and backups created;
- routes added, retained, disabled, or blocked;
- exact provider/model identities and profile hashes;
- commands run with PASS, FAIL, or NOT RUN;
- receipt locations and failure classes;
- paid-fallback status;
- T3 human/UI gates still required;
- rollback path and next action.

Read reference/receipt-schema.md for the minimum proof fields. Use scripts/Invoke-FuguFreeModelFleetSnapshot.ps1 for repeatable snapshots. Run the eval scenarios in examples/evals/ before changing the workflow.
