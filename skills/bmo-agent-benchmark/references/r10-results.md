# BMO benchmark v2 r10 empirical results

The 2026-07-26 r10 campaign attempted all 16 planned cells. Fifteen had a
successful harness exit. M06 completed a real DeepSeek Pro editing session but
ClaudeSeek returned `error_max_budget_usd` after its Anthropic-style estimate
reached `$5.015697`; the measured DeepSeek balance delta was `$0.12`. The cell
was preserved and not retried.

## Headline measurements

- Check passes: `3/16`
- Build passes: `6/16`
- Strict artifact-contract passes: `0/16`
- Rounded receipt sum: `$0.43`
- End-to-end account balance: `$4.91 -> $4.45` (`$0.46`)
- Strongest result: F08, ClaudeSeek Flash action-first producing pass followed
  by a fresh Flash action-first repair pass

All three check-clean results were Flash repair cells: F04, F06 and F08. No Pro
repair cell passed `svelte-check`. All four action-first pass-2 artifacts built,
versus one of four standard pass-2 artifacts.

## Interpretation

Flash is viable for non-trivial implementation when paired with:

1. a compact authoritative source brief;
2. action-first postconditions;
3. a fresh artifact-only repair pass;
4. deterministic outer check/build evidence.

The campaign does not support Pro as the default second implementation worker.
Use Pro as an orchestrator, critic or narrow reviewer until a controlled repair
benchmark shows an advantage.

Harness comparisons are confounded by iteration control. Hermes enforced ten
turns. Claude Code has no equivalent CLI cap and used 18–132 turns. Future
turn-matched tests require an SDK or stream controller with a real iteration
limit.

## Browser finding

F08 was the strongest practical artifact. It returned HTTP 200 at desktop and
mobile widths, switched tabs, opened its mobile drawer, closed on Escape,
started keyboard navigation at the skip link, had no password input or
horizontal overflow, and rendered the complete page hierarchy. Its remaining
issues were placeholder hash links and live BMO assets that failed under
HTTP/2.

F04 passed check/build but failed production preview with
`ReferenceError: window is not defined`; build success alone is not a runtime
verdict.

## Reusable controls learned

- Set both `ANTHROPIC_AUTH_TOKEN` and `ANTHROPIC_API_KEY` for DeepSeek through
  Claude Code `--bare`.
- Send child CLI arguments through one JSON value across `pwsh -File`.
- Preserve stderr when a child closes stdin early.
- Count completed and failed terminal-cell deltas across resume boundaries.
- Never retry a paid terminal cell. Continue only independent later cells and
  record the failed cell as its result.
- A provider-free retry requires zero account delta, zero model stream and an
  unchanged target, with the failed attempt archived first.
- Keep conservative account-baseline cost separate from rounded receipt sums.

Heavy evidence remains machine-local under:

`<DEV_ROOT>\deepseek.workspace\bmo-agent-benchmark\bmo16-v2-20260726-r10`
