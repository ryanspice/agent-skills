---
name: vibe-check
description: Audits AI-assisted code for production resilience issues: missing error handling, null/empty edge cases, scale failures, resource leaks, data integrity gaps, observability gaps, and rollout risks. Use before commit/push, during repo hardening, or when a feature seems to work locally but may fail under real load.
version: 0.1.0-aiwiki.1
status: candidate
type: universal-agent-skill
risk: medium
platforms: [windows, ai-wiki, mcp, claude-code, codex, trae, hermes, chatgpt]
tags: [code-review, ai-generated-code, safety, pre-push, audit]
source_name: Vibe Guard Skills
source_slug: codecoincognition-vibe-guard-skills
source_url: https://github.com/codecoincognition/vibe-guard-skills
source_path: skills/vibe-check.md
adapted: true
review_only: true
provenance_origin: "modified"
provenance_source_path: "04_skills/agent-skills/skills/vibe-guard-pack-aiwiki-adapted/vibe-check/SKILL.md"
provenance_credit: "Ryan Spice-Finnie"
provenance_ingested_as: "ryanspice/agent-skills owned skill"
provenance_note: "AI Wiki adaptation credited to Ryan Spice-Finnie, based on the external vibe-guard skill pack."
provenance_upstream: "codecoincognition/vibe-guard-skills https://github.com/codecoincognition/vibe-guard-skills"

---
# Vibe Check

## Purpose

Review code for production failures that AI-generated code often misses. This is not a style review. It is the "will this break at 2 a.m. when someone actually uses it?" pass. 🌙

## Trigger phrases

Use this skill when the user asks for:

- `vibe-check`
- production resilience audit
- edge-case pass
- scale/failure-mode review
- pre-push production check
- null guard / error handling / N+1 / leak review

## Scope modes

- **Default:** changed files or `git diff HEAD`.
- **Quick:** changed files, critical production issues only.
- **Full:** tracked source files, excluding generated/vendor/build output.

## Fixed checklist

### Error handling gaps

Check for external API, DB, file, async, and worker calls that lack useful failure handling. A `try/catch` that logs and continues blindly is not resilience; it is theatre.

### Scale failures

Look for:

- N+1 queries
- unbounded loops
- missing pagination
- full table scans
- unbounded in-memory transforms
- cache stampedes
- missing queue/backpressure/concurrency caps

### Edge cases AI commonly skips

Look for:

- empty arrays/collections
- null/undefined/nil inputs
- concurrent writes without locking/idempotency
- timezone assumptions
- integer/precision overflow
- off-by-one mistakes
- schema drift/version skew

### Untested or unexercised branches

If tests are in scope, call out important branches with no matching test path. If tests are not in scope, report the risky code path without inventing claims about test coverage.

### Resource leaks

Check DB connections, file handles, event listeners, timers, intervals, subscriptions, global maps/caches, and anything that grows across app lifetime.

### Data integrity

Look for multi-step operations without transaction boundaries, read-modify-write races, missing idempotency keys, and partial failure states.

### Observability

Check whether critical failures preserve context: request ID, tenant/user/project, operation name, upstream error code, structured logs, metrics, health signals, or traces.

### Rollout safety

Check env/config validation, migration compatibility, rollback safety, default feature flag behavior, and startup failure behavior.

## Adaptive pass

After the checklist, infer domain-specific risks:

- payments: duplicate charges, rounding, idempotency
- auth: token refresh races, session invalidation
- queues/workers: delivery semantics, poison jobs
- Svelte/React UI: stale lifecycle subscriptions, listener leaks, hydration assumptions
- WebGL/audio/game loops: unbounded buffers, RAF leaks, GPU resource cleanup

Skip the adaptive pass in quick mode.

## Output shape

```txt
VIBE CHECK — Production Resilience
Scope: <...>

CRITICAL
- path/file.ts:42 — Finding
  Risk: ...
  Fix: ...

WARNING
- path/file.ts:103 — Finding
  Fix: ...

PASS NOTES
- Error handling: no obvious gaps in scoped files.

SUMMARY: 1 critical · 1 warning
```

## Guardrails

- Do not fix automatically.
- Do not over-report generic theoretical issues with no file evidence.
- Mark speculative findings as `Needs verification`.
- Prefer small, targeted fixes over broad rewrites.

## References

- Upstream source path: `skills/vibe-check.md`
- Local original snapshot, when installed: `04_skills/candidates/codecoincognition-vibe-guard-skills-original/vibe-check/SKILL.md`
