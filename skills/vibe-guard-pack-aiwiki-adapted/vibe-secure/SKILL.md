---
name: vibe-secure
description: Audits AI-assisted code for security risks: hardcoded secrets, injection surfaces, auth/authz gaps, insecure defaults, mass assignment, insecure deserialization, prototype pollution, weak crypto, dependency risk, and business-logic races. Use before commit/push, around auth/payments/uploads/client data, or when the user asks for a security pass.
version: 0.1.0-aiwiki.1
status: candidate
type: universal-agent-skill
risk: medium
platforms: [windows, ai-wiki, mcp, claude-code, codex, trae, hermes, chatgpt]
tags: [code-review, ai-generated-code, safety, pre-push, audit]
source_name: Vibe Guard Skills
source_slug: codecoincognition-vibe-guard-skills
source_url: https://github.com/codecoincognition/vibe-guard-skills
source_path: skills/vibe-secure.md
adapted: true
review_only: true
provenance_origin: "modified"
provenance_source_path: "04_skills/agent-skills/skills/vibe-guard-pack-aiwiki-adapted/vibe-secure/SKILL.md"
provenance_credit: "Ryan Spice-Finnie"
provenance_ingested_as: "ryanspice/agent-skills owned skill"
provenance_note: "AI Wiki adaptation credited to Ryan Spice-Finnie, based on the external vibe-guard skill pack."
provenance_upstream: "codecoincognition/vibe-guard-skills https://github.com/codecoincognition/vibe-guard-skills"

---
# Vibe Secure

## Purpose

Find security holes before AI-generated code reaches a repo, client, or public deploy. This skill is for review and recommendations; it must not print secrets or apply fixes without approval. 🔐

## Trigger phrases

Use this skill when the user asks for:

- `vibe-secure`
- security audit
- auth/payment/upload review
- secret scan
- injection review
- pre-push security pass
- AI-generated code safety check

## Scope modes

- **Default:** changed files or `git diff HEAD`.
- **Quick:** changed files, critical security findings only.
- **Full:** tracked source files, excluding generated/vendor/build output.

Always infer and state the detected stack when useful, because JS prototype pollution, Python pickle, PHP file upload, and Rust unsafe boundaries are not the same animal.

## Fixed checklist

### Secrets and credentials

Find hardcoded API keys, tokens, passwords, private keys, certificates, secrets in comments/tests/logs, credentials in URLs, and server-side secrets exposed to client bundles.

### Injection surfaces

Check SQL, NoSQL, command execution, eval-like behavior, path traversal, template injection, XSS, SSRF, XML/XXE, URL/webhook destinations, and unsafe file path construction.

### Input validation gaps

Check user-controlled values before DB writes, file paths, auth decisions, structured fields, large text bodies, type assumptions, and enum/URL/email/content-type fields.

### Auth and authorization

Look for unprotected routes, missing object-level authorization, weak JWT/session handling, timing comparisons, CORS mistakes, CSRF gaps, and missing token/session invalidation.

### Insecure defaults

Check debug mode, stack traces, missing rate limits, cookie flags, security headers, insecure HTTP, file upload magic-byte validation, and cache control for sensitive pages/APIs.

### Mass assignment

Flag request bodies or payloads spread into models/entities without allowlisted fields.

### Insecure deserialization

Check Python pickle/yaml unsafe load/eval/marshal, JavaScript untrusted object spread into class-like structures, and language-specific deserialization foot-guns.

### Prototype pollution

For JS/TS, check recursive merge utilities, `Object.assign`, spread, lodash merge, and user-controlled `__proto__`, `constructor`, or `prototype` keys.

### Dependencies and crypto

Check unreviewed package names, postinstall scripts, missing lockfile integrity, MD5/SHA1 password hashing, `Math.random()` tokens, weak KDFs, nonce/IV reuse, and TLS verification disablement.

### Security logging and monitoring

Look for missing audit logs around login, logout, privilege changes, data export, payment initiation, webhook verification, and failed auth attempts.

### Business logic and races

Look for double-spend, duplicate-action, parameter tampering, tenant isolation gaps, and race windows where two requests pass a check before either commits.

## Adaptive pass

Infer domain-specific risks from the code: client sites, e-commerce, SaaS tenancy, local agents, MCP tooling, file upload, AI prompt execution, browser extension boundaries, and generated installer scripts.

Skip adaptive analysis in quick mode.

## Output shape

```txt
VIBE SECURE — Security Audit
Scope: <...>
Detected stack: <...>

CRITICAL
- path/file.ts:42 — Finding
  Risk: ...
  Fix: ...

WARNING
- path/file.ts:103 — Finding
  Risk: ...
  Fix: ...

SUMMARY: 1 critical · 1 warning
```

## Guardrails

- Redact secret values. Show only enough to locate the issue.
- Do not provide exploit instructions beyond what is needed to explain risk and remediation.
- Do not auto-fix auth, payments, file deletion, credentials, or production/client code.
- Prefer minimal, reviewable patches.

## References

- Upstream source path: `skills/vibe-secure.md`
- Local original snapshot, when installed: `04_skills/candidates/codecoincognition-vibe-guard-skills-original/vibe-secure/SKILL.md`
