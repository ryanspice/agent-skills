---
name: spiceflow-mcp-bridge
description: Discover, map, validate, and use AI Wiki, PixelBoats, and future MCP servers through capability-based adapters. Use when work depends on connected project or knowledge sources, when a skill must call MCP tools, when tool names differ across harnesses, or when a new MCP should be integrated without coupling SpiceFlow to one server implementation.
metadata:
  provenance_origin: "unknown"
  provenance_source_path: "04_skills/agent-skills/skills/mcp-bridge/SKILL.md"
  provenance_credit: "Ryan Spice-Finnie (customization); earlier source unverified"
  provenance_ingested_as: "ryanspice/agent-skills owned skill"
  provenance_note: "SpiceFlow package customized for Ryan; earlier influence has not been identified."
---

# SpiceFlow MCP Bridge

**Bind to capabilities, discover actual tool names, and fail closed when authority is unclear.**

## Principles

1. Connected source evidence outranks remembered history.
2. Capability names are stable; MCP tool names may vary.
3. Read before write.
4. Stage before promote.
5. Verify every mutation.
6. Never invent a tool or claim a call succeeded when it was unavailable.
7. Keep credentials and connection details out of skills and artifacts.

## Capability vocabulary

Use stable aliases such as:

```text
knowledge.search
knowledge.context-pack
knowledge.read
knowledge.skill-list
knowledge.skill-get
knowledge.stage
knowledge.promote
project.search
project.read
project.write
project.test
project.build
project.asset-inspect
project.state
project.handoff
```

An adapter maps aliases to discovered MCP tools and records whether each capability is `required`, `optional`, `read-only`, `write`, or `unsupported`.

## Discovery workflow

1. Identify the connected MCP server and harness.
2. Enumerate available tools using the harness’s native discovery mechanism.
3. Match tools to capability aliases by schema and documented behavior, not name alone.
4. Record the map in an adapter manifest.
5. Test one read-only call per required read capability.
6. Test writes only in a bounded staging location with explicit authority.
7. Record limitations and fallbacks.

## AI Wiki MCP

Known read-oriented capability candidates include tools such as `vault_search` and `context_pack`. Treat exact availability as discoverable, not guaranteed.

Default behavior:

- search before opening broad files;
- retrieve a bounded context pack;
- use canonical skill metadata and registry evidence;
- stage generated skills and artifacts under `06_Inbound/proposed`;
- do not autonomously promote proposals into active canonical shelves;
- generate a promotion plan and validation result for review.

## PixelBoats MCP

The PixelBoats MCP should expose project authority without letting an agent improvise over the repository.

Required read capabilities should normally cover:

- repository and semantic search;
- bounded file reads;
- project instructions and architecture records;
- tests, builds, runtime evidence, and asset metadata;
- current task or handoff state.

Write capabilities must be explicit, scoped, reversible, and followed by project-native verification. New systems remain off-limits unless Ryan explicitly approves them.

## Future MCPs

For a new MCP:

1. generate an adapter with `New-SpiceFlowMcpAdapter.ps1`;
2. describe authority boundaries and lifecycle;
3. map capability aliases to actual tools;
4. define read, stage, write, and promote permissions separately;
5. add smoke tests and failure behavior;
6. reference the adapter from skills instead of embedding server-specific tool names.

## Failure behavior

If a required capability cannot be mapped:

- do not guess a tool name;
- do not fall back to stale memory for source-specific facts;
- report the missing capability;
- use an approved local or connector path when available;
- otherwise stop at a staged artifact or explicit handoff.

## Output

Return:

```text
Server: <resolved server>
Adapter: <path>
Mapped: <required capabilities>
Optional: <available optional capabilities>
Unsupported: <missing capabilities>
Authority: <read/stage/write/promote boundaries>
Verified: <smoke tests>
Next: <one bounded integration action>
```


## Growth & Feedback (promotion contract, 2026-07-20)

This skill is **dynamic** — a generated v0.3.0 snapshot with one canonical growth loop, not a frozen copy. Do not hand-edit it in place.

- **Friction or gap noticed in use:** log it via the AI Wiki MCP `append_log` (lightweight, no review burden).
- **Concrete growth request:** stage a proposal via `stage_inbound_note` into `AI-Wiki/00_INBOX/proposed` naming this skill, the trigger, and the wanted change.
- **Repeated feedback** on the same theme triggers a **skill-forge derivation**: a versioned update candidate (semver bump, provenance hash chain back to the v0.3.0 archive) staged as an inbound proposal.
- **Promotion is owner-gated:** candidates land only through the pnpm-validated `agent-skills` workflow. Derived indexes may rebuild automatically after validation; canonical content never self-promotes.
- Every harness adapter (Claude, Codex, Hermes, Kun) points at this one loop — no per-harness forks of skill content. Provenance: `PROVENANCE.md`.
