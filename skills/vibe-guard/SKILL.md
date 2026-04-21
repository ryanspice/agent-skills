---
name: vibe-guard
description: Use this skill when building, auditing, or refactoring AI-generated code.
---

# Vibe Guard Skill

## Purpose

Security, privacy, build-safety, repo-hygiene, and agent-behavior guardrails for AI-generated code.

This skill is always active. Use it for every project where an AI agent edits code, config, scripts,
CI, docs, build tooling, generated files, deployment files, or project structure.

## Operating mode

Act as a security-minded senior engineer and a disciplined repo-aware coding agent.

Before changing code:

1. Identify the runtime surface: browser app, server app, desktop app, CLI, worker, static site,
   automation script, test harness, CI job, deployment pipeline, generated artifact, or local tool.
2. Identify trust boundaries: user input, filesystem, shell/process calls, environment variables,
   APIs, database, cookies, OAuth, IPC/native commands, plugins, external URLs, generated files,
   logs, and local app state.
3. Inspect the existing repo patterns before inventing new ones.
4. Make the smallest safe patch.
5. Do not introduce broad rewrites, new dependencies, weakened config, disabled checks, or fake
   abstractions to “make it work.”
6. Report risk honestly. Passing a build is not the same thing as being safe.

When security and convenience conflict, security wins unless the user explicitly accepts the risk.

## Critical rules

### 1. Never hardcode secrets

Never commit API keys, OAuth secrets, tokens, passwords, private URLs with credentials, connection
strings, certificates, private keys, signing material, or local machine secrets.

Use environment variables, secret stores, ignored local config, `.env.example`, documented
placeholders, or setup instructions.

Safe pattern:

```text
SECRET_VALUE = read_from_environment("SECRET_VALUE")
```

### 2. Validate input at every boundary

Validate all external and cross-boundary input:

- HTTP bodies and query params
- form submissions
- route params
- IPC/native command args
- file paths
- uploaded/imported files
- JSON/YAML/TOML/config files
- CLI args
- webhook payloads
- external API responses
- generated files before reuse

Prefer lightweight schemas or focused validators. Do not add heavy validation dependencies for tiny
checks.

### 3. Encode output and avoid injection

Never trust user-controlled strings in:

- HTML or rich text
- database queries
- shell/process commands
- file paths
- redirects
- logs
- generated config
- script/style snippets
- Markdown rendered as HTML

Avoid raw HTML or unsafe rendering. If unavoidable, sanitize first and explain the trust model.

### 4. Protect authentication and authorization

Authentication proves identity. Authorization controls access. Do both.

Every private route, mutation, admin screen, server action, API endpoint, backend task, native
operation, and destructive tool must check authorization near the action being performed.

Do not rely on hidden buttons, disabled UI, route names, local state, or client-only checks for
security.

### 5. Keep user and tenant boundaries intact

For multi-user or multi-tenant data:

- filter by authenticated user or tenant
- enforce storage/database policies where available
- never fetch broad private data and filter only in the UI
- never trust user-provided ownership or tenant IDs
- test at least one “wrong user/wrong tenant” case when touching access logic

### 6. Use safe data access

No string-concatenated queries. Use parameterized queries, query builders, safe APIs, or the repo’s
existing safe abstraction.

Safe pattern:

```text
query("select fields from records where id = ?", [record_id])
```

Never pass unchecked user input directly into query strings, filters, storage keys, collection names,
or query fragments.

### 7. Lock down IPC, plugin, and native command surfaces

For desktop, local tooling, or agent-controlled apps:

- expose the smallest possible command surface
- validate every command argument on the receiving side
- return typed/sanitized errors without leaking internals
- keep filesystem, shell, dialog, network, process, and plugin permissions narrow
- never let UI input directly choose arbitrary commands, paths, URLs, or executables
- keep dangerous operations behind explicit state checks and confirmation where appropriate

Danger signs:

- shell execution from user input
- unrestricted file writes
- recursive deletes
- broad plugin permissions
- native commands exposed without state checks
- UI-only protection for privileged operations

### 8. Treat filesystem paths as hostile

Normalize and constrain paths before reading or writing.

Rules:

- reject path traversal
- restrict writes to approved project/app/data directories
- avoid unsafe symlink behavior for destructive actions
- generate safe filenames internally
- validate extensions and file signatures where relevant
- never write using raw user-provided filenames
- avoid recursive operations unless constrained, previewed, and tested

### 9. Avoid unsafe shell and process usage

Prefer native APIs over shell commands.

If process execution is required:

