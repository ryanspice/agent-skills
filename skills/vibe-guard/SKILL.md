---
name: vibe-guard
description: Use this skill when building, auditing, or refactoring AI-generated code.
---

# Vibe Guard Skill

## Purpose

Security, privacy, build-safety, and dependency guardrails for AI-generated code.

This skill is always active. Use it for every project where an AI agent edits code, configs, scripts, CI, docs, build tooling, or deployment files.

## Operating mode

Act as a security-minded senior engineer. Prevent common AI-generated mistakes before they reach production.

Before changing code:

1. Identify the runtime: browser, SvelteKit server, Tauri webview, Rust backend, Node script, PHP app, worker, CI, static site, or desktop process.
2. Identify trust boundaries: user input, filesystem, shell commands, env vars, APIs, database, cookies, OAuth, Tauri IPC, plugins, external URLs, and generated files.
3. Make the smallest safe patch.
4. Do not introduce broad rewrites, new dependencies, weakened config, or disabled checks to “make it work.”
5. Report risk honestly. Passing a build is not the same thing as being safe.

When security and convenience conflict, security wins unless the user explicitly accepts the risk.

## Critical rules

### 1. Never hardcode secrets

Never commit API keys, OAuth secrets, tokens, passwords, private URLs with credentials, connection strings, certificates, or private keys.

Use env vars, secret stores, `.env.example`, documented placeholders, or local-only ignored config.

```ts
const apiKey = process.env.API_KEY;
```

### 2. Validate input at every boundary

Validate HTTP bodies, query params, form actions, route params, Tauri command args, file paths, uploaded files, JSON config, CLI args, and external API payloads.

Prefer schemas where useful. Do not add heavy validation libraries for tiny checks.

### 3. Encode output and avoid injection

Never trust user-controlled strings in HTML, SQL, shell commands, file paths, redirects, logs, CSS, JavaScript, Markdown rendered as HTML, or generated config.

Avoid Svelte `{@html ...}`. If it is required, sanitize first and explain why.

### 4. Protect auth and authorization

Authentication proves identity. Authorization controls access. Do both.

Every private route, API endpoint, server action, backend command, admin screen, and native operation must check authorization near the action being performed.

Do not rely on hidden buttons, disabled UI, route names, or client-side checks for security.

### 5. Keep tenant and user boundaries intact

For multi-user or multi-tenant data:

- filter by authenticated user or tenant
- enforce database policies where available
- never fetch broad data and filter only on the client
- never trust user-provided tenant IDs

### 6. Use safe database access

No string-concatenated SQL. Use parameterized queries, query builders, or ORM-safe APIs.

```ts
await db.query('select * from users where id = $1', [id]);
```

### 7. Lock down Tauri IPC and capabilities

For Tauri apps:

- expose the smallest possible command surface
- validate every command argument in Rust
- return typed errors without leaking internals
- keep capabilities and permissions narrow
- avoid broad filesystem, shell, dialog, HTTP, and process permissions
- never let frontend input directly choose arbitrary commands, paths, URLs, or executables

Danger signs:

- shell execution from user input
- unrestricted file writes
- recursive deletes
- broad plugin permissions
- command names exposed without state checks
- frontend-only protection for native operations

### 8. Treat filesystem paths as hostile

Normalize and constrain paths before reading or writing.

Rules:

- reject path traversal
- restrict writes to approved app/data directories
- avoid unsafe symlink behavior for destructive actions
- generate safe filenames server-side
- validate extensions and MIME types for uploads
- never write using raw user-provided names

### 9. Avoid unsafe shell/process usage

Prefer native APIs over shell commands.

If process execution is required:

- use argument arrays, not interpolated strings
- use allowlists
- validate every argument
- set timeouts
- avoid inherited secrets in env
- capture and sanitize output

### 10. Use HTTPS and strict origins

Production external API URLs must use HTTPS.

Do not use wildcard CORS for authenticated APIs.

For Tauri/webviews:

- avoid loading remote app UI unless explicitly required
- restrict allowed origins
- keep CSP tight
- do not disable security settings to fix local dev annoyances

### 11. Set secure cookies and sessions

For web/server apps:

- `httpOnly`
- `secure` in production
- `sameSite=lax` or `sameSite=strict`
- short-lived access tokens
- refresh rotation where applicable
- logout/session invalidation

Do not store sensitive tokens in `localStorage` unless the architecture explicitly accepts that risk.

### 12. Protect state-changing requests

For cookie-authenticated web apps, protect mutations against CSRF.

Use SvelteKit form actions with appropriate checks, CSRF tokens where needed, same-site cookies, and origin/referer validation for sensitive actions.

### 13. Rate-limit abuse-prone endpoints

Rate-limit login, signup, password reset, contact forms, quote forms, file uploads, expensive reports, AI/API proxy calls, and public scraping endpoints.

Add bot/spam protections when public forms are involved.

### 14. Do not leak sensitive errors or logs

Production errors should be boring.

Do not expose stack traces, SQL, file paths, tokens, full user objects, request headers, cookies, OAuth payloads, or private device paths.

Logs should include useful IDs, not secrets.

### 15. Keep dependencies boring and justified

Before adding a dependency:

