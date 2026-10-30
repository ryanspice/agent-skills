# Immutable v1 baseline

Date: 2026-07-26

Original compact inputs:

- implementation prompt SHA-256:
  `9F4BD692CE910D554862C1DC9E4C7CF4575E99804E52F2B44ADA06EB51EB0406`
- source brief SHA-256:
  `75DB940953D5856B761D43D9675450F4A2A187189D4C7A5EBE033099395337C3`

The original 16-cell results remain under:

`<DEV_ROOT>\deepseek.workspace\bmo-flash-test`

Key artifacts:

- `MATRIX.md`
- `MATRIX-RESULTS.json`
- `SYNTHESIZED-RESULTS.md`
- `COST-AUDIT.md`

Summary:

- best Flash-only sequence: F01 to F02, which reached a clean build;
- strongest raw mixed sequence: M03 to M04, Flash to Pro;
- all ClaudeSeek v1 cells were constrained by a `$1` Claude harness budget
  that did not represent real DeepSeek billing;
- estimated provider cost for the scored 16 calls was
  `$0.2728615148`;
- the wider 21-call diagnostic ledger was `$0.3253341140`;
- token ledger: 589,157 cache-miss input, 5,630,080 cache-hit input and
  293,616 output tokens.

V2 does not overwrite or rescore v1. It adds provenance, explicit source
validation, a common visible reasoning kernel, 10-turn bounded cells,
postcondition gates, corrected Claude budget interpretation, hidden child
process isolation and plan-hash approval.
