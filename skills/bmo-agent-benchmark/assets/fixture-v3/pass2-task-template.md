# BMO benchmark cell {{CELL_ID}} — fresh artifact integration pass

Repository root: `{{TARGET_ROOT}}`
Harness: `{{HARNESS}}`
Model route: `{{MODEL}}`
Condition: `{{CONDITION}}`
Externally bounded work cycles: `{{MAX_TURNS}}`

This is a fresh session. Treat the repository and the conductor evidence below
as the complete handoff. Do not ask for, infer or search for the first pass
transcript or final answer.

The repository is an isolated repair clone of the exact frozen source artifact
named in the evidence. Do not inspect another benchmark workspace.

## Conductor evidence

{{CHECK_EVIDENCE}}

Inspect the current root-wired artifact, then edit it to repair the highest
impact failures and complete missing acceptance rows. You have file tools only.
Do not invoke a terminal, browser, web/MCP tool, package manager, process,
child agent or another model. Do not modify files outside the repository root.

Required handoff:

- keep the implementation coherent and reachable from `+page.svelte`;
- preserve the visible demo and no-credentials safety boundary;
- address deterministic errors before decorative polish;
- return a compact list of changed files, evidence addressed, static
  self-audit findings and exact remaining gaps;
- apply the Clarity and Coverage gates before returning;
- label claims as verified, unverified, assumed, failed or deferred;
- do not claim a post-edit check/build passed; the conductor reruns it after
  this pass.
