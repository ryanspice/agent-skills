---
name: sveltekit-lab-route-authoring
description: "Create lab/debug/doc routes in SvelteKit projects, including SPA-style wiki pages with sidebar navigation, markdown rendering, and dark-theme styling. Covers the (lab) route group pattern and Svelte 5 runes conventions."
version: 1.0.0
platforms: [windows, linux, macos]
metadata:
  hermes:
    tags: [sveltekit, svelte5, lab-route, wiki, documentation]
    related_skills: [sveltekit-blog-article-authoring, sketch]
---

# SvelteKit Lab Route Authoring

## Use When

- Creating a new lab/debug/prototype route in a SvelteKit project (e.g., `src/routes/(lab)/lab/<name>/+page.svelte`)
- Building a wiki-style page with sidebar navigation and multi-page content
- Adding a documentation/lore/reference route that renders markdown as styled HTML
- Creating any SPA-style page within a SvelteKit route (client-side nav via `$state`)

## Core Pattern

### Route Structure

Lab routes typically live under a route group like `(lab)` to keep them isolated from production routes:

```
src/routes/(lab)/lab/<name>/
  └── +page.svelte          ← single-page component
```

There is usually no `+layout.svelte` needed — the route group inherits from the root layout.

### SPA-Style Navigation

Use Svelte 5 `$state` for client-side page switching within a single route — no need for SvelteKit `goto()` or separate route files:

```svelte
<script lang="ts">
  let activePage = $state('overview');

  const pages = [
    { id: 'overview', label: 'Overview', icon: '🌊' },
    { id: 'details',  label: 'Details',  icon: '📋' },
  ];

  const content: Record<string, string> = {
    overview: `# Overview\n\nMarkdown content here.`,
    details: `# Details\n\nMore content.`,
  };
</script>

