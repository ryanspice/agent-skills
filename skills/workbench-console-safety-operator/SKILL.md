---
name: workbench-console-safety-operator
description: Audit, observe, verify, plan, apply, and restore console-safe AI Wiki workbench operations across MCP, Hermes, Claude, Codex, Kimi, Kun, Fugu, Svelte Lab, and Conversation Vault. Use when a terminal flashes unexpectedly, an MCP/client registration must be added, removed, or repaired, a silent launcher must be checked, the base AI Wiki bridge needs controlled action, or a weaker model needs a bounded command-free workflow with backups and rollback.
provenance_origin: "original"
provenance_source_path: "04_skills/agent-skills/skills/workbench-console-safety-operator/SKILL.md"
provenance_credit: "Ryan Spice-Finnie"
provenance_ingested_as: "ryanspice/agent-skills owned skill"
provenance_note: "Registered from the existing local working tree; earlier origins were not independently verified."
---

# Workbench Console Safety Operator

Use the typed operator surface. Never improvise a shell command, config path,
process filter, or client-specific mutation.

## Sources of truth

- Operation catalog:
  `<AI_WIKI_ROOT>\00_Kit\workbench\console-safety-operations.json`
- Local workflow:
  `<AI_WIKI_ROOT>\00_Kit\scripts\Invoke-WorkbenchConsoleSafety.ps1`
- Client registration manifest:
  `<AI_WIKI_ROOT>\00_Kit\workbench\mcp-clients.json`
- Static regression gate:
  `<AI_WIKI_ROOT>\00_Kit\scripts\Test-WorkbenchMcpConsoleSafety.ps1`

Prefer the `workbench_ops` MCP target. Use the local workflow only when the MCP
target is unavailable or when the catalog marks an operation local-only.

## Non-negotiable rules

1. Keep the normal AI Wiki MCP read-only.
2. Never stop or restart Claude, Hermes, Codex, Kimi, Kun, or a user-owned
   terminal session.
3. Never accept an arbitrary command, path, process ID, process name, or config
   fragment.
4. Never enable the admin operator or process-control gate merely because a tool
   call failed.
5. Treat existing visible processes as inventory, not permission to close them.
6. Keep command lines out of popup-observation receipts because they may contain
   private arguments.
7. Require a fresh plan for every live change. Never reuse an expired, consumed,
   drifted, or failed plan.
8. Show the exact plan ID, change, targets, expiry, and disruptive label to the
   owner before apply.
9. Apply only after explicit owner approval for that exact plan.
10. Report rollback honestly. A failed apply that rolled back is not a success.

## Decision workflow

### 1. Discover

Call `workbench_ops_catalog`. Confirm that the requested capability exists and
read its authority label.