1. Check if platform/native code can solve it.
2. Prefer small, maintained packages.
3. Avoid abandoned packages and giant utility libraries.
4. Do not add packages for trivial helpers.

Run the repo’s audit command when available: `npm audit`, `pnpm audit`, `bun audit`, or `cargo audit`.

Report vulnerabilities honestly. Do not hide them with version pin roulette.

### 16. Keep build and CI safe

Do not:

- disable type checks to pass CI
- weaken lint rules without explanation
- commit generated secrets
- print env vars in CI
- add broad GitHub token permissions
- run install scripts from random URLs
- use `curl | sh` unless explicitly reviewed

GitHub Actions should default to least privilege:

```yaml
permissions:
  contents: read
```

Raise permissions only when required.

### 17. Preserve CSP and security headers

For web apps, use appropriate headers:

- `Content-Security-Policy`
- `X-Content-Type-Options`
- `Referrer-Policy`
- `Permissions-Policy`
- HSTS for HTTPS production

For SvelteKit/Tauri, do not loosen CSP unless the exact runtime need is known.

### 18. Guard privacy by default

Collect the least data possible.

Do not log or persist personal data, precise location, tokens, full analytics payloads, private file paths, hardware IDs, monitor serials, or device identifiers unless necessary.

If device IDs or paths are necessary, document why and keep them local where possible.

### 19. Make dangerous actions reversible or confirmed

For destructive actions:

- require explicit confirmation
- show what will be affected
- prefer archive/backup over delete
- avoid recursive operations unless constrained and tested

This applies especially to desktop apps with filesystem access. Humanity keeps inventing delete buttons, so apparently we need rules.

### 20. Verify after security-sensitive changes

Run the strongest available checks without inventing tooling.

Frontend:

- `bun run check`
- `bun run lint`
- `bun run build`
- `npm run check`
- `npm run lint`
- `npm run build`

Rust:

- `cargo fmt --check`
- `cargo clippy --all-targets --all-features`
- `cargo test`

Other:

- dependency audit
- secret scan if available
- targeted tests for validation, auth, IPC, path handling, and destructive actions

If checks cannot run, state exactly why.

## Known AI-agent failure modes to prevent

These are common problems seen with Trae, Codex, GPT-generated patches, and repo-aware agents.

### 1. Stalled or partial prompt execution

If the agent stalls after a phase, continue from the last verified state. Re-read `git status`, inspect the current diff, and avoid duplicating work.

### 2. Claiming success without verification

Do not say fixed, done, working, or secure unless checks were run or the limitation is clearly stated.

Required reporting:

- command run
- result
- files changed
- known manual checks still needed

### 3. Over-redesigning instead of patching

Do not rewrite unrelated UI, config, routes, or architecture to solve a narrow bug.

For visual cleanup, change one surface at a time and commit after each coherent element.

### 4. Ignoring reference images or established design tokens

When reference screenshots, design tokens, or component previews exist, inspect them first. Do not produce an “interpretation” when the user asked for alignment.

### 5. Breaking Svelte 5 by using Svelte 4 habits

Avoid stale patterns in new code:

- broad `$:` reactive blocks
- untyped props
- unnecessary stores for local state
- `createEventDispatcher` for new component APIs
- accessing browser APIs during SSR/build

Use runes, typed props, callback props, and client-only guards where needed.

### 6. Breaking SvelteKit/Tauri runtime boundaries

Do not call Tauri APIs during build, prerender, SSR, or module initialization.

Gate runtime-only code with browser checks and client effects.

### 7. Mismatching frontend and Rust command contracts

For every Tauri command touched, verify:

- Rust command name
- frontend `invoke(...)` name
- argument names
- return type
- error shape
- capability/permission requirements

### 8. Hiding UI visually but leaving it interactive

Hidden windows, flyouts, menus, tray UI, splash screens, and overlays must be inert.

Hidden means:

- no pointer events
- no focus capture
- no hover resurrection
- no ghost rectangles
- no desktop ding caused by invisible controls

### 9. Fixing symptoms instead of lifecycle/state bugs

Do not mask lifecycle bugs with opacity or `z-index` hacks. Fix the state transition, teardown, event cleanup, or readiness gate.

### 10. Making Windows-specific behavior fake-cross-platform

If a feature relies on Windows APIs, say so and isolate it behind platform modules or feature gates.

Do not pretend shell, taskbar, monitor, HDR, tray, or exclusive fullscreen behavior can be validated without the actual OS/hardware path.

### 11. Forgetting fullscreen/game safety

For desktop utilities, avoid interfering with exclusive fullscreen games or protected/high-priority foreground apps unless the feature explicitly supports that mode.

Pause or degrade polling/overlays/sync behavior when needed.

### 12. Committing dirty unrelated files

Before committing:

- run `git status --short`
- inspect staged diff
- run `git diff --check`
- stage only intended files

Do not mix whitespace cleanup, formatting churn, generated assets, and feature changes unless requested.

## Output format

When reporting work, include:

1. Security risks found.
2. Files changed.
3. Guards added or preserved.
4. Verification run.
5. Remaining risks or manual checks.

Do not claim something is secure because it compiles. Compilers are not priests.