<nav>
  {#each pages as p}
    <button
      class="nav-link"
      class:active={activePage === p.id}
      onclick={() => activePage = p.id}
    >
      {p.label}
    </button>
  {/each}
</nav>

<main>
  {#each pages as p}
    <article class:visible={activePage === p.id}>
      {#each content[p.id].split('\n') as line}
        <!-- render line as heading / paragraph / list etc -->
      {/each}
    </article>
  {/each}
</main>
```

### Markdown Rendering (Component-Level) — Block Parser

Render markdown inline in Svelte without a library. **Do NOT use line-by-line iteration** — it breaks on multi-line code blocks, tables, and nested structures. Use a **block-based parser** that pre-processes the markdown string into typed blocks before rendering.

#### Block Parser Implementation

Add a `parseBlocks()` function in the `<script>` section that splits the markdown into an array of typed block objects:

```svelte
<script lang="ts">
  type Block =
    | { t: 'h1'; c: string }
    | { t: 'h2'; c: string }
    | { t: 'h3'; c: string }
    | { t: 'h4'; c: string }
    | { t: 'p'; c: string }
    | { t: 'li'; c: string }
    | { t: 'bq'; c: string }
    | { t: 'table'; rows: string[][] }
    | { t: 'code'; c: string }
    | { t: 'spacer' };

  function parseBlocks(md: string): Block[] {
    const lines = md.split('\n');
    const blocks: Block[] = [];
    let inCode = false;
    let codeBuf: string[] = [];

    function flushCode() {
      if (codeBuf.length > 0) {
        blocks.push({ t: 'code', c: codeBuf.join('\n') });
        codeBuf = [];
      }
    }

    for (const line of lines) {
      if (inCode) {
        if (line.startsWith('```')) { inCode = false; flushCode(); continue; }
        codeBuf.push(line);
        continue;
      }
      if (line.startsWith('```')) { flushCode(); inCode = true; codeBuf = []; continue; }

      if (line.startsWith('#### ')) { flushCode(); blocks.push({ t: 'h4', c: line.slice(5) }); continue; }
      if (line.startsWith('### '))  { flushCode(); blocks.push({ t: 'h3', c: line.slice(4) }); continue; }
      if (line.startsWith('## '))   { flushCode(); blocks.push({ t: 'h2', c: line.slice(3) }); continue; }
      if (line.startsWith('# '))    { flushCode(); blocks.push({ t: 'h1', c: line.slice(2) }); continue; }

      if (line.startsWith('|')) {
        if (line.match(/^\|[- ]/)) continue; // skip separator rows
        flushCode();
        const cells = line.split('|').filter((c: string) => c.trim()).map((c: string) => c.trim());
        if (cells.length > 0) {
          const last = blocks[blocks.length - 1];
          if (last?.t === 'table') last.rows.push(cells);
          else blocks.push({ t: 'table', rows: [cells] });
        }
        continue;
      }
      if (line.startsWith('> ')) { flushCode(); blocks.push({ t: 'bq', c: line.slice(2) }); continue; }
      if (line.startsWith('- ')) { flushCode(); blocks.push({ t: 'li', c: line.slice(2) }); continue; }
      if (line.trim() === '')    { flushCode(); blocks.push({ t: 'spacer' }); continue; }

      flushCode();
      blocks.push({ t: 'p', c: line });
    }
    flushCode();
    return blocks;
  }

  // Pre-compute all pages at module load time:
  const pageBlocks: Record<string, Block[]> = {};
  for (const p of flatPages) {
    pageBlocks[p.id] = parseBlocks(content[p.id] ?? '');
  }
</script>
```

Then render blocks in the template:

```svelte
{#each pageBlocks[p.id] as block}
  {#if block.t === 'h1'}
    <h1>{block.c}</h1>
  {:else if block.t === 'h2'}
    <h2>{block.c}</h2>
  {:else if block.t === 'p'}
    <p class="wiki-p">{@html html(block.c)}</p>
  {:else if block.t === 'code'}
    <pre class="wiki-code">{block.c}</pre>
  {:else if block.t === 'table'}
    <div class="wiki-table-wrap">
      {#each block.rows as row, ri}
        <div class="wiki-table-row" class:wiki-table-header={ri === 0}>
          {#each row as cell}
            <span class="wiki-table-cell">{@html html(cell)}</span>
          {/each}
        </div>
      {/each}
    </div>
  {:else if block.t === 'spacer'}
    <div class="wiki-spacer"></div>
  {/if}
{/each}
```

Where `html()` handles inline formatting:

```svelte
<script lang="ts">
  function html(s: string): string {
    return s
      .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
      .replace(/`(.+?)`/g, '<code>$1</code>');
  }
</script>
```

Key differences from line-by-line:
- **Code blocks** collect ALL lines between fences into a single `<pre>` — no scattered `<p>` tags mid-code
- **Tables** merge consecutive rows into one `{ t: 'table', rows: [...] }` block for consistent rendering
- **Pre-computation** happens once at module load (`pageBlocks`), not every render cycle
- **Separator rows** (`|--|--|`) are detected and skipped, not rendered as visible rows

## Styling Conventions

Lab routes use one of two theme palettes depending on the content's tone:

### Theme A: Dark/Gold (Default — Mechanical/Dev Pages)

Best for: debug tools, feature matrices, engine spikes, system dashboards.

```
--page-bg:     #0a0a0a
--sidebar-bg:  #050505
--content-bg:  #0a0a0a
--text:        #e0e0e0
--accent:      #f5a623  (gold)
--h1:          #fff
--h2:          #f5a623  (gold)
--muted:       #888 / #666
--border:      rgba(255, 255, 255, 0.08)
--code-bg:     #141414
--code-text:   #c0e0d0
--bullet:      #f5a623
--blockquote-border: #f5a623
```

### Theme B: Ocean/Teal (Warm — Lore, Narrative, World-Building Pages)

Best for: lore wikis, world-building docs, narrative content, setting bibles.

```
--page-bg:        #07131c   (deep navy)
--sidebar-bg:     linear-gradient(180deg, #091e2c, #06131f)
--content-bg:     #0b1a28 + radial gradients
--text:           #c8d8dc
--accent:         #00aba9   (metro teal)
--h1:             #d8f0ec   (sea-foam white)
--h2:             #00aba9   (teal)
--h3:             #9dd5d0   (muted teal)
--h4:             #7ab5b0
--muted:          #5a8888 / #4a7a7a
--border:         rgba(0, 171, 169, 0.12)
--code-bg:        rgba(0, 10, 18, 0.7)
--code-text:      #8dd0c0
--bullet:         #00aba9
--blockquote-bg:  rgba(0, 171, 169, 0.06)
--blockquote-border: #00aba9
```

The content area in Theme B uses three radial gradients for a submerged ocean feel:
```css
background:
  radial-gradient(ellipse 80% 40% at 50% 0%, rgba(0, 171, 169, 0.03) 0%, transparent 100%),
  radial-gradient(ellipse 60% 30% at 80% 100%, rgba(45, 137, 239, 0.04) 0%, transparent 100%),
  radial-gradient(ellipse 50% 25% at 20% 100%, rgba(0, 171, 169, 0.03) 0%, transparent 100%),
  #0b1a28;
```

**To switch themes**: change the accent color (gold → teal), the page backgrounds (black → navy), and the border/bullet/blockquote colors to match. The grid layout (`220px 1fr`), sidebar stickiness, and responsive breakpoint stay the same — only the color tokens change.

Layout: CSS Grid with `grid-template-columns: 220px 1fr` (sidebar + content). Sidebar is `position: sticky; height: 100dvh` for desktop, collapses to single-column on mobile.

### Section Grouping in Sidebar

For wikis with more than ~10 pages, group them under section labels in the sidebar:

```svelte
const sections = [
  {
    label: 'World',
    pages: [
      { id: 'overview', label: 'Overview', icon: '🌊' },
      { id: 'factions', label: 'Factions', icon: '⚓' },
    ]
  },
  {
    label: 'People',
    pages: [
      { id: 'characters', label: 'Characters', icon: '🧑' },
    ]
  },
];

const flatPages = sections.flatMap(s => s.pages);
```

Render sections with a `.section-label` div, then the nav buttons for that section:

```svelte
{#each sections as section}
  <div class="section-label">{section.label}</div>
  {#each section.pages as p}
    <button ...>{p.label}</button>
  {/each}
{/each}
```

Content panels still iterate `flatPages` (the flattened array), not the nested sections — so the `activePage === p.id` check works without nesting logic.

Style `.section-label` as uppercase, small (10px), letter-spaced, dim (#555) — clearly distinct from the nav links below.

On mobile (where sidebar becomes a horizontal tab bar), hide section labels with `display: none` so the tabs read as a flat list.

### Content Footer with Canon Legend

Add a footer below the content area showing data sources and a color-coded canon-level legend for lore wikis:

```svelte
<div class="content-footer">
  <span>Lore sourced from [source description].</span>
  <span>Canon levels:
    <span class="dot" style="background:#60a917"></span>Established
    <span class="dot" style="background:#f5a623"></span>Provisional
    <span class="dot" style="background:#1ba1e2"></span>Needs Name
    <span class="dot" style="background:#e51400"></span>Cleanup
    <span class="dot" style="background:#aa00ff"></span>Guardrail
  </span>
</div>
```

Style `.dot` as `inline-block; width: 8px; height: 8px; border-radius: 50%; margin: 0 4px 0 8px; vertical-align: middle;`.

### Page Count Badge

Add a badge in the sidebar header for context:

```svelte
<span class="wiki-badge">v0.1</span>
<!-- or -->
<span class="wiki-badge">{flatPages.length} pages</span>
```

Style as `font-size: 9px; text-transform: uppercase; padding: 1px 6px; border: 1px solid rgba(...); color: #666; margin-left: auto;`.

## Question Board / Decision-Board Mirror Routes

When a lab route mirrors project-owned questionnaires or decision prompts, keep the project route as a thin dashboard and deep-link launcher. Do **not** duplicate the canonical interactive editor/parser if it lives in another app.

- Store real question files in the project repo under `.questions/*.questions.md`.
- Use one file per questionnaire with frontmatter plus `## Qn — ...` blocks.
- Server-load lightweight summaries: title, phase, status, total question count, answered/signed-off count; for richer mirrors, also parse individual `## Q` blocks.
- Optional per-question fields `- priority:` and `- weight:` can drive a promoted Top 3 front-board queue. Use score roughly `priority × weight`, with dossier urgency/order as tie-breakers; default priority can fall back to question order and default weight to `1`.
- Client renders cards and deep-links to the canonical editor, e.g. `<boardBase>/question-board?tenant=pixelboats&file=<file>`.
- For GDD/wiki sync tasks, add cross-reference notes to the GDD and wiki open-questions page, but keep `.questions/` as the active answer workflow until decisions are signed off and promoted.
- Verification pitfall: raw `curl` can return only the SvelteKit app shell; use Playwright/headless browser to verify client-rendered dashboard content.

See `references/question-board-mirror-pattern.md` for a concrete project sync workflow and file format.

For a richer UI/UX pass, see `references/question-board-redesign-pattern.md`: decision-cockpit layout, summary stats, lane filters, selected-dossier panel, Playwright verification, and Svelte 5 `$state` pitfalls.

For turning a mirror into a local inline editor with save-back, weighted Top 3 behavior, virtualized queues, and scroll-safe panels, see `references/question-board-inline-editor-virtual-list-pattern.md`.

For PixelBoats-specific shell/header/dropdown/focus-modal lessons, including lab-mode scrolling, z-index popout fixes, quick-answer toggles, sureness sliders, and sparse touched-field writes, see `references/pixelboats-lab-shell-and-question-board-ux.md`.

For focus-modal question answering, Escape/backdrop dismissal, quick-answer toggle-off behavior, unset/snap-marked sureness sliders, and touched-field-only save payloads, see `references/question-board-focus-modal-and-touched-fields.md`. This is the preferred pattern when answering a question should take over the screen and untouched `.questions` fields must not be rewritten.

For a focused question-entry modal, quick answers from `.questions` type/hints, sureness/confidence sliders, and lab-shell route-surface scrolling fixes, see `references/question-board-focus-modal-choices-scroll-pattern.md`.

For lab routes embedded inside a fixed PixelBoats/GameShell chrome, see `references/lab-shell-scroll-and-focus-modal-pattern.md`: route-surface scroll containment, standardized lab scrollbars, Playwright scroll probes, and default full-screen focus modals for question editors.

## Dynamic Filesystem-Backed Pageso a local inline editor with save-back, weighted Top 3 behavior, virtualized queues, and scroll-safe panels, see `references/question-board-inline-editor-virtual-list-pattern.md`.

## Dynamic Filesystem-Backed Pages

For lore/documentation pages that should auto-discover content as new files are added (rather than hardcoding everything in a `Record<string, string>`), use a server-side load function that reads a directory tree and a content API endpoint.

### Route Structure

```
src/routes/(lab)/lab/<name>/
├── +page.server.ts          ← scans directory, returns file tree
├── content/+server.ts       ← serves individual file content
├── +page.svelte             ← renders sidebar + content viewer
└── RenderMarkdown.svelte    ← markdown rendering component
```

### Server Load Function (`+page.server.ts`)

```typescript
import fs from "node:fs";
import path from "node:path";

const CONTENT_ROOT = "S:/path/to/content/directory"; // Platform-specific path

type LoreNode = {
  name: string;
  path: string;
  type: "file" | "dir";
  children?: LoreNode[];
};

function scanDir(dirPath: string, relativeRoot: string): LoreNode[] {
  const entries: LoreNode[] = [];
  const items = fs.readdirSync(dirPath, { withFileTypes: true });
  for (const item of items) {
    const relPath = path.join(relativeRoot, item.name);
    if (item.isDirectory()) {
      const children = scanDir(path.join(dirPath, item.name), relPath);
      if (children.length > 0) {
        entries.push({ name: item.name, path: relPath, type: "dir", children });
      }
    } else if (item.name.endsWith(".md")) {
      entries.push({ name: item.name.replace(/\.md$/, ""), path: relPath, type: "file" });
    }
  }
  entries.sort((a, b) => {
    if (a.type !== b.type) return a.type === "dir" ? -1 : 1;
    return a.name.localeCompare(b.name);
  });
  return entries;
}

export async function load() {
  const tree = scanDir(CONTENT_ROOT, "");
  return { tree };
}
```

### Content API Endpoint (`content/+server.ts`)

```typescript
import fs from "node:fs";
import path from "node:path";

const CONTENT_ROOT = "S:/path/to/content/directory";

export async function GET({ url }) {
  const filePath = url.searchParams.get("file");
  if (!filePath) return new Response("Missing file parameter", { status: 400 });

  const resolved = path.resolve(CONTENT_ROOT, filePath);
  if (!resolved.startsWith(path.resolve(CONTENT_ROOT))) {
    return new Response("Invalid path", { status: 403 });
  }

  try {
    const content = fs.readFileSync(resolved, "utf-8");
    return new Response(content, {
      headers: { "Content-Type": "text/markdown; charset=utf-8" },
    });
  } catch {
    return new Response("File not found", { status: 404 });
  }
}
```

### Dynamic Sidebar Component Pattern

Key features of the client-side component:

```typescript
let collapsedDirs = $state<Set<string>>(new Set());

function toggleDir(dirPath: string) {
  if (collapsedDirs.has(dirPath)) {
    collapsedDirs.delete(dirPath);
  } else {
    collapsedDirs.add(dirPath);
  }
  collapsedDirs = new Set(collapsedDirs); // Trigger reactivity
}

async function openFile(filePath: string) {
  loading = true;
  const res = await fetch(`${base}/lab/lore/content?file=${encodeURIComponent(filePath)}`);
  markdownContent = await res.text();
  loading = false;
}
```

```svelte
<aside class="lore-sidebar">
  <nav>
    {#each data.tree as node}
      {#if node.type === "file"}
        <button onclick={() => openFile(node.path)}>{node.name}</button>
      {:else if node.type === "dir"}
        <button onclick={() => toggleDir(node.path)}>
          {collapsedDirs.has(node.path) ? "▶" : "▼"} {node.name}
        </button>
        {#if !collapsedDirs.has(node.path)}
          {#each node.children as child}
            <button class="child" onclick={() => openFile(child.path)}>{child.name}</button>
          {/each}
        {/if}
      {/if}
    {/each}
  </nav>
</aside>
```

### Markdown Renderer Component

Create a separate `RenderMarkdown.svelte` component that parses markdown into typed blocks (NOT line-by-line):

- Parse headings (h1-h4), paragraphs, code blocks, tables, lists, blockquotes, horizontal rules
- Handle Mermaid diagram blocks (display as labeled code blocks; browser-side Mermaid renderer can be added later)
- Render inline formatting: bold, italic, inline code, links
- Tables need proper `<thead>`/`<tbody>` rendering with header row detection

See the `sveltekit-blog-article-authoring` skill for the inline HTML renderer pattern. The key difference: the block-based parser pre-processes the markdown string into typed blocks before rendering, avoiding the fragility of line-by-line iteration.

### Key differences from hardcoded `Record<string, string>` approach

| Approach | Pros | Cons |
|---|---|---|
| Hardcoded (static pages array) | Simple, no server needed, fast | Must edit Svelte to add content; can't separate lore from code |
| Dynamic (filesystem-backed) | Auto-discovers new files; lore lives in separate markdown files; non-devs can add content | Requires server-side read access to filesystem; dev-only route |

Use the dynamic approach when:
- Lore content is authored by non-developers or by agents in seperate sessions
- The content directory is on a shared/long-lived path (e.g., an AI Wiki or Obsidian vault)
- You expect the content to grow beyond ~10 files
- Content updates should not require code edits

1. [ ] Create `src/routes/(lab)/lab/<name>/+page.svelte`
2. [ ] Add `<svelte:head>` with title and meta description
3. [ ] Wrap in `<section>` with a descriptive `aria-label`
4. [ ] Add navigation links back to other lab routes (optional, but friendly)
5. [ ] Test with `bun run check` (no new errors)
6. [ ] Test with `bun run build` (compiles cleanly)

## Additional PixelBoats Lab UI Patterns

For PixelBoats-style lab shell scrolling, expanded main header lab navigation, focus-modal question answering, quick-answer toggle behavior, touched-field saves, and unset/snap-point sureness sliders, see `references/pixelboats-lab-shell-question-board-patterns.md`.

For PixelBoats root/base lab navigation completeness, water-lab pipeline UI conclusions, and no-code seabed visibility investigations, see `references/pixelboats-lab-navigation-and-water-investigation.md`.

For continuing `/lab/water-lab` as a staged Svelte Water Lab pipeline surface — stage 0 seabed, per-layer toggles, shared `waterConfig`, diagnostics probes, and HUD-conversion boundaries — see `references/pixelboats-water-lab-pipeline-ui-continuation.md`.

For the newer `/lab/water-lab` Svelte/DOM/Pixi parity lessons — hidden-not-removed roadmap controls, store/event bridge discipline, Stage 0 seabed texture semantics, stage-toggle isolation, camera-driven `Normalize by zoom`, and Playwright verification probes — see `references/pixelboats-water-lab-store-and-stage-ui.md`.

For independent Stage 0/Stage 1 source-square overlays, purple seabed heuristic debug tiles, shallow-floor visibility controls, ocean opacity, and Stage 1 blend-technique shader knobs, see `references/pixelboats-water-source-overlays-and-floor-blending.md`.

When working on PixelBoats labs for this user, keep the response style tight: conclusion first, concrete verified facts and paths, short blockers/next-up only when useful, and no edits when the user explicitly asks to investigate only.roadmap controls, store/event bridge discipline, Stage 0 seabed texture semantics, stage-toggle isolation, camera-driven `Normalize by zoom`, and Playwright verification probes — see `references/pixelboats-water-lab-store-and-stage-ui.md`.

When working on PixelBoats labs for this user, keep the response style tight: conclusion first, concrete verified facts and paths, short blockers/next-up only when useful, and no edits when the user explicitly asks to investigate only.

### PixelBoats Ship Lab sprite-generation pattern

For `/lab/ship-lab`, keep the main SVG/world preview separate from sprite-output calibration. Use the current `HullForm` generator for geometry, but render sprite comparison through a dedicated orthographic 16-frame projector (`sprite-projector.ts`) rather than the sea-plane/world projection. Compare against `static/assets/boats/merchant-sail-16dir.png` as 16×128 frames, expose phase/invert controls for frame-convention mismatch, and verify hydrated UI with Playwright: reference cells, generated cells, model/style/phase controls, and no browser errors. Keep rig-derived hull model as the default and model override as lab/debug unless explicitly promoted. For silhouette tuning, measure the source sprite alpha in-browser, draw reference band profiles/bounds/waterline in the Overlay strip, and default an `Auto-fit overlay` transform for generated hull+sail overlays while keeping the raw Generated strip unchanged. Treat fitted overlay as a comparison aid, not export output.

## Pitfalls

When adding or auditing PixelBoats lab routes, make the base `/` route a complete launcher, not just a few featured links. Inventory concrete Svelte routes under `src/routes/(lab)/lab`, `src/routes/lab`, `src/routes/labs`, plus standalone demo routes, then ensure all concrete labs are represented in root navigation and mirrored in `/pages` route registry when that registry is manually curated. Skip dynamic catch-all routes like `/lab/[project]` as direct root-nav entries, but include archived/raw labs exposed through it. See `references/pixelboats-root-lab-navigation.md`.

## PixelBoats navigation and staged rendering UI

## PixelBoats navigation and staged rendering UI

For PixelBoats root/base navigation coverage and water-lab rendering-pipeline UI conclusions, see `references/pixelboats-root-lab-navigation-and-water-ui.md`.

Key reminders:
- Inventory all concrete `+page.svelte` lab/demo routes across `/lab`, `/labs`, route groups, and standalone demo routes; exclude dynamic catch-alls like `/lab/[project]` from concrete-route completeness checks.
- Patch both the root boot page and any sitemap registry when the user asks for base/root navigation coverage.
- Verify hydrated root navigation with Playwright rather than raw HTTP HTML; SvelteKit raw HTML may only contain the app shell.
- Treat `/lab/water-lab` as a staged rendering-pipeline acceptance console, not an all-effects mixer: only enable stages rebuilt on the fresh pipeline, and keep disabled stages as roadmap/acceptance gates.
- When wiring staged water controls, preserve future-stage controls in the DOM/data model and hide/lock them instead of deleting them; this keeps recipe rows, diagnostics, and future parity checks intact.
- For Svelte + imperative Pixi lab UI parity, make one shared store the source of truth (`waterConfigStore`/mutable runtime config) and verify both directions: Svelte control → DOM HUD/debug state and DOM HUD/debug state → Svelte control.
- PixelBoats water-stage isolation pitfall: Stage 0 seabed must not silently enable Stage 1 base-depth/texture/ramp toggles, but it still needs a dedicated visible material path. If disabling later-stage context makes the canvas flat/blocky, add an explicit solo shader/render path (e.g. seabed-only uniform/branch) rather than re-enabling the wrong stage.
- Verification pitfall: store/state assertions are not enough for water visuals. Use browser smoke plus a screenshot/visual check for texture detail after stage isolation; a state-correct Stage 0 can still be visually wrong if the shader is showing only depth blocks.
- For PixelBoats UI/design conclusions, lead with a short verdict, then compact numbered conclusions and next step.
- For PixelBoats UI/design conclusions, lead with a short verdict, then compact numbered conclusions and next step.

## Pitfalls

- **Type error when accessing content by key**: Use `const content: Record<string, string> = { ... }` not `const content = { ... }`. Otherwise `content[p.id]` gives "No index signature with a parameter of type 'string'".
- **Filter callback type errors in Svelte templates**: In `{#each}` or `{@const}` expressions, arrow params inside `.filter()` / `.map()` need explicit types: `filter((c: string) => c.trim())`. Svelte's template type inference is weaker than in `.ts` files.
- **Table rendering**: Tables are rendered as divs with CSS Grid (one `div.wiki-table-row` per row). The first row gets header styling. Separator rows (`|---|---|`) are skipped. This is simpler than a `<table>` element and avoids colspan/rowspan complexity.
- **Page enumeration**: Use `{#each pages as p}` to render both the nav buttons AND the content panels. This guarantees nav and content stay in sync — adding a new page means one array entry, not two separate lists.
- **Svelte 5 `$state` reactivity**: `activePage` changes instantly (no async). No need for `$derived` unless you're computing derived data from the active page.
- **`{@html}` in Svelte 5**: Works the same as Svelte 4. Safe to use here because content is authored, not user-submitted. But keep it confined to inline formatting spans, not whole blocks.
- **Backtick escaping in JavaScript template literals**: When your markdown content is stored in JavaScript template literals (`` ` `` ... `` ` ``), any `` ` `` characters inside the content (e.g. `` `game-ui-fixtures.ts` ``) will TERMINATE the template literal and cause a parse error. Always escape them as `\`` when inside a template literal. This applies to:
  - Inline code with backticks: write `\`filename.ts\`` not `` `filename.ts` ``
  - Any backtick character that should be literal text
- **Content provenance / source flags**: When building a wiki from MULTIPLE sources (GPT dump + codebase audit + design notes), contradictions will emerge (same character with different names, different ship class lists). Handle this by:
  1. Flagging all codebase-sourced additions with `> **From <source> — needs review.**` banners
  2. Adding a dedicated review page that catalogs contradictions and proposes resolutions
  3. The review page should have a clear NOT CANON status and sit in a Meta section of the sidebar
- **Inline `{@const}` type annotations**: In Svelte template expressions, arrow function parameters in `.filter()` / `.map()` need explicit types: `filter((c: string) => c.trim())`. Svelte's template type inference is weaker than in `.ts` files.
- **Responsive break**: At ~720px, switch sidebar from fixed left column to horizontal tab bar. Use `@media (max-width: 720px)` with a CSS grid redefinition.