Local fallback:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File "<AI_WIKI_ROOT>\00_Kit\scripts\Invoke-WorkbenchConsoleSafety.ps1" -Action Catalog -Json
```

If the capability is absent, stop. Do not approximate it with a generic
terminal command.

### 2. Establish current state

Call `workbench_ops_status`, then `workbench_ops_audit`.

- Use status for a compact readiness and persistence summary.
- Use audit for launchers, MCP registrations, Hermes profiles, scheduled tasks,
  Startup persistence, and hidden-launcher parity.
- Do not interpret a user-visible existing session as a popup violation.

### 3. Observe an intermittent popup

Call `workbench_ops_observe` for 1–55 seconds. Repeat bounded calls when the
reported interval is longer. Correlate process name, PID, parent PID, and
visible-window state; do not infer ownership from the name alone.

Observation is diagnostic only. It never authorizes termination.

### 4. Verify

Call `workbench_ops_verify` with:

- `core` for console safety, MCP/client health, Conversation Vault, Kun, and
  Hermes TUI;
- `extended` for direct-Node Fugu and Svelte Lab check/test/build gates;
- `all` only when the broader runtime cost is justified.

### 5. Plan an add, remove, repair, or bridge action

Call `workbench_ops_plan` with exactly one catalog change:

- `repair-base-clients`
- `enable-conversation-curator`
- `disable-conversation-curator`
- `enable-workbench-operator-admin`
- `disable-workbench-operator-admin`
- `ensure-base-bridge`
- `restart-base-bridge`
- `stop-base-bridge`

The plan must contain target snapshots, an integrity hash, an expiry, and an
exact confirmation token. Planning may write a receipt under the machine-local
runtime root; it does not change a live config or process.

Stop here unless the owner has explicitly approved this exact plan.

### 6. Apply

Use `workbench_ops_apply` only when it is already exposed by an owner-enabled
operator target. Pass the exact plan ID and confirmation token.

The apply must:

- reject changed target hashes;
- create a machine-local backup;
- touch only allowlisted targets;
- avoid process/session termination;
- run post-apply verification;
- roll back file changes automatically when verification fails;
- emit a receipt.

Bridge control additionally requires the separate process-control environment
gate. The admin configuration-write target does not enable that gate.

### 7. Restore

Use `workbench_ops_restore` only for a successful config receipt and its exact
restore token. Restore must refuse when any target changed after apply.

Process-control receipts are not automatically restorable.

## Adjacent routes

- Conversation listing/replay: use `agent_recovery`,
  `conversation_recovery_list`, or `conversation_replay`. These never launch an
  agent, and Codex remains separate unless requested.
- cot-extractor analysis: take the exact local command from
  `conversation_replay` or the `agent-conversation-recovery` skill. Use visible
  transcript evidence only; never infer that recovered reasoning is ground
  truth, and never start provider-backed re-elicitation without approval.
- Conversation curation: use `conversation_build_context`, then the optional
  curator's `stage_inbound_note` for at most one deduplicated proposal. Raw
  transcripts never become ordinary AI Wiki notes.
- Research artifact refresh: use `workbench_ops_research_status`,
  `workbench_ops_research_discover`, `workbench_ops_research_verify`, and
  `workbench_ops_research_plan`, then load the
  `research-harness-archive-operator` skill. Apply is append-only and available
  only on the separately write-enabled operator after approval.
- DeepResearch: use the canonical `00_Kit\scripts\DeepResearch.ps1` surface and
  dry-run first. Keep its cache below `<AI_WIKI_RUNTIME_ROOT>`; do not route routine
  work through the legacy quick/heavy orchestrator.
- Skill changes: scaffold one canonical skill with `skill-creator`, validate it,
  rebuild the AI Wiki skill indexes, and link it through
  `aiwiki-link-codex.mjs`. Disable or deprecate through a reviewed targeted
  change; never bulk-delete live skill folders.
- Conversation Vault runtime install: use the cataloged local installer. Do not
  expose it as an MCP mutation.
- Kun runtime install: use the cataloged local installer and keep runtimes
  outside OneDrive. GitHub must use the pinned official native binary through
  `github-mcp-stdio-launcher.mjs`, with fixed read-only toolsets, GitHub CLI
  credential relay, checksum verification, no surprise OAuth, and no
  `@modelcontextprotocol/server-github` registration.
- Fugu delegation: use only `Invoke-FuguLane.ps1`; dry-run first and never
  hand-build a Hermes launch command.

## Failure behavior

- Missing read-only MCP: use the exact local workflow fallback.
- Missing admin MCP: return the plan and explain that live authority is not
  enabled; do not enable it autonomously.
- Hash drift: create a fresh plan after re-auditing.
- Verification failure with rollback success: report the failed check and
  confirmed rollback.
- Rollback failure: stop immediately and report the backup and receipt paths.
- Unknown operation or target: fail closed.

## Output contract

Return:

```text
Capability: <catalog id>
Authority: <read-only | bounded diagnostic | plan then write | owner-only local>
State: <verified summary>
Plan: <id or none>
Applied: <yes/no>
Verification: <checks and result>
Rollback: <not needed | completed | failed>
Sessions touched: none
Next: <one bounded action>
```