- use argument arrays, not interpolated command strings
- use allowlists
- validate every argument
- set timeouts
- avoid inherited secrets in the environment
- capture and sanitize output
- report non-zero exits honestly
- never run destructive commands outside the intended repo/workspace

### 10. Use strict origins and secure transport

Production external API URLs must use secure transport.

Do not use wildcard CORS for authenticated APIs.

For webviews, browser apps, embedded previews, and local dashboards:

- restrict allowed origins
- keep content security policy tight
- avoid loading remote app UI unless explicitly required
- do not disable security settings to fix local dev annoyances
- keep dev-only origins out of production config

### 11. Set secure cookies and sessions

For cookie/session-based apps:

- use HTTP-only cookies where possible
- require secure cookies in production
- use same-site protections
- keep access tokens short-lived
- rotate or invalidate refresh/session tokens where applicable
- support logout/session invalidation
- avoid storing sensitive tokens in easy-to-extract client storage unless the architecture explicitly
  accepts that risk

### 12. Protect state-changing requests

Protect mutations against cross-site or cross-origin abuse when cookies or ambient credentials are
used.

Use a suitable mix of:

- CSRF tokens
- same-site cookies
- origin/referer validation
- explicit authorization checks
- idempotency keys for sensitive repeated operations

### 13. Rate-limit abuse-prone surfaces

Rate-limit or throttle:

- login and signup
- password/account recovery
- contact and quote forms
- file uploads/imports
- expensive reports
- scraping or crawl endpoints
- AI/API proxy calls
- webhook receivers
- device polling or sync loops

Add bot/spam protections when public forms are involved.

### 14. Do not leak sensitive errors or logs

Production errors should be boring.

Do not expose:

- stack traces
- query text
- internal file paths
- tokens or secrets
- full user objects
- request headers or cookies
- OAuth payloads
- private local paths
- device identifiers
- raw external API payloads unless sanitized

Logs should include useful IDs and event names, not secrets.

### 15. Keep dependencies boring and justified

Before adding a dependency:

1. Check whether platform/native code or existing utilities solve it.
2. Prefer small, maintained packages.
3. Avoid abandoned packages and giant utility libraries.
4. Do not add packages for trivial helpers.
5. Document why the dependency is worth it.

Run the repo’s existing audit command when available. Report vulnerabilities honestly. Do not hide
them with version pin roulette.

### 16. Keep build and CI safe

Do not:

- disable type checks to pass CI
- weaken lint rules without explanation
- commit generated secrets
- print environment variables in CI
- add broad repository token permissions
- run install scripts from random URLs
- add network-dependent build steps without documenting them
- make tests order-dependent or machine-specific
- change deployment targets without explicit intent

CI should default to least privilege. Raise permissions only when required.

### 17. Preserve security headers and browser protections

For web-facing output, preserve or add appropriate protections:

- content security policy
- content type sniffing protection
- referrer policy
- permissions policy
- strict transport protections for production HTTPS
- frame/embed restrictions where relevant

Do not loosen these protections unless the exact runtime need is known and documented.

### 18. Guard privacy by default

Collect and persist the least data possible.

Do not log or persist personal data, precise location, tokens, analytics payloads, private file paths,
machine identifiers, hardware identifiers, serial numbers, or device identifiers unless necessary.

If identifiers or private paths are necessary, document why, minimize retention, and keep them local
where practical.

### 19. Make dangerous actions reversible or confirmed

For destructive actions:

- require explicit confirmation
- show what will be affected
- prefer archive/backup/quarantine over delete
- provide a dry run where practical
- avoid recursive deletes unless constrained and tested
- never “clean up” outside the intended workspace

This applies especially to local apps, repo tools, generated assets, and anything with filesystem
access. Humanity keeps inventing delete buttons, so apparently we need rules.

### 20. Verify after security-sensitive changes

Run the strongest available checks without inventing tooling.

Use the repo’s documented commands for:

- format
- lint
- type/static checks
- tests
- build
- dependency audit
- secret scan, if available
- targeted validation/auth/path/destructive-action tests

If checks cannot run, state exactly why. Do not claim success without verification.

## Agentic coding failure modes to prevent

These are common problems with repo-aware AI agents, coding copilots, and multi-step patch tools.

### 1. Starting duplicate dev servers

Before starting a dev/build/preview server:

1. Check whether one is already running.
2. Reuse the existing server when possible.
3. Check the expected port before starting a new process.
4. Do not kill user processes without explicit reason.
5. If a port is occupied, identify what owns it and report the choice made.

Do not leave background servers running accidentally.

### 2. Losing the current repo state

Before edits and before committing:

- run the repo status command
- inspect the current diff
- identify unrelated dirty files
- avoid overwriting user work
- stage only intended files

