# Integration — one canonical skill, verified entrypoints

The original package was built without installation. Follow Ryan's existing AI-Wiki helper/registry
workflow. Do not create a second canonical root or install a framework to install a skill.
Sources [S2]–[S6] in NOTICE distinguish user conventions from documented host behavior.

## 1. Discover before applying

Inspect `Skills`, `Copy-In` / custom `Copy -In`, and the local function catalog. Check
the current skill registry and existing `wayfinder` / `wayfinder-spice` definitions.
Use a narrow query; do not load the entire vault. The own-repo source suggests
`04_skills/agent-skills/skills/wayfinder-spice` as a plausible relative home, but that
is a proposed path, not permission to create it or evidence it is the active registry.

Inspect the supplied files and run package validation when Python is already available.
A current registry/import helper takes precedence over manual copies, symlinks, or
provider settings changes. Produce the proposed canonical destination and narrow
entrypoints before applying; apply only within the actual installation request.
Keep candidate versus active promotion explicit. Do not overwrite an existing skill.

## 2. Native host surfaces

| Host | Documented surface | This package's approach |
| --- | --- | --- |
| Codex | User/repo `.agents/skills/<name>/SKILL.md` | Core plus `agents/openai.yaml`; explicit `$wayfinder-spice`. |
| OpenCode | `.opencode/skills`, `.agents/skills`, `.claude/skills`, and documented user equivalents | Core includes slash/manual metadata; explicit selection where the installed version supports it. |
| Claude Code | `.claude/skills/<name>/SKILL.md`, including the active personal/profile context | Thin wrapper with `disable-model-invocation: true`; explicit `/wayfinder-spice`. |
| T3 Code | The selected provider/harness, not an assumed universal skill folder | Verify the provider's discovery or have it explicitly read the canonical skill. |
| Hermes / dot / other agents | Inspect actual available skill/file tools | Explicit canonical-file read when no verified native registration exists. |

Documentation describes capability, not this computer's installed state. Verify exact
paths and features in the active profile, particularly alternate Claudex roots. Do not
infer a working route from a picker item, a directory, or a config entry alone.

Do not register the same name in every folder: OpenCode can discover `.agents` and
`.claude` surfaces too, so multiple wrappers can collide. Choose the smallest existing
entrypoint strategy that each client can actually load, and verify which copy is active.
A `.ai/skills` pointer is a repo convention, not universal automatic skill discovery.
Do not grant whole-vault filesystem access to make one skill readable.

## 3. Thin Claude wrapper

A ready-to-fill example is [the wrapper template](../assets/claude-wrapper.template.md).
It is intentionally not another discoverable `SKILL.md` inside this archive. Resolve
its canonical path through the established installer/registry before use. Keep support
file references relative to the canonical skill, not the wrapper's location.

The portable core uses standard Agent Skills fields. Claude's native manual-invocation
flag lives in this adapter; Codex's policy lives in `agents/openai.yaml`; OpenCode's
controls live in string-valued metadata. Neither these flags nor prose replaces sandbox
permissions, and old clients may not implement the documented behavior. Use explicit
file loading instead of claiming an unsupported flag guarantees manual-only operation.
No `allowed-tools`, model override, auth mutation, or paid fallback is introduced.

## 4. Acceptance before promotion

Use a harmless read-only prompt: “Load WAYFINDER / Spice. Report the loaded version,
canonical path, and default write boundary. Do not create files, run probes, or use a tracker.”
Verify the agent actually read the intended file. Then run the small-task, read-only,
existing-changes, and blocked-decision behavioral cases. Record the host/version,
canonical content hash, selected route without credentials, and observed result.

Only call installation successful after discovery and invocation work in that host.
Only call behavioral acceptance passed after observed runs satisfy the rubric.
If several hosts are requested, report each independently; do not generalize one pass.

## Integration handoff prompt

```text
Integrate the attached wayfinder-spice package through my existing AI Wiki workflow.
Read README.md and NOTICE.md, verify its manifest, inspect current Skills/Copy-In
help and the active skill registry, and check for existing WAYFINDER definitions.
Keep one canonical copy in the verified AI Wiki skill root, with narrow existing-style
pointers/adapters for the harnesses I actually use. Preserve the upstream wayfinder.
Do not invent helper signatures, duplicate universal content across repos, modify
provider/auth/default-model settings, or import anything into Svelte Lab.
Apply only the skill installation changes authorized by this request. Smoke-test
explicit loading and the read-only/small-task boundaries; report exact paths and
per-host results. Leave untested clients and promotion status explicitly unverified.
```

## Local owned-repository integration

For the established Wiki checkout, `scripts/aiwiki-link-codex.mjs --name
wayfinder-spice` previews a selective junction and `--apply` installs it without
changing other skills. The Wiki registry rebuild is a separate generated-index
step. A 2026-10-16 local receipt reported Codex discovery and explicit T3/Codex
file loading; these historical results do not establish current discovery in any
host or provider. A successful file read is not proof of a composer picker chip.
