# Connected MCP surfaces per harness — discovery snapshot 2026-07-20

Read-only discovery evidence for the mcp-bridge capability maps. Configured does not mean
reachable; quota/probe state must be established per session. Never claim a tool works from
this file alone — it records what was *registered* on 2026-07-20.

## Claude Code (live-verified in the discovery session)

- `aiwiki` — 11 tools: `vault_search`, `vault_read`, `search`, `fetch`, `context_pack`,
  `graph_neighbors`, `inbound_list`, `stage_inbound_note`, `append_log`,
  `workbench_command_read`, `workbench_command_search`.
  `vault_search`, `context_pack`, `inbound_list` verified by live calls.
- `pixelboats` — 18 tools (see `pixelboats.adapter.json`), server v0.2.0, evidence-first contract.

## Hermes (`%USERPROFILE%\AppData\Local\hermes\config.yaml`, `mcp_servers:` block)

- `codegraph` (command: codegraph)
- `aiwiki` (command: node)
- `pixelboats` (command: node → `<DEV_ROOT>\PixelBoats\tools\pixelboats-mcp\dist\index.js`,
  profile `pixelboats-alpha`, mode `evidence`, expensive checks off, tool allowlist)

## Codex (`%USERPROFILE%\.codex\config.toml`, `[mcp_servers.*]`)

- `openaiDeveloperDocs`, `svelte`, `codegraph`, `pixelboats`, `node_repl`
- **Gap:** no `aiwiki` server registered. Owner approved registering it (2026-07-20 checkpoint);
  done in the harness-integration phase with a config backup.

## Kun (`%USERPROFILE%\.kun\mcp.json`, `servers`)

- `gui_schedule`, `filesystem`, `github`, `context7`
- **Gap:** neither `aiwiki` nor `pixelboats` registered. Owner approved registering both
  (2026-07-20 checkpoint); done in the harness-integration phase with a backup of `mcp.json`.

## Inbound staging truth

Live inbox: `AI-Wiki/00_INBOX/` with `proposed/reviewed/rejected` states (verified via
`inbound_list`). The package's `06_Inbound/proposed` boundary is legacy and absent on disk;
legacy provenance is consolidated into `00_INBOX`. `07_inbound` does not exist.
