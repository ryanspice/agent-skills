# Operational Contract

Version: 0.2.0

This contract governs repeatable free-model fleet refreshes across Fugu, Hermes, OpenCode, and T3 Code.

## Authority map

| Surface | Authority | Derived or protected material | Rule |
|---|---|---|---|
| Fugu policy | FUGU_POLICY_PATH | none | Read before every dispatch change |
| Fugu lanes | active adapter source | generated fleet manifest | Reconcile the adapter and regenerate its manifest |
| Hermes | Hermes base config and profile directories | profile hashes and receipts | Keep credentials per profile; never print .env |
| OpenCode | supported config and auth boundary | model cache | Keep provider/model IDs exact |
| T3 Code | supported application/UI boundary | userdata and secrets | Never edit userdata directly |
| Runtime receipts | FUGU_RUNTIME_ROOT | summaries and reports | Receipts outrank prose and exit codes |

## Route identity

Record provider and model separately. These are distinct routes even when the model string looks similar:

- OpenRouter-hosted exact model IDs;
- direct NVIDIA NIM model IDs;
- Kimi Code membership routes;
- NVIDIA-hosted Kimi routes;
- MiMo Token Plan routes;
- OpenAI/Codex subscription routes.

Never collapse them into free, kimi, nvidia, or another generic alias.

## Evidence gates

Keep these independent:

    catalog-listed
    account-entitled
    authenticated-inference
    tool-capable
    structured-output-capable
    broker-child-eligible
    task-accepted

An exact zero-cost catalog row is a candidate, not proof of dispatchability. A provider HTTP 200 or process exit code is not a successful canary unless the receipt proves a nonempty, correctly identified result.

## Refresh sequence

1. Capture location, PowerShell version, binary discovery, package state, dirty state, protected T3 paths, and hashes.
2. Read or refresh the sanitized provider catalog and provider-state ledger.
3. Reconcile one authoritative lane map with Hermes defaults and the generated manifest.
4. Stage additive changes with explicit provider/model IDs and model-specific limits.
5. Run static checks and adapter dry runs.
6. Run exact no-fallback/no-child canaries.
7. Keep children disabled until a separate capability gate passes.
8. Use the supported T3 UI/application surface for T3 selections.
9. Regenerate derived state, re-hash, semantically compare, inspect receipts, and record rollback.

## PowerShell and path rules

- Use pwsh -NoProfile -ExecutionPolicy Bypass.
- Pass roots explicitly; do not depend on the current directory.
- Re-hash generated manifests after inventory or validation commands.
- Use bounded dated backups before overwriting existing config.
- Do not put API keys, auth headers, .env values, raw prompts with secrets, or private customer data in receipts or snapshots.

## Acceptance ladder

| Gate | Required evidence | If missing |
|---|---|---|
| Parsed | config parses and expected files exist | stop |
| Catalog | exact ID appears in a fresh catalog | disable route |
| Auth | authenticated completion | classify failure |
| Capability | claimed tool/image/structured canary | remove claim or disable feature |
| Broker | policy-compliant adapter receipt | no children |
| Task | bounded task accepted | remain experimental |

## Rollback

Disable new routes first. Restore only backed-up touched files. Regenerate derived manifests. Keep receipts and old profiles until one known-good route proves the rollback. Restore T3 selections through T3, never by overwriting userdata.

## Failure taxonomy

Keep these distinct: catalog-unavailable, configuration-mismatch, auth-failed, entitlement-closed, rate-limited, retired-model, endpoint-invalid, timeout, stale-stream, tool-unsupported, structured-output-failed, paid-fallback-blocked, and protected-boundary.
