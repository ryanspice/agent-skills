# Ryan's working profile

Prepared 2026-10-16. These are established preferences and dated context, not a live
machine inventory. Current explicit instructions and inspected repo facts win.
Do not load unrelated personal, health, financial, or relationship history.

## Durable operating preferences

Ryan works at principal/staff front-end and platform scope while still implementing,
debugging, documenting, testing, and explaining tradeoffs to clients and leadership.
Optimize for useful delivery and maintainability, not ticket volume or agent count.
Use concise, direct communication, targeted changes, small modules, explicit boundary
types, minimal dependencies, conventional commits when authorized, and short PR
verification notes. Code/artifacts first for implementation; decisions first for planning.

Respect an existing implementation before proposing a new abstraction, dependency,
framework, package manager, directory tree, or orchestration layer. Reuse beats
rewriting without evidence. Client-facing work must retain accessibility, performance,
SEO behavior where applicable, and a credible acceptance path.

## Windows and canonical roots

Distribution uses placeholders. Resolve `<AI_WIKI_ROOT>` through the current Wiki
registry or the canonical directory above `04_skills`, `<USERPROFILE>` from the
host environment, and runtime/staging roots through the fleet entry point or local
installation receipt. Do not create literal placeholder directories. The optional
probe accepts `-AiWikiRoot`, `-RuntimeRoot`, and `-BrowserStagingRoot`; absent values
are unknown (`null`), not evidence that a root is missing.

| Context | Established path or rule |
| --- | --- |
| Host | Windows 11; PowerShell-first. Current hardware/available RAM is unverified. |
| Downloads/staging | `<BROWSER_STAGING_ROOT>` |
| Curated knowledge/config | `<AI_WIKI_ROOT>` — preserve the `Obsidan` spelling. |
| Mutable local runtime | `<AI_WIKI_RUNTIME>` |
| Cross-workbench stable facts | `<AI_WIKI_ROOT>\00_Kit\workbench-memory\` |
| Svelte Lab and local tooling | Existing locations under AI Wiki `00_Kit`; discover actual subpaths. |
| Legacy runtime | Discover legacy locations locally; do not use them for new state. |

Keep caches, live databases, logs, temporary claims, and high-churn outputs out of
OneDrive. Keep project decision records with the project's chosen tracker; do not
promote every session into shared memory. A downloaded archive is staging, not an
installed skill or a trusted executable.

Historical CPU/GPU descriptions are not a hardware inventory. Discover RAM, CPU,
GPU, disk headroom, tool versions, and active loads only when a decision needs them.
Do not size a local model, VM, build fan-out, or GPU workload from old conversation
shorthand. Windows is the default environment; WSL, Hyper-V, containers, and Alpine
are not assumed to be installed or adopted. Existing VM/sandbox boundaries win.
Do not expose Windows credentials or broad writable host mounts to a worker VM.

## Existing helpers first

Known helper names include `Search`, `qsr`, `qsp`, `qsb`, `Skills`, `Copy-In`,
`Copy -In`, `Execute`, `Import-SvelteLabDemo`, and `Hermes`.
Discovery is safe; invocation semantics must come from current help or the local catalog.
`Copy` may be a stock alias, not Ryan's custom helper; do not guess.

```powershell
Get-Command Search,qsr,qsp,qsb,Skills,Copy-In,Copy,Execute,Import-SvelteLabDemo,Hermes -ErrorAction SilentlyContinue |
    Select-Object Name,CommandType,Source
Get-Help Skills -Full -ErrorAction SilentlyContinue
Get-Help Copy-In -Full -ErrorAction SilentlyContinue
```

Inspect one relevant catalog/help result, then use the established workflow. Do not
replace it with a new import/sync script. Do not print function bodies, environment
variables, auth stores, or full provider configs into a shareable report.

**Hard boundary:** never auto-import PixelBoats or rough WIP demo TARs into Svelte Lab.
Treat them as fragments/proposed material until cleaned and explicitly accepted.

## Repository adaptation

Follow actual naming, exports, folder shape, tests, and package manager. Read scripts
before running them: a task named `test`, `check`, or `build` is not automatically safe.
Do not alter lockfiles, generated files, vendored assets, or unrelated dirty changes
without a task-specific reason. Do not mass-format to make one edit convenient.

`AGENTS.md`/harness files carry rules; `INTENT.md` or existing `intent.md` carries
outcomes and constraints; decision tickets carry reasoning summaries and evidence;
`.thoughts` carries concise continuation state. Do not create competing copies or
case-only filename variants on Windows. These are project conventions, not claims
that every host automatically loads `INTENT.md` or `.ai/skills`.

For Svelte work supported by the repo, prefer SvelteKit 2 / Svelte 5 runes, event
attributes, semantic HTML, progressive enhancement, and minimal client state. Match
an in-progress migration rather than casually mixing patterns. Inspect actual SSR,
prerender, and CSR settings: do not apply a blanket `csr = false` to interactive UI,
a dashboard, a game, or an authenticated flow. Keep server-only code out of clients.

For React, Angular, Node, PHP, Python, Kotlin/Compose, .NET, Azure, and CI work, use
the detected project toolchain rather than transplanting Svelte defaults. Public sites
need appropriate rendered content, canonical metadata, structured data where justified,
and indexability checks; private app routes do not need marketing-page SEO rules.
Games and WebOS apps need input/lifecycle/device acceptance, not just a browser build.

## Harness and model boundaries

Treat this as an operating preference, not a guarantee every integration is working:

- T3 Code is the preferred coordination surface when available; dot may coordinate.
  Do not assume T3 implements a universal skill registry or all provider features.
- Preserve native Codex and its established authentication, native Claude Code,
  Claudex/CLIProxyAPI, Hermes, OpenCode, and other working routes. Do not homogenize
  their configuration or replace defaults as part of planning.
- Follow current owner instructions for third-party provider onboarding and route
  selection. No silent paid fallback, automatic account creation, quota resets, or
  migration of a primary workflow.
- Hermes should stay on its proven configured route unless a change is requested.
  Fugu/other worker tools are optional only when present and policy-approved.
- Read current authored Fugu policy and applicable harness/run-plan limits for
  routing, effort, recursion, and spend. Historical alias ceilings are not current
  policy. Preserve active route selection unless the task authorizes a change;
  catalog presence and prior success do not establish present entitlement.
- Compatibility state is not permission to enable a route excluded by current policy.
  Preserve existing state without reactivating it.

Recorded config locations, to check rather than dump:
`<USERPROFILE>\.config\opencode\opencode.jsonc`,
`<USERPROFILE>\.claude_claudex`, and
`<AI_WIKI_ROOT>\00_Kit\config\hermes\config.yaml`.
Availability, versions, quotas, and identity require current evidence.

Use utility routes for extraction/classification with explicit rubrics. Use an approved
coding route for bounded implementation and an appropriate independent review for
consequential decisions. A stronger prompt does not prove a smaller model equivalent:
compare task outcomes, errors, correction effort, and real usage when available.
No fixed model weights, context windows, quotas, or universal reasoning levels are
baked into this skill.

## Durable memory promotion

Read Workbench Memory's index and only relevant facts when cross-workbench context
matters. Verify project-specific statements against current source. Promote stable,
reusable facts only through the established review/memory process. Keep temporary
implementation state in the project. Retain superseded facts as archived records,
not silent deletion. Never persist secrets or speculative conclusions as facts.

Sources: the user's supplied profile and recent explicit workflow preferences;
Library operating instructions dated 2026-09-23; repository convention [S2] in NOTICE.