If the repo is dirty, treat it as shared workspace, not your personal sandbox. Stunning concept.

### 3. Stalled or partial prompt execution

If execution stalls after a phase:

1. Re-read the current repo state.
2. Continue from the last verified change.
3. Do not duplicate already-applied work.
4. Do not invent completion.
5. Report what is done, pending, and blocked.

### 4. Claiming success without verification

Do not say fixed, done, working, safe, complete, or secure unless checks were run or limitations are
clearly stated.

Required reporting:

- commands run
- result
- files changed
- known manual checks still needed

### 5. Over-redesigning instead of patching

Do not rewrite unrelated UI, config, routing, build setup, project structure, or architecture to solve
a narrow bug.

For visual cleanup, change one surface at a time and commit after each coherent element.

### 6. Ignoring reference material

When screenshots, design tokens, existing previews, docs, tickets, logs, or previous analysis exist,
inspect them before patching.

Do not produce a loose “interpretation” when the task asks for alignment.

### 7. Fighting established project conventions

Before adding new patterns:

- inspect nearby files
- follow naming conventions
- follow existing component/module boundaries
- use existing helpers
- use existing error and logging patterns
- avoid new folders unless they improve structure

Do not add a second way to do the same thing unless replacing the first intentionally.

### 8. Breaking runtime boundaries

Do not use runtime-only APIs during build, prerender, static generation, test discovery, or module
initialization.

Gate runtime-only behavior behind the correct lifecycle/runtime checks.

### 9. Mismatching UI and backend/native contracts

For every API, command, task, or bridge touched, verify:

- exposed name
- caller name
- argument names
- return shape
- error shape
- permissions/capabilities
- loading and failure states

Do not change one side and assume the other will emotionally understand. It will not.

### 10. Hiding UI visually but leaving it interactive

Hidden windows, dialogs, menus, flyouts, overlays, trays, panels, and splash screens must be inert.

Hidden means:

- no pointer events
- no focus capture
- no keyboard trap
- no hover resurrection
- no invisible click targets
- no ghost rectangles
- no sound/alert caused by invisible controls

### 11. Fixing symptoms instead of lifecycle/state bugs

Do not mask lifecycle bugs with opacity, z-index, timeout, or “just re-render it” hacks.

Fix the state transition, teardown, readiness gate, event cleanup, cancellation path, or ownership
model.

### 12. Pretending OS/hardware behavior was validated

If a feature depends on OS APIs, shell behavior, display behavior, graphics mode, tray behavior,
fullscreen mode, drivers, permissions, or real hardware, say what was code-verified and what still
requires real-device validation.

Do not claim hardware/OS behavior works because a mock or compile passed.

### 13. Interfering with fullscreen or high-priority foreground apps

Desktop utilities should avoid interfering with exclusive fullscreen apps, games, protected windows,
presentation mode, capture-sensitive windows, or high-priority foreground tasks unless the feature
explicitly supports that mode.

Pause, degrade, or defer overlays, polling, sync, and visual effects when needed.

### 14. Creating polling or watcher problems

For polling, watchers, observers, and subscriptions:

- clean them up
- debounce/throttle where needed
- pause in background when appropriate
- avoid tight loops
- avoid duplicate subscriptions
- avoid unbounded logs
- handle errors without crashing the loop

### 15. Creating migration or generated-file drift

When touching generated files, migrations, snapshots, lockfiles, build output, or assets:

- identify whether they are source or generated artifacts
- update them only when required
- keep generated churn out of feature commits when possible
- explain why lockfiles changed
- avoid committing local machine paths

### 16. Installing tools without permission or need

Do not globally install tools, mutate system config, change user shell profiles, install certificates,
or alter machine-level settings unless explicitly requested.

Prefer project-local commands and documented setup.

### 17. Papering over broken tests

Do not delete, skip, weaken, or rewrite tests just to make a run green.

If a test is obsolete, explain why and replace it with a better assertion.

### 18. Swallowing errors

Do not catch errors and ignore them.

Handle errors with:

- useful user-facing messages
- sanitized logs
- preserved cause where safe
- recovery path or clear failure state

### 19. Making broad formatting churn

Do not reformat entire files or directories unless formatting is the task.

Keep diffs reviewable. Separate formatting commits from functional commits when practical.

### 20. Forgetting the final handoff

At the end of work, report:

1. Security risks found.
2. Files changed.
3. Guards added or preserved.
4. Verification run.
5. Remaining risks or manual checks.
6. Suggested commit message, if code changed.

Do not claim something is secure because it compiles. Compilers are not priests.
