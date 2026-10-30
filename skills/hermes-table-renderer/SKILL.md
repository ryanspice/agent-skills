---
name: hermes-table-renderer
description: Defines the structured HermesTable contract and rendering workflow for responsive terminal, Markdown, JSON, CSV, and future interactive table output. Use when presenting comparisons, audits, file lists, task states, test results, rankings, diagnostics, model reviews, or dense tabular data where hand-aligned text would be brittle.
version: 0.1.0
type: universal-agent-skill
status: active
risk: low
platforms: [windows, hermes, claude-code, codex, ai-wiki, terminal]
tags: [tables, terminal-output, structured-output, cli, markdown, json, csv, diagnostics]
provenance_origin: "original"
provenance_source_path: "04_skills/agent-skills/skills/hermes-table-renderer/SKILL.md"
provenance_credit: "Ryan Spice-Finnie"
provenance_ingested_as: "ryanspice/agent-skills owned skill"
provenance_note: "Registered from the existing local working tree; earlier origins were not independently verified."
---

# Hermes Table Renderer

Use this skill when structured information needs to be shown as a table. Do not manually space-align terminal tables from prose. Produce a machine-readable `HermesTable` model first, then render it for the current surface.

## Trigger

Use for:

- structured comparisons
- audits and inventories
- task/status lists
- file or diff reviews
- test/diagnostic summaries
- model/skill rankings
- handoff checklists
- any table that must survive narrow terminals, logs, Codex/Claude handoffs, or copy/paste

## Core Rule

Agents emit table data, not fixed-width art.

Flow:

```text
Agent reasoning
  -> HermesTable JSON contract
  -> renderer chooses terminal / markdown / json / csv / interactive
  -> final readable table
```

If no renderer exists yet, still create the `HermesTable` object and use the simplest deterministic local renderer available. Never rely on hand-counted spaces as the source of truth.

## HermesTable Contract

```ts
export type HermesTable = {
  title?: string;
  summary?: string;
  columns: HermesTableColumn[];
  rows: Record<string, unknown>[];
  defaultSort?: {
    column: string;
    direction: "asc" | "desc";
  };
  actions?: HermesTableAction[];
  notes?: string[];
};

export type HermesTableColumn = {
  key: string;
  label: string;
  minWidth?: number;
  maxWidth?: number;
  priority?: 1 | 2 | 3 | 4 | 5;
  align?: "left" | "right" | "center";
  wrap?: boolean;
  truncate?: boolean;
  hiddenBelow?: number;
};

export type HermesTableAction = {
  label: string;
  command: string;
  rowKey?: string;
};
```

## Column Rules

- `priority: 1` = essential; preserve on tiny terminals.
- `priority: 2` = important context.
- `priority: 3` = normal detail.
- `priority: 4` = useful when width allows.
- `priority: 5` = nice-to-have; hide first.
- Use `wrap: true` for prose.
- Use `truncate: true` for paths, hashes, IDs, URLs, and commands.
- Keep row values concise. Put verbose details in `notes`, `actions`, or expandable row details.

## Responsive Modes

Use terminal width as the main signal:

```ts
const width = process.stdout.columns || 100;
const mode = width < 80 ? "compact" : width < 130 ? "normal" : "wide";
```

Rules:

| Width | Behavior |
|---|---|
| `<80` | Show priority 1-2 columns. Collapse detail into row expansion text or notes. |
| `80-129` | Show priority 1-3 columns. Wrap descriptions. |
| `130+` | Show most columns. Keep IDs, paths, scores, and notes visible when useful. |
| non-TTY | Prefer Markdown or JSON. Avoid ANSI styling. |

Disable color when `NO_COLOR`, `TERM=dumb`, `CI`, or non-TTY is detected.


## Premium Hermes Rendering Rules

A responsive renderer must not always choose a grid. At 80 columns, a four-column comparison table still looks like ASCII spreadsheet output and forces the eye to read wall-to-wall. Use layout modes by information density:

| Mode | Width | Shape | Use for |
|---|---:|---|---|
| `brief` | any | one-line summary + status counts | first glance / chat answer |
| `cards` | `<100` | stacked row cards with status chips | comparisons with prose |
| `matrix` | `100-149` | 2-3 essential columns + hidden detail notes | audits and status lists |
| `wide-table` | `150+` | full table with evidence/source columns | terminals with room |
| `interactive` | explicit | sortable/filterable browser | many rows or decisions |

For premium Hermes/Claude-Code-like output:

- Put the answer in a header panel: title, one-line verdict, source/verification badges.
- Use status chips instead of plain status words: `PARTIAL`, `MISSING`, `ARCHIVED`, `PASS`, `FAIL`.
- Use semantic color only: green=done/pass, yellow=partial/warn, red=fail/blocker, blue=info, dim=secondary evidence.
- At narrow widths, render each row as a card:
  - line 1: status chip + feature name
  - line 2: `now:` concise current state
  - line 3: `next:` pulse recommendation
  - optional line 4: dim source/evidence
