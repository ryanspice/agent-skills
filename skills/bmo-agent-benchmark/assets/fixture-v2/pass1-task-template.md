# BMO benchmark cell {{CELL_ID}} — implementation pass

Repository root: `{{TARGET_ROOT}}`
Harness: `{{HARNESS}}`
Model route: `{{MODEL}}`
Condition: `{{CONDITION}}`
Bounded tool-turn target: `{{MAX_TURNS}}`

Work only inside the repository root above. The implementation specification,
typed BMO source brief and execution condition are authoritative.

This is a producing pass. Inspect the minimum existing scaffold and edit the
repository immediately. You have file tools only. Do not invoke a terminal,
browser, web/MCP tool, package manager, process, child agent or another model.
Do not modify files outside the repository root.

Required handoff:

- leave a coherent, root-wired SvelteKit artifact on disk;
- preserve the visible `REFERENCE DEMO — NOT BMO` boundary;
- never create credential inputs, authentication, tracking or BMO API calls;
- return a compact list of changed files, static self-audit findings and exact
  remaining gaps;
- do not claim deterministic checks ran; the outer conductor runs them after
  this pass.
