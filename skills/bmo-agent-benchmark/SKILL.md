---
name: bmo-agent-benchmark
description: Prepare, approve, run, score, and package the bounded 16-cell BMO SvelteKit implementation benchmark across Hermes and ClaudeSeek with DeepSeek Flash and Pro. Use when reproducing the BMO agent comparison, investigating Flash narration without edits, validating its compact fixture, or creating a safe future benchmark packet without visible terminal windows.
provenance_origin: "original"
provenance_source_path: "04_skills/agent-skills/skills/bmo-agent-benchmark/SKILL.md"
provenance_credit: "Ryan Spice-Finnie"
provenance_ingested_as: "ryanspice/agent-skills owned skill"
provenance_note: "Registered from the existing local working tree; earlier origins were not independently verified."
---

# BMO Agent Benchmark

Run this as a hash-bound experiment, not as an open-ended multi-agent prompt.
The canonical packet lives in `assets/fixture-v3`; heavy repositories, logs,
snapshots and model streams stay on the machine-local `B:` runtime.

Before any paid call, read:

`<USER_HOME>\.claude\FUGU-CODEX.md`

## Workflow

1. Validate the compact fixture.
2. Create a fresh machine-local plan and eight isolated initial repositories.
   The eight repair repositories do not exist yet.
3. Run the no-cost dry run.
   It also proves pairwise-identical repair cloning, clone isolation and
   file-delta/handoff matching without creating paid repair workspaces.
4. Show the owner the current plan identity, 16 cells, four waves, routes,
   caps, egress, expected cost, account stop and stop conditions.
5. Obtain explicit paid authority for that displayed plan and stop. The owner
   may approve in natural language, for example “orchestrate this complete
   16-cell plan under the displayed `$2.25` hard stop.” The conductor records
   the exact hash and token internally; do not make the owner relay them again.
6. If the owner delegates whole-run orchestration, record a standing approval
   receipt. It may cover infrastructure-only plan rebindings, provider-free
   launch repair and continuation past a preserved terminal cell. It does not
   authorize a higher account stop, different matrix, new model/provider,
   expanded egress or retry of a paid terminal cell.
7. Run and supervise the plan. Freeze F01, F03, F05 and F07, then create
   separate Flash and Pro repair clones from each exact frozen artifact.
   Preserve every attempt and terminal receipt.
8. Score deterministic checks, production-preview browser evidence, file
   deltas, handoff coverage and account-balance deltas.
9. Synthesize matched Flash-versus-Pro repairs plus harness and condition
   effects.
10. Package the skill for reuse.

## Commands

Set the canonical skill path once:

```powershell
$Benchmark = '<AI_WIKI_ROOT>\04_skills\agent-skills\skills\bmo-agent-benchmark\scripts\Invoke-BmoAgentBenchmarkV3.ps1'
```

Validate:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File $Benchmark -Action Validate -Json
```

Plan into a fresh local root:

```powershell
$RunRoot = '<DEV_ROOT>\deepseek.workspace\bmo-agent-benchmark\<fresh-run-id>'
pwsh -NoProfile -ExecutionPolicy Bypass -File $Benchmark `
  -Action Plan `
  -WorkspaceRoot $RunRoot `
  -Json
```

Dry-run all 16 cells without a provider call:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File $Benchmark `
  -Action DryRun `
  -WorkspaceRoot $RunRoot `
  -Json
```

Only after exact owner approval:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File $Benchmark `
  -Action Run `
  -WorkspaceRoot $RunRoot `
  -ApprovedPlanSha256 '<exact full SHA-256>' `
  -ConfirmToken '<exact RUN-BMO16 token>' `
  -Json
```

The conductor supplies the approved SHA and token from the recorded receipt.
The owner should not have to copy them from one message into the next.

Resume an interrupted run:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File $Benchmark `
  -Action Run `
  -WorkspaceRoot $RunRoot `
  -ApprovedPlanSha256 '<internally retained full SHA-256>' `
  -ConfirmToken '<internally retained RUN-BMO16 token>' `
  -Resume `
  -Json
```

Continue independent cells after preserving a paid terminal cell:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File $Benchmark `
  -Action Run `
  -WorkspaceRoot $RunRoot `
  -ApprovedPlanSha256 '<internally retained full SHA-256>' `
  -ConfirmToken '<internally retained RUN-BMO16 token>' `
  -Resume `
  -ContinueAfterFailedCell `
  -Json
```

`-ContinueAfterFailedCell` never retries or rewrites the failed cell. It skips
its preserved receipt, includes its account delta in the original campaign
ceiling, writes zero-call `blocked-dependency` receipts for dependent repairs,
and continues independent cells. Scoring reports attempted, failed, blocked
and not-dispatched cells separately.

Score:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File $Benchmark `
  -Action Score `
  -WorkspaceRoot $RunRoot `
  -Json