- Avoid heavy full-width grids unless the terminal is wide. Borders are not premium if every cell is still a wall of wrapped prose.
- Prefer whitespace, bullets, section dividers, and badges over dense box drawing.
- Preserve a raw `HermesTable` JSON artifact beside any pretty render so Codex, CI, logs, and handoffs stay machine-readable.
- If `process.stdout.isTTY` is false, do not emit ANSI by default; use Markdown or JSON.

Current Hermes note: this environment has Python `rich` available but does not currently have Node packages such as `cli-table3`, `ink`, `wrap-ansi`, or `string-width` installed. Until the Node renderer is added, use Rich or a deterministic local renderer for premium previews.

## Output Modes

Static table is the default. Interactive mode is explicit.

Recommended CLI behavior:

```text
--table        responsive terminal table
--markdown     Markdown fallback
--json         raw HermesTable contract
--csv          exportable rows
--no-color     force plain output
--interactive  Ink/Textual-style browser when implemented
```

Interactive controls, when available:

| Key | Action |
|---|---|
| Up / Down | Move row |
| Left / Right | Move column |
| / | Filter |
| s | Sort selected column |
| Enter | Expand row |
| c | Copy selected row as JSON |
| m | Copy table as Markdown |
| q | Quit |

## Renderer Checklist

The renderer should:

- Detect terminal width.
- Hide low-priority columns first on narrow displays.
- Wrap long text without breaking alignment.
- Truncate paths/IDs intelligently.
- Disable color in dumb/CI/non-TTY contexts.
- Export Markdown, JSON, and CSV.
- Preserve the machine-readable contract for handoffs.
- Support row expansion for details.
- Never require the model to manually align spaces.

## Recommended Implementation Stack

First pass for Hermes CLI:

```text
cli-table3
string-width
strip-ansi
wrap-ansi
```

Later interactive mode:

```text
ink
react
```

Suggested file layout:

```text
src/hermes/table/
  table.types.ts
  render-table.ts
  render-markdown-table.ts
  render-json-table.ts
  terminal-width.ts
  column-layout.ts

src/hermes/table/interactive/
  TableApp.tsx
  useTableNavigation.ts
  useTableFilter.ts
```

Python fallback, if the command is Python-first:

```text
rich
t textual/textual DataTable when interactive mode matters
```

## Agent Workflow

1. Decide whether the information is tabular.
2. Define a `HermesTable` object with columns and rows.
3. Assign priorities before rendering.
4. Pick mode from user request or environment.
5. Render through a deterministic table renderer.
6. Include notes for hidden columns, caveats, or verification details.

## Minimal Example

```json
{
  "title": "Verification Summary",
  "summary": "Build passed; full check failed on unrelated diagnostics.",
  "columns": [
    { "key": "command", "label": "Command", "priority": 1, "truncate": true },
    { "key": "status", "label": "Status", "priority": 1 },
    { "key": "evidence", "label": "Evidence", "priority": 2, "wrap": true }
  ],
  "rows": [
    { "command": "bun run build", "status": "pass", "evidence": "SvelteKit build completed." },
    { "command": "bun run check", "status": "fail", "evidence": "Existing svelte-check errors outside changed files." }
  ],
  "notes": ["Do not mark the whole repo clean unless the canonical check passes."]
}
```


## Rich Response Rendering Boundary

This skill must not encourage agents to emit raw ANSI escape codes. Colors, panels, hyperlinks, status chips, row expansion, and Markdown rendering are renderer responsibilities.

Preferred pipeline:

```text
assistant text / HermesTable artifact
  -> Hermes renderer sanitizes raw content
  -> renderer detects TTY, width, color support, TUI/classic mode
  -> renderer applies styles/cards/tables/links
  -> raw transcript remains plain and machine-readable
```

Rules:

- Do not put raw `\x1b` / ANSI / OSC8 sequences in normal assistant responses.
- Use semantic Markdown and structured artifacts (`HermesTable`) as renderer input.
- Let Hermes style known statuses such as `PASS`, `FAIL`, `BLOCKED`, `MISSING`, `PARTIAL`, and `ARCHIVED` deterministically.
- Treat OSC8 hyperlinks as a renderer opt-in with plain path/URL fallback.
- Strip or escape control characters from user, model, and tool text before rendering.
- Use Hermes TUI (`hermes --tui`) for richer current Markdown rendering when available; classic CLI should stay scriptable and log-safe.

## Safety

- Do not hide failing status columns in compact mode.
- Do not drop warnings/errors to make a table prettier.
- Do not convert unknown values to confident labels.
- If the renderer is unavailable, say so and provide JSON/Markdown fallback.
