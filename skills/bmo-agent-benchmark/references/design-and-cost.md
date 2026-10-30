# BMO benchmark v2 design and cost notes

## Question

Can DeepSeek V4 Flash produce and continue the BMO SvelteKit implementation
without Pro, and when does a fresh Pro integration pass materially help?

The 16 cells separate:

- Hermes from ClaudeSeek;
- standard from action-first scheduling;
- Flash-to-Flash from Flash-to-Pro;
- producing pass from fresh artifact-only integration pass.

This is a harness-plus-model experiment, not a pure model benchmark. Hermes and
ClaudeSeek have different runtime prompts and tool mediation. Name that
limitation in every synthesis.

## Why the compact packet

The raw page captures contain megabytes of duplicated CSS, framework state,
analytics, consent tooling and navigation payload. The delegate receives:

- a concise implementation specification;
- a typed 30 KB source brief;
- one common visible reasoning kernel;
- one execution condition;
- one cell task;
- bounded deterministic evidence for pass 2.

The source validator ensures 7 campaigns, 36 navigator cards and 3 help cards
survive compaction.

## Cost model

The matrix stores the official rates used when this fixture was prepared:

| Model | Cache-hit input | Cache-miss input | Output |
| --- | ---: | ---: | ---: |
| DeepSeek V4 Flash | $0.0028/M | $0.14/M | $0.28/M |
| DeepSeek V4 Pro | $0.003625/M | $0.435/M | $0.87/M |

Refresh official rates before a future paid run. A changed price does not
silently change an approved plan; generate a new plan.

The prior 16-call matrix was estimated at about $0.273 from its token ledger.
V2 expects roughly $0.30–$0.55 because it raises the bounded turn target to 10
and supplies stronger execution controls. The current plan template uses the
explicitly authorized account-delta stop of $2.25; each generated plan freezes
that amount and still requires its own exact hash and confirmation token.

`claude --max-budget-usd 5.00` is intentionally a loose, mispriced harness
ceiling. Claude Code can estimate cost as if the routed model were Anthropic,
so that value is not DeepSeek spend and must never be summed as billing.

R10 demonstrated the mismatch directly. M06 reached a Claude estimate of
`$5.015697` and returned `error_max_budget_usd`, while the DeepSeek account
delta for that cell was `$0.12`. Treat this sentinel as a harness control, not
an invoice or provider-spend assertion.

The full r10 campaign moved the account balance from `$4.91` to `$4.45`
(`$0.46`). Rounded per-cell receipts summed to `$0.43`; the `$0.03` difference
is the expected consequence of cent-level snapshots and resume boundaries.
Future reports must show both values and use the larger start-to-finish delta
when no concurrent account use is plausible.

## Chunking

The benchmark already uses a two-pass chunk:

1. establish a complete root-wired implementation;
2. give a fresh worker the artifact plus exact conductor evidence.

Within an action-first pass, use postconditions rather than one giant plan:

1. spine;
2. content breadth;
3. remaining sections;
4. behavior and accessibility;
5. static audit.

Do not split so finely that every call must rediscover the repository.

## Iteration parity

The task packet requests ten turns. Hermes enforces that through
`--max-turns 10`; Claude Code currently exposes no equivalent CLI switch. R10
ClaudeSeek cells used 18–132 turns. This means:

- the campaign is a valid operational harness comparison;
- it is not a turn-matched pure model comparison;
- ClaudeSeek success cannot be credited without naming its larger iteration
  allowance;
- a future parity run needs Claude Agent SDK `maxTurns` support or an external
  stream controller that terminates at a counted iteration boundary.

Do not emulate parity by lowering the mispriced Claude dollar sentinel. Dollar
estimates and tool iterations are different controls.

## Interpretation

Score each cell on:

- first edit and root-route wiring;
- semantic coverage;
- Svelte check/build;
- prohibited behavior;
- accessibility and interactions;
- visual fidelity at target widths;
- completion-claim accuracy;
- runtime and cost.

A Flash run that needs deterministic conductor repair is not autonomous
success. A Pro integration pass that only polishes a complete Flash result is a
different finding from a Pro pass that rescues missing architecture.

R10 found no Pro repair advantage: all three check-clean cells were Flash
repair passes, and no Pro pass cleared `svelte-check`. Action-first was the
strongest intervention: all four action-first pass-2 artifacts built, versus
one of four standard pass-2 artifacts.
