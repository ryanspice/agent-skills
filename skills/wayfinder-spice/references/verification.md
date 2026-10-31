# Verification and engineering judgment

## Discover commands, then use them

Read manifests, package scripts, CI workflows, and local helper docs. Derive the
working directory, package manager, runtime, and test commands from them. Existing
workspace scripts win. Do not write `npm test` merely because the repo is JavaScript.
Do not install dependencies or execute scripts solely because their names sound safe.

Record only the commands actually run. A verification receipt states:

```text
Target and revision:
Working directory:
Command or observation:
Environment/version when relevant:
Result and exit code:
Evidence location:
Limitations / not run:
```

Prefer a regression reproduction before a fix; distinguish it from an unrelated
existing failure. Use targeted checks first, then the relevant wider suite before
claiming readiness. Review the changed files against preserved baseline changes.
Never invent test totals or report a planned check as passed.

## Select relevant acceptance, not a universal checklist

| Work | Decisive evidence to consider |
| --- | --- |
| Frontend change | Intended interaction, keyboard/focus, error/empty/loading states, responsive behavior, console errors. |
| Public Svelte/client site | Rendered content and crawlable links, metadata/canonical intent, hydration boundaries, form behavior, appropriate consent, no server secrets in bundles. |
| WebOS/TV | Remote keys and focus, suspend/resume, playback lifecycle, overlays, navigation transitions, installed-device observation. |
| Game/prototype | Actual loop and input, lifecycle/reset, frame stability on the target, asset provenance, clear prototype/production distinction. |
| Azure/CI/deployment | Correct target and environment, build artifact identity, relevant hosted checks, rollback, separate deployment approval and live verification. |
| Android/.NET release | Separate component tests, produced installer/package identity, install/upgrade preservation, physical audio/network/device checks when applicable. |
| Agent/provider tooling | Exact configured route, auth mode without credentials, required tools/protocol, bounded canary, write limits, actual receipts. |

These are acceptance prompts, not claims about the current implementation. Use the
repo's established accessibility/security standards; verify current official guidance
when a precise requirement is material.

## Independent validation

Workers deliver evidence, not authority. A coordinator checks source references and
reruns decisive deterministic checks when feasible. High-impact changes deserve an
independent reviewer who examines the actual artifacts and does not simply restate
the author's conclusion. When no independent reviewer exists, label self-review.

Owner visual/device acceptance is not replaced by a second model. Conversely, do not
wait for subjective approval to read code, inspect logs, or resolve deterministic facts.

## Improvement loop

After a few real efforts, compare against the unmodified workflow on similar tasks:
Did it pick the right next decision, avoid rework, stay inside permissions, and produce
a usable handoff? Capture actual time/usage only when supplied by reliable telemetry.
Do not infer token spend from visible text or call an unmeasured route “cheaper.”

Run the relevant bundled behavioral cases before promoting changes; select cases
proportionate to the changed behavior and record untested scenarios explicitly. Keep a failing real-world
case as a new regression. Change the smallest rule that addresses the failure, rather
than appending an ever-growing global prompt. See [S7] in NOTICE for eval methodology.
