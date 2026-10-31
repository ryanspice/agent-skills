---
name: spiceflow-artifact-forge
description: Build durable, versioned TAR.GZ handoffs, implementation bundles, research packs, audit packs, visual asset packs, automation packs, and release artifacts. Use when Ryan asks to package work, create a TAR, produce scripts or installers, prepare a handoff, make work resumable, or leave another agent with a verifiable continuation artifact. Prefer PowerShell-first tooling, explicit manifests, acceptance checks, verification, rollback, and source authority.
metadata:
  provenance_origin: "unknown"
  provenance_source_path: "04_skills/agent-skills/skills/artifact-forge/SKILL.md"
  provenance_credit: "Ryan Spice-Finnie (customization); earlier source unverified"
  provenance_ingested_as: "ryanspice/agent-skills owned skill"
  provenance_note: "SpiceFlow package customized for Ryan; earlier influence has not been identified."
---

# SpiceFlow Artifact Forge

**Leave behind a package another capable person or agent can verify, install, continue, and undo.**

## Use this skill when

- creating a `.tar.gz` package;
- delivering code plus installation scripts;
- preparing a Codex, Claude, Hermes, Kun, Fable, Luna, or High Luna handoff;
- packaging research, audits, visual assets, automation definitions, or MCP adapters;
- converting chat output into a durable local artifact;
- preparing a versioned checkpoint before risky work.

## Artifact contract

Every durable package should contain only the files needed for its purpose, but normally includes:

1. `README.md` — purpose, contents, quick start, and source authority;
2. `HANDOFF.md` — current state, decisions, continuation sequence, and stop conditions;
3. `ACCEPTANCE.md` — observable completion checks;
4. `.thoughts.md` — decisions and rejected approaches, never private chain-of-thought;
5. `manifest.json` — name, version, type, source, generated files, hashes, and status;
6. `scripts/Verify-Package.ps1` — bounded validation;
7. `CHANGELOG.md` — meaningful version changes.

Add implementation, assets, docs, adapters, examples, or tests only when the package needs them.

## Package types

Use the narrowest matching package type:

- `implementation-bundle`
- `feature-handoff`
- `research-pack`
- `audit-report`
- `visual-asset-pack`
- `skill-pack`
- `mcp-adapter`
- `automation-pack`
- `release-handoff`

Do not mix unrelated deliverables into one archive merely because they were discussed together.

## Workflow

1. Lock the artifact purpose and consumer.
2. Identify the canonical source files and current version.
3. Generate from `templates/artifact` with `scripts/New-SpiceFlowArtifact.ps1`.
4. Add the smallest complete payload.
5. Add acceptance checks, install or usage instructions, rollback, and continuation guidance.
6. Run package validation.
7. Build the TAR with `scripts/Export-SpiceFlowPackage.ps1`.
8. Report the exact archive path and SHA-256.

## PowerShell safety

Before copy, delete, install, promotion, or archive operations:

- resolve source, destination, and working directory to full paths;
- print or record them;
- reject identical source and destination;
- reject a destination nested inside a source when recursion is possible;
- use `SupportsShouldProcess` and `-WhatIf` for mutating scripts;
- create backups before modifying existing configuration;
- use `pwsh -NoProfile -ExecutionPolicy Bypass`, not legacy `powershell`.

## Source authority

- The repository or package payload is authoritative.
- A generated image, rough prototype, chat fragment, or stale handoff is proposed material until promoted.
- Do not silently replace approved visual assets, architecture records, or existing scripts.
- Record where the package came from and what remains unverified.

## Verification

A package is not complete because the TAR exists. Verify:

- required files exist;
- JSON parses;
- PowerShell scripts parse when `pwsh` is available;
- internal paths resolve;
- generated archives list the intended root folder;
- the hash is recorded;
- install and rollback instructions refer to real files;
- no credentials, tokens, or personal secrets are included.

## Output

Return:

```text
Artifact: <name>-v<version>.tar.gz
Path: <absolute or sandbox path>
SHA-256: <hash>
Contains: <bounded summary>
Verified: <checks run>
Unverified: <remaining checks>
Next: <one continuation action>
```


## Growth & Feedback (promotion contract, 2026-07-20)

This skill is **dynamic** — a generated v0.3.0 snapshot with one canonical growth loop, not a frozen copy. Do not hand-edit it in place.

- **Friction or gap noticed in use:** log it via the AI Wiki MCP `append_log` (lightweight, no review burden).
- **Concrete growth request:** stage a proposal via `stage_inbound_note` into `AI-Wiki/00_INBOX/proposed` naming this skill, the trigger, and the wanted change.
- **Repeated feedback** on the same theme triggers a **skill-forge derivation**: a versioned update candidate (semver bump, provenance hash chain back to the v0.3.0 archive) staged as an inbound proposal.
- **Promotion is owner-gated:** candidates land only through the pnpm-validated `agent-skills` workflow. Derived indexes may rebuild automatically after validation; canonical content never self-promotes.
- Every harness adapter (Claude, Codex, Hermes, Kun) points at this one loop — no per-harness forks of skill content. Provenance: `PROVENANCE.md`.
