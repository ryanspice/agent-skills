# Luna Light Runbook

Use this file when handing the free-model fleet refresh to a current Luna Light route.

## Mission

Refresh and, where proven safe, update the free-model routing surfaces across Fugu, Hermes, OpenCode, and T3 Code using the newest secret-free snapshot and current provider state.

## Required inputs

- <AI_WIKI_ROOT>/05_Outputs/fugu-free-model-fleet/<snapshot>/snapshot.json;
- the current Fugu policy and adapter paths recorded in that snapshot;
- the current provider catalog and sanitized provider-state ledger;
- this skill and reference/operational-contract.md.

## Authority and boundaries

- The root operator owns final integration and acceptance.
- Dispatch only through the current Invoke-FuguLane.ps1 adapter.
- Work only in bounded paths named by the snapshot and current task.
- Do not read, print, copy, hash, or edit API-key values, profile .env contents, T3 userdata, or client secrets.
- Do not run a paid fallback. Stop with needs-credits, entitlement-closed, or paid-fallback-blocked when appropriate.
- Do not hand-edit generated fleet manifests.
- Preserve unrelated dirty work, old receipts, disabled routes, and backups.

## Execution order

1. Read the newest snapshot and operational contract.
2. Verify location, PowerShell version, binaries, package state, and target hashes.
3. Refresh the sanitized catalog/provider state if stale.
4. Produce a pre-change discrepancy report; stop if the route source of truth is ambiguous.
5. Stage bounded backups.
6. Add or repair profiles and route definitions with exact identities.
7. Validate Hermes and OpenCode before inference.
8. Run a dry run, then exact no-fallback/no-child canaries.
9. Inspect receipts and selected provider/model identity, not only exit codes.
10. Update T3 only through the supported UI/application boundary when authorized.
11. Regenerate the manifest and run the complete acceptance checklist.

## Required report

Return PASS, PARTIAL, or FAIL with snapshot and backup paths, changed files, route decisions, exact identities, profile hashes, gate evidence, receipt paths, failure classes, paid-fallback proof, T3 status, rollback result, and one next action.

If a command, entitlement, tool, or UI surface is unavailable, report NOT RUN and the reason. Do not fill the gap with a guess.