```

Never construct a raw `hermes -p ... chat` command. The runner dispatches
Hermes through `Invoke-FuguLane.ps1` and ClaudeSeek through its canonical
launchers.

## Fixed 16-cell design

Read `assets/fixture-v3/matrix-v3.json` for the machine-readable matrix.

- Wave 1: four Flash initial builds that become frozen repair sources:
  F01, F03, F05 and F07.
- Wave 2: four independent Flash initial-build replicates:
  F02, F04, F06 and F08.
- Wave 3: four Flash repairs of isolated frozen-source clones:
  F09, F10, F11 and F12.
- Wave 4: four Pro repairs of separate identical clones:
  P13, P14, P15 and P16.

Each wave contains at most four remote calls. Calls run serially. Every cell
has a unique repository root, a 12-cycle cap, a 1,200-second hard limit and
zero API retries. Repair cells receive an exact frozen artifact clone and
bounded deterministic evidence, never an earlier transcript or final prose.
F09/P13, F10/P14, F11/P15 and F12/P16 start from pairwise identical trees.

## Doctrine and “say, do not do” control

The Hermes `worker-flash` route normally carries a research-only Fable packet
whose visible contract forbids edits. That is valid for research but
contradicts a producing coding cell and can provoke narration instead of work.

For this benchmark the runner explicitly uses `-NoSoul -NoFable` on Hermes.
Both harnesses instead receive `visible-reasoning-kernel.md`, which preserves
the observable evidence, action, postcondition and claim discipline without
requesting hidden chain-of-thought or forbidding edits.

Every cell also receives `policy-spiceflow-v0.4-bmo.md`: a frozen,
benchmark-only projection containing the Neanderthal packet, Clarity,
Coverage and Evidence gates. Divergent Focus and the common SpiceFlow
immediate-edit rule are excluded. Only action-first condition cells receive
the experiment's explicit edit-scheduling treatment.

The action-first condition additionally requires:

- one batched inspection at most;
- first edit by the second tool cycle;
- a root-wired integration spine;
- ordered postcondition gates;
- no completion claim while required content is absent or unwired.

Do not remove these controls merely to make a weak run look better.

## Safety invariants

- All worker processes are windowless. ClaudeSeek is launched with
  `UseShellExecute=false`, `CreateNoWindow=true`, hidden window style and
  redirected streams. Hermes runs in its own hidden PowerShell adapter process.
- Do not close, restart or modify user-owned terminals or agent sessions.
- Delegate tools are file-only. Child delegation, background agents, browser,
  web, terminal, process and MCP tools are unavailable.
- No raw BMO DOM, CSS, Next.js payload, analytics or consent payload enters a
  delegate packet.
- No credentials are logged. Balance and model-list reads store only numeric
  account state and model identifiers.
- The only writable repositories are the 16 isolated descendants declared by
  the plan. Only eight initial roots exist at approval time. Heavy run state
  never enters OneDrive.
- Emit `plan-receipt.json` only after all eight initial roots, their approved
  `node_modules` junctions and all eight initial prompts exist and validate.
  An interrupted preparation may leave `plan.json`, but it must not leave an
  approvable receipt.
- Create each repair root only after its source cell has a completed receipt
  and immutable snapshot hash. Record a clone receipt before model contact.
  The Flash and Pro repair roots for a source must match that same hash.
- Before a dry run or paid run, revalidate every prepared target and prompt.
  Unstarted targets must still match the approved starter tree. This check
  occurs before provider model, balance or completion calls.
- No automatic paid retry or model, provider, route, task, target, matrix or
  budget substitution is allowed after provider contact. An
  infrastructure-only binding repair requires recorded standing authority,
  immutable before/after evidence and a fresh zero-call dry run.
- A provider-free launch attempt may be resumed only when evidence proves all
  of the following: zero account delta, zero model stream, unchanged target,
  archived failed receipt/log/snapshot, repaired bound transport and a fresh
  zero-call dry run. A paid or ambiguous attempt is never retried.
- A paid failed cell remains the benchmark result. Under recorded standing
  authority, the conductor may continue later independent cells with
  `-ContinueAfterFailedCell`; it may not retry that cell.
- Write a one-attempt receipt before every model launch. If an attempt receipt
  exists without a terminal cell receipt, provider contact is ambiguous and
  the cell is permanently ineligible for automatic retry.
- Native `pwsh -File` callers must use the adapter's hashed
  `-ContextManifestFile` boundary for multiple context files. Do not pass
  several values to `-ContextFile`; PowerShell can rebind later paths to
  unrelated named parameters.
- The assembled Hermes prompt must travel through the retained, SHA-256-bound
  UTF-8 query file. Never place a large benchmark packet on the Hermes process
  command line.
- Claude child arguments must travel through the launcher's single
  `-ClaudeArgsJson` value. A leading child flag such as `-p` can otherwise be
  rebound as a PowerShell script parameter.
- Claude Code `--bare` must receive `ANTHROPIC_API_KEY`. The DeepSeek launchers
  set both `ANTHROPIC_API_KEY` and `ANTHROPIC_AUTH_TOKEN` from the isolated
  DeepSeek key and restore the caller environment afterward.
- Stop on plan drift, launcher/profile drift, model identity drift, auth/quota
  failure, timeout, visible-console regression, target escape, user
  cancellation or the campaign account-delta threshold.
- The Claude `--max-budget-usd` value is a mispriced harness guard, not claimed
  DeepSeek billing. Use DeepSeek account deltas and current official rates for
  cost reporting.
- Resumes must count positive account deltas from every existing terminal cell,
  including failed cells, against the original campaign stop.
- Preserve both cost views in the run receipt: the sum of per-cell balance
  deltas and the conservative campaign-level account delta. The latter protects
  against cent-level provider balance rounding across resumed invocations.

## Fixture gate

`scripts/Test-BmoBenchmarkPacketV3.ps1` must pass before planning and again before
execution. It rejects:

- a non-v3 matrix or malformed v2 compact source brief;
- PowerShell `@{...}` object strings;
- anything other than 7 campaigns, 6 tabs, 6 cards per tab, 36 cards total,
  3 help cards, 16 cells and 4 waves;
- anything other than 16 isolated targets, eight initial builds, four frozen
  sources and eight repair clones;
- unbalanced harness/model/condition cells or broken frozen-source pairs;
- a cycle cap other than 12, a 1,200-second runtime cap or a non-zero retry
  allowance;
- missing Clarity/Coverage/Evidence policy, Divergent Focus exclusion or source
  archive hash;
- missing starter files;
- packet size without adapter headroom.

The BMO artifact gate normalizes only typography-equivalent semantic literals:
zero-width characters, non-breaking spaces and incidental spacing around
apostrophes, `®`, `™` and `†`. It does not relax the required 70-literal set or
convert real omissions into passes. This behavior is an explicit BMO-only
opt-in to the shared artifact contract.

The browser gate fails local runtime errors, page errors, unnamed controls,
failed local requests, missing responsive behavior and failed tab interaction.
External BMO asset failures are recorded under `externalResourceErrors` but do
not fail an otherwise working local artifact. Image `alt` text and
`aria-labelledby` contribute to accessible-name checks.

The source brief is authoritative for the benchmark even if the public page
changes later. Refreshing the public fixture creates a new fixture version and
new baseline; never silently mutate historical results.

## Evidence and scoring

The outer conductor runs hidden `npm run check`, `npm run build` and a
headless production-preview probe. It snapshots the artifact before checks,
applies the semantic/safety contract, compares actual file deltas with literal
handoff paths, captures mobile/tablet/desktop screenshots and structural
accessibility signals, and records the DeepSeek balance before and after every
cell.

Account-delta cost can include unrelated concurrent DeepSeek use. If concurrent
use is plausible, label it and additionally calculate a token-ledger estimate
from the official rates in the matrix.

Report both the conservative start-to-finish account balance delta and the sum
of rounded per-cell receipts. Cent-level balance snapshots can undercount when
summed across many cells or resume boundaries.

The matrix requests 12 cycles, but only Hermes currently enforces that limit.
Claude Code has no equivalent CLI flag; earlier ClaudeSeek cells used 18–132
turns. Until ClaudeSeek is routed through an SDK or stream controller with a
real iteration cap, describe harness comparisons as operational rather than
turn-matched.

After all cells:

1. run `-Action Score`;
2. compare Flash and Pro repairs of the same frozen source within harness and
   condition;
3. compare standard against action-first;
4. compare Hermes against ClaudeSeek while naming system-prompt differences;
5. inspect the browser evidence from every buildable cell and visually review
   the strongest artifact from each meaningful comparison;
6. report build, semantics, interaction, visual fidelity, claim accuracy,
   runtime and cost separately.

## MCP route

Use the existing read-only Workbench command MCP:

1. `workbench_command_search` for `bmo benchmark`;
2. `workbench_command_read` for `bmo-agent-benchmark`;
3. follow its fixed commands and skill source.

The MCP record provides discovery and safe guidance only. It does not expose an
arbitrary command/path executor or bypass the plan-hash approval.

## References

- `references/design-and-cost.md` — matrix interpretation, costs and comparison
  cautions.
- `references/prior-baseline.md` — immutable v1 baseline summary.
- `references/r10-results.md` — historical completed v2 campaign measurements and
  operational lessons.
- `references/workbench-command-registry-record.json` — portable MCP command
  registry record.
- `assets/fixture-v3/` — authoritative v3 packet.
- `assets/fixture-v2/` — preserved historical v2 packet.
- `scripts/` — v3 validator, runner, browser probe, artifact contract and
  package builder.
