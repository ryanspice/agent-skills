# WAYFINDER / Spice

A custom decision-mapping skill for Ryan Spice-Finnie's Windows-first, repo-native,
multi-harness workflow. Adapted from Matt Pocock's WAYFINDER; attribution is in
[NOTICE.md](NOTICE.md). Version **1.0.1**, prepared **2026-10-16**.

**Reviewed local adaptation; per-host installation and behavioral acceptance are recorded separately.** Per-harness behavior retains separate local acceptance. The original 1.0.0 was
prepared without local Windows changes. Version 1.0.1 was integrated at the owner's
request; the AI Wiki installation receipt records exact observed results.

## Use it now

Give an agent this folder or read access to its canonical location, then say:

```text
Read wayfinder-spice/SKILL.md and use it to chart this effort: <goal>.
Inspect the current repo and existing intent first. Stay in planning mode.
Give me the decision map and the next decision worth resolving.
```

After verified native registration, Codex supports `$wayfinder-spice`; a Claude wrapper
supports `/wayfinder-spice`; current OpenCode documentation describes explicit slash
selection through the bundled metadata. These are agent-chat inputs, not PowerShell
commands. T3/Hermes/dot use their verified provider/skill integration or explicit reading.
See [integration](references/harness-integration.md) for host-specific limits and sources.

```text
$wayfinder-spice chart this game feature; inspect INTENT.md and preserve scope.
$wayfinder-spice resume the existing map; resolve the next eligible decision only.
$wayfinder-spice status; read-only, no tracker or repo changes.
$wayfinder-spice handoff the accepted decisions to the implementation agent.
$wayfinder-spice reset this stalled investigation without reinstalling the toolchain.
```

## What changed from upstream

| Upstream shape | Personal adaptation |
| --- | --- |
| Decision map with gradual discovery | Retained; no speculative backlog pretending to be a map. |
| Frequent mandatory grilling | Evidence-first defaults; real human choices stay human. |
| Mandatory companion skill calls | Optional available helpers; standalone workflow works. |
| Research branches pushed automatically | No implicit branch, push, PR, publish, or deployment. |
| Assignee used as claim | One coordinator plus session ownership; assignment is not a lock. |
| Ticket sized around a 100K-token session | A bounded question with decisive evidence and a stop condition. |
| Tracker-centric operation | Existing tracker first; existing local planning convention second. |
| Generic setup | AI-Wiki canonical roots, PowerShell helpers, .thoughts and intent boundaries. |

The core is deliberately small; profile, state protocol, verification, examples, and
installation details load only when needed. Simple known fixes bypass WAYFINDER.

## What is included

- `SKILL.md`: the portable operating skill.
- `references/`: Ryan's profile, decision protocol, verification, and harness integration.
- `assets/`: map, decision, worker, handoff, and thin Claude-wrapper templates.
- `agents/openai.yaml`: explicit invocation policy and display metadata for Codex.
- `scripts/`: optional read-only context probe and dependency-free package validator.
- `tests/` and `evals/`: validator tests plus behavioral evaluation cases.
- `VERIFICATION.md`, `MANIFEST.sha256`, and `.thoughts/CONTINUATION.md`: receipts and next steps.

## Optional local checks

Inspect scripts before running. From this extracted skill directory, with an existing
Python 3.10+ installation (use the installed launcher; do not install Python just for this):

```powershell
py -3 -B .\scripts\verify_package.py
py -3 -B -m unittest discover -s .\tests -v
```

The validator checks this package's restricted frontmatter, required assets, safe links,
manual-invocation settings, eval structure, and manifest hashes. It does not launch an
LLM or claim to be a complete YAML/Agent Skills implementation. Tests use temporary
copies, not your repositories. Hashes detect accidental differences, not publisher identity.

Optional context discovery in the existing PowerShell session:

```powershell
& .\scripts\Get-WayfinderContext.ps1 -RepoRoot '<PROJECT_ROOT>'
```

Replace the placeholder with an existing project directory.
The probe emits JSON to the console and does not invoke discovered helpers, install
anything, edit a repo, read auth configs, or make network requests. It reports known
manifest/framework signals and available command names without dumping script values.
Hardware queries require `-IncludeHardware`. Local paths are hidden unless explicitly
requested with `-IncludeLocalPaths`; review all output before sharing. Its Windows
runtime status is documented separately in [VERIFICATION.md](VERIFICATION.md).

## Install through the existing workflow

Keep this folder in staging until the canonical skill registry and helper signatures
are verified. `<BROWSER_STAGING_ROOT>` is the established download/staging area, not the
canonical home. Follow [integration](references/harness-integration.md); it includes a
handoff prompt for dot/local Codex and a thin-wrapper strategy. Do not spray full copies
into `.agents`, `.claude`, `.opencode`, every repo, and AI Wiki.

No auto-installer is bundled: the current local helper/registry behavior was not executed
here, and inventing a competing installer would violate the intended workflow.

## Definition of success

It selects the next consequential decision, avoids unnecessary questions and rework,
preserves existing state and permissions, and leaves a handoff another agent can verify.
Use [behavioral evaluations](evals/README.md) to test those claims rather than assume
this version is better because it contains more instructions.
