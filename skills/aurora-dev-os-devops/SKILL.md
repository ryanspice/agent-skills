---
name: aurora-dev-os-devops
description: "Guide for building new labs, workspace panels, and UI within the Aurora Dev OS ecosystem of PixelBoats. Covers shell patterns, suite registration, lab route conventions, workspace panel authoring, Aurora UI primitives, design tokens, navigation wiring, route policy, and verification."
version: 1.0.0
status: active
type: project-agent-skill
risk: medium
tags: ["pixelboats", "aurora", "devos", "devops", "lab-route", "workspace", "ui", "shell", "suite", "registration"]
project: pixelboats
created_at: 2026-07-21
metadata:
  related_skills: [sveltekit-lab-route-authoring, pixelboats-game-dev-orchestrator, pixelboats-production-architecture, pixelboats-skill-authoring]
  hermes:
    tags: [sveltekit, svelte5, aurora, devos, suite-registry, workspace, lab, ui-kit]
    related_skills: [sveltekit-lab-route-authoring, pixelboats-game-dev-orchestrator]
---

# Aurora Dev OS DevOps

## Use When

- Building a **new lab route** under `src/routes/(lab)/lab/<name>/`
- Adding a **workspace panel** to the IDE (`/workspace`)
- Registering a **new app in the suite registry** (`suite-registry.ts`)
- Wiring **navigation** — dock, footer, header menus, process rails
- Choosing the **right shell pattern** — standalone, dashboard, workspace, compact header
- Building **UI with Aurora design tokens** or the Kit component library
- Creating a **dashboard-style page** within the Dev OS chrome
- Adding **right-click context menus** or modal overlays within Dev OS routes
- Any task where the agent needs to know "how do I build X within the Aurora shell"

## Getting Started: Dev Server

The dev server is a **SINGLETON** — never start raw `bun run dev` or `vite dev`. Always use:

```bash
node scripts/pixelboats/dev-server.mjs
```

If the server is already running (check with `pixelboats_dev_server_status`), reuse it. Raw duplicates cost ~2.4 GB each and cause port conflicts. The MCP `pixelboats_queue` tool serializes server control across Claude Code, Codex, and Hermes.

## Aurora Dev OS Philosophy

Four principles drive every decision:

1. **Single source of truth.** The suite registry (`suite-registry.ts`) is the ONE catalog. The dashboard, workspace, sitemap, dock, footer, and domain rail all derive from it. Register here first — everything else follows.
2. **Shell/lab separation.** The Aurora chrome (header, footer, dock, GameHost) lives in `src/lib/suite/aurora/`. Lab content lives in `src/routes/(lab)/lab/<name>/`. Labs don't import shell components unless they opt into the full Dev OS layout.
3. **Token-first theming.** All colors, radii, fonts, and effects come from `aurora-theme.css` CSS variables. Never hardcode `#0b1738` or `14px` — use `var(--aurora-surface)` and `var(--aurora-radius-sm)`.
4. **Svelte 5 runes.** `$state`, `$derived`, `$effect`, `$props`, snippet slots. No Svelte 4 stores or `$:` reactive statements. LabPanel values MUST be `$state` objects.

## Quick Decision Flowchart

**What am I building?**

```
New lab or UI? ─────────────────────────────────────────────┐
  ├─ Standalone page (no chrome) ── /lab/<name> + standalone:true in registry
  ├─ Dashboard in Dev OS chrome ─── AuroraShell variant="dashboard"
  ├─ IDE/workspace page ─────────── AuroraShell variant="workspace"
  ├─ Workspace panel ────────────── new component in workspace/ dir
  ├─ Navigation item ────────────── edit dock/footer/header-menus
  └─ Wiki/lore page ─────────────── standalone lab + markdown block parser

Need LabPanel controls? ─────────────────────────────────────┐
  ├─ Sliders/toggles/colors/selects ── LabPanel with LabSchema
  ├─ Floating toggle button ────────── LabFab
  ├─ HUD pipeline nav ──────────────── HudLabNav (pipeline:'hud')
  └─ Mechanics scene nav ───────────── MechanicLabNav

Need UI components? ────────────────────────────────────────┐
  ├─ Content blocks/panels ────── KitPanel, GlassPanel
  ├─ Buttons ──────────────────── KitButton, IconButton
  ├─ Modal/dialog ─────────────── AuroraModal
  ├─ Dropdown menu ────────────── Dropdown + DropdownItem
  ├─ Status/count badge ───────── Badge, KitBadge
  ├─ Progress/stat ────────────── KitProgress, KitStatBar, MeterBar
  ├─ Tab bar ──────────────────── KitTabBar
  └─ Icons ────────────────────── GameIcon (glyph/emoji/PNG)
```

## Shell Patterns

### AuroraShell (the primary layout container)

Located at `src/lib/suite/aurora/AuroraShell.svelte`. CSS Grid with three snippet slots:

```svelte
<script lang="ts">
  import AuroraShell from '$lib/suite/aurora/AuroraShell.svelte';
</script>

<AuroraShell variant="dashboard" {statusResizable}>
  {#snippet rail()}
    <!-- Left sidebar (13.5rem) — DomainRail, SceneOutline, etc. -->
  {/snippet}
  {#snippet main()}
    <!-- Center content — REQUIRED -->
  {/snippet}
  {#snippet status()}
    <!-- Right pane (220-520px when resizable) — optional -->
  {/snippet}
</AuroraShell>
```

**Variants:**
- `"dashboard"` — Padded main pane. Use for overview pages, settings, catalog views.
- `"workspace"` — Edge-to-edge main pane. Use for IDE layouts with toolbars + viewports.

**statusResizable:** When `true` and `status` snippet is provided, the right pane gets a drag handle and ranges 220-520px. Persisted via `--aurora-status-width` CSS variable.

**Responsive:** Collapses to single-column at 1100px.

### Standalone Mode (No Dev OS Chrome)

For labs that should render WITHOUT the Aurora shell (just the compact header FAB):

1. Set `standalone: true` in the suite registry entry
2. The root `+layout.svelte` checks `STANDALONE_ROUTES` (derived from registry) plus the `?standalone=1` URL parameter
3. Standalone labs get the **compact header** (small floating FAB badge) instead of the full AuroraHeader

```svelte
<!-- src/routes/(lab)/lab/my-lab/+page.svelte -->
<svelte:head><title>My Lab · PixelBoats</title></svelte:head>

<div class="my-lab-content">
  <!-- Full control over layout — no shell wrapper -->
</div>
```

### Compact Header vs Full Header vs No Header

The root `+layout.svelte` decides chrome mode:

| Condition | Result |
|---|---|
| `?standalone=1` or `?shell=0` | Compact header (small FAB badge) |
| `?fullscreen=1` or `?live=1` | Compact header |
| `?workspace=1` or `?embedded=workspace` | NO header (embedded mode) |
| DevOS route (/, /workspace, /settings, etc.) | Full AuroraHeader |
| `routeOwnsAuroraHeader()` returns true | Lab owns its header (only `/lab/pixelgen`) |

If your lab needs a custom full header: update `routeOwnsAuroraHeader()` in `src/lib/suite/aurora/header/header-route-policy.ts`.

### (devops) Route Group Layout

Routes under `src/routes/(devops)/` get the `(devops)/+layout.svelte` wrapper, which provides:
- Full AuroraHeader
- Persistent GameHost iframe (loads the spine app with `?standalone=1&workspace=1`)
- Does NOT unmount GameHost across navigations — 3D context stays alive

Lab routes under `(lab)/lab/` do NOT go through this layout — they inherit from root directly.

## The Suite Registry

**File:** `src/lib/suite/suite-registry.ts`

Every app/lab/route that appears in the Dev OS must be registered here. This is the single source of truth.

### SuiteApp Type

```typescript
type SuiteApp = {
  id: string;            // Stable slug — matches the lab directory name
  href: string;          // Route path, e.g. "/lab/my-lab"
  label: string;         // Display name
  domain: SuiteDomain;   // One of 9 domains (see below)
  status: SuiteStatus;   // One of 6 statuses (see below)
  summary: string;       // One-line description shown on tiles
  icon?: string;         // Emoji glyph for GameIcon fallback
  standalone?: boolean;  // Renders without full Dev OS chrome
  tags?: string[];       // Extra search keywords
  pipeline?: 'hud';      // HUD pipeline membership → shows on HudLabNav
  order?: number;        // 1-based position along the pipeline
  openIn?: 'workspace' | 'standalone';  // Preferred launch target
};
```

### Domains (map to A/B/C/P/D-S model)

| Domain | Label | Covers |
|---|---|---|
| `spine` | Integration Spine | Atmosphere, composition, WorldRenderPacket |
| `world` | World & Water | A/B/C/P — water, terrain, mapgen, projection, charts |
| `ships` | Ships & Characters | D-S — hull, rig, physics, sprites, characters |
| `ui` | UI & HUD | HUD pipeline, lore, menus, component kits |
| `audio` | Audio | SFX, music, ambient |
| `net` | Networking | Multiplayer, server |
| `tools` | Dev Tools | Cross-cutting meta tools |
| `product` | Product Shells | /game, /map, /playtest |
| `archive` | Archive | Dead/superseded |

### Statuses

| Status | Use When | Transition Rule |
|---|---|---|
| `canonical` | Source of truth for its domain (rare — e.g. SVG Authority, Lore) | Promote from `active` after multi-lane consensus |
| `active` | In active development (default for new WIP labs) | Default for new labs |
| `frozen` | Reference only — do not edit (e.g. Ship Lab) | Freeze when other labs depend on your output format |
| `scaffold` | Placeholder shell, not yet implemented | Move to `active` when implementation begins |
| `deferred` | Intentionally parked | Use when deprioritized but not dead |
| `archived` | Dead/superseded (e.g. HUD Composer, UI Director) | Archive when a new canonical supersedes this app |

### The `openIn` Field

`openIn?: 'workspace' | 'standalone'` controls the **preferred launch target** when a tile/launcher opens the app:

- `'workspace'` — Opens in a /workspace Scene tab (deferred consumer — not yet fully implemented)
- `'standalone'` — Opens as a standalone full-page route

When omitted, the app opens as a normal page navigation. This is a preference hint, not enforced — the launcher (`launchHref()` in suite-registry.ts) may override it based on context.

### Consuming Suite OS State

**File:** `src/lib/suite/suite-os.svelte.ts`

The reactive client state backing the dashboard. Any agent building a dashboard, launcher, or domain-aware UI needs to know how to read and write it:

```typescript
import { suiteOs } from '$lib/suite/suite-os.svelte';

// Read state (all are Svelte 5 $state — reactive anywhere)
suiteOs.query;           // Current search query string
suiteOs.activeDomain;    // Selected domain filter (or null for all)
suiteOs.showMuted;       // Whether archived/deferred apps are shown
suiteOs.favorites;       // string[] of app ids (persisted to localStorage)
suiteOs.recents;         // string[] of recently launched app ids
suiteOs.paletteOpen;     // Command palette visibility

// Write state
suiteOs.setDomain('world');    // Filter by domain
suiteOs.toggleFavorite('id');  // Add/remove favorite
suiteOs.recordLaunch('id');    // Record a launch (updates recents)
suiteOs.openPalette();         // Open command palette
```

Favorites persist to `localStorage` key `pb.devos.favorites.v1`. Recents persist to `pb.devos.recents.v1`.

### i18n / Paraglide

Dev OS pages use `@inlang/paraglide-js` for internationalization. Import messages from:

```typescript
import { m } from '$lib/paraglide/messages.js';
```

Usage: `m.your_message_key()` returns the localized string. The workspace page uses this pattern extensively (e.g., `m.footer_nav_dashboard()`, `m.ws_panel_health()`).

When adding user-facing text to Dev OS panels, use paraglide messages rather than hardcoded English strings. For lab pages that don't need i18n, plain strings are fine.

**Step 1:** Create the route file
```
src/routes/(lab)/lab/<name>/+page.svelte
```

**Step 2:** Add entry to `SUITE_REGISTRY` array (keep alphabetical within domain block):
```typescript
{
  id: "my-new-lab",
  href: "/lab/my-new-lab",
  label: "My New Lab",
  domain: "tools",        // pick the closest domain
  status: "active",       // default for new WIP
  summary: "Brief one-line description for dashboard tiles.",
  icon: "🔬",             // optional emoji
  standalone: true,       // if no shell chrome needed
  tags: ["tag1", "tag2"], // at least 2-3 search tags
}
```

**Step 3:** Verify with `reconcileSuite()` — `suite-discovery.server.ts` scans disk vs registry. Check the dashboard status rail for "unfiled" (route exists but not registered) or "missing" (registered but no route file).

**Step 4:** Wire navigation (see Navigation Integration section below).

## Server-Side Data Patterns

For data-driven pages (like /workspace), use `+page.server.ts` to load data server-side:

```typescript
// +page.server.ts
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async () => {
  // Read filesystem, run git, query databases — runs on server only
  return { tree, git: { branch, head, dirtyCount }, drift };
};
```

```svelte
<!-- +page.svelte -->
<script lang="ts">
  import type { PageData } from './$types';
  let { data }: { data: PageData } = $props();
  // Use data.tree, data.git, etc.
</script>
```

The workspace server load (`src/routes/(devops)/workspace/+page.server.ts`) is the canonical example: it builds a source tree (depth 2, max 160 nodes), gets git HEAD/branch/dirty count, and runs `reconcileSuite()` for registry drift. It is DEV-ONLY (returns 404 in production).

**Important:** `+page.server.ts` files have full Node.js filesystem access but run only on the server. They cannot use browser APIs. The returned data is serialized as JSON to the client.

## Route Groups

The repo uses four route groups. Each has different layout rules:

| Group | Path | Layout | Use For |
|---|---|---|---|
| `(devops)` | `/`, `/workspace`, `/settings`, etc. | `(devops)/+layout.svelte` — full AuroraHeader + GameHost | Dev OS pages, IDE, admin |
| `(lab)` | `/lab/<name>` | Inherits root layout — NO group layout | Labs, prototypes, experiments |
| `(mechanics)` | `/lab/<name>` | Inherits root layout, shared `MechanicLabNav` | Gameplay mechanic prototypes |
| `(legacy)` | `/lab/<name>` | Inherits root layout | Archived/superseded labs |

**`(mechanics)` group:** Contains gameplay prototypes (Fishing, Dunk Toss, Cursive Log, Day Clock). These share `MechanicLabNav.svelte` for top navigation. Register them in the suite registry normally — the route group is transparent to the registry.

**`(legacy)` group:** Archived labs (weather-perspective, wake-poc, pixi-foundation, etc.). These are superseded but preserved for reference. Do not edit these without explicit approval.

## Lab Route Authoring

### Route Structure

```
src/routes/(lab)/lab/<name>/
  └── +page.svelte          ← single-page component (no +layout needed)
```

**No group layout.** Lab routes inherit from the root `+layout.svelte`. Do NOT create a `+layout.svelte` in `(lab)/` — it would apply to ALL labs.

### LabPanel (Schema-Driven Control Panel)

**File:** `src/lib/pixelboats/ui/lab/LabPanel.svelte`

The primary way to add interactive controls to a lab. Schema-driven: define sections, controls, and values — LabPanel renders the UI.

**Props:**
- `schema: LabSchema` — section/control definitions
- `values: Record<string, LabValue>` — MUST be a `$state` object
- `ctx: { set(key, value), reset?() }` — write callbacks
- `open: boolean` (bindable) — panel visibility
- `dock: LabDock` (bindable) — `'right'` | `'float'` | `'collapsed'` | `'inline'`
- `hideSearch: boolean` — hide local search (when host owns search)
- `persistKey: string` — localStorage key prefix (default: `'pb-labpanel'`)

**Dock modes:**
- `right` — Fixed right panel (default)
- `float` — Draggable free-floating window
- `collapsed` — Hidden, shows reopen button
- `inline` — Embedded in parent container (use for workspace status area)

**Type definitions** from `src/lib/pixelboats/ui/lab/lab-types.ts`:
```typescript
type LabControlKind = 'slider' | 'toggle' | 'color' | 'select';

type LabSliderControl = {
  key: string; label: string; kind: 'slider';
  min: number; max: number; step: number;
};

type LabToggleControl = {
  key: string; label: string; kind: 'toggle';
};

type LabColorControl = {
  key: string; label: string; kind: 'color';
};

type LabSelectControl = {
  key: string; label: string; kind: 'select';
  options: { value: string; label: string }[];
};

type LabSection = {
  id: string;
  label: string;
  group?: string;        // tab id this section belongs to
  blurb?: string;
  thumbnail?: string;
  controls?: LabControl[];
  palette?: { key: string; label: string }[];
  ready?: boolean;
};

type LabTab = { id: string; label: string };

type LabSchema = {
  title: string;
  tabs?: LabTab[];
  sections: LabSection[];
};
```

**Usage pattern:**
```svelte
<script lang="ts">
  import LabPanel from '$lib/pixelboats/ui/lab/LabPanel.svelte';
  import LabFab from '$lib/pixelboats/ui/lab/LabFab.svelte';
  import type { LabSchema } from '$lib/pixelboats/ui/lab/lab-types';

  const schema: LabSchema = {
    title: 'My Lab Controls',
    sections: [
      {
        id: 'section-1',
        label: 'Display',
        controls: [
          { key: 'brightness', label: 'Brightness', kind: 'slider', min: 0, max: 100, step: 1 },
          { key: 'showGrid', label: 'Show Grid', kind: 'toggle' },
        ],
      },
    ],
  };

  let values = $state<Record<string, number | boolean | string>>({
    brightness: 50,
    showGrid: true,
  });

  const ctx = {
    set(key: string, value: number | boolean | string) { values[key] = value; },
    reset() { /* restore defaults */ },
  };

  let panelOpen = $state(false);
</script>

<LabPanel schema={schema} values={values} {ctx} bind:open={panelOpen} persistKey="my-lab-panel" />
<LabFab bind:open={panelOpen} label="Controls" />
```

### LabFab (Floating Toggle Button)

**File:** `src/lib/pixelboats/ui/lab/LabFab.svelte`

Props: `open` (bindable), `label`, `anchor` (`'top-right'`|`'bottom-right'`|`'top-left'`|`'bottom-left'`), `draggable` (for /game overlay use), `storageKey` (localStorage persistence), `class`.

### HudLabNav (HUD Process Pipeline Rail)

**File:** `src/lib/pixelboats/ui/lab/HudLabNav.svelte`

Shows the 4-stage HUD pipeline: Assets(1) → Elements(2) → Studio(3) → HD(4). Only renders for apps with `pipeline: 'hud'` in the registry. Takes `current` prop (the active app's `id`).

```svelte
<HudLabNav current="stormy-hud-elements" />
```

### MechanicLabNav

**File:** `src/lib/pixelboats/ui/lab/MechanicLabNav.svelte`

Shared top nav for `(mechanics)` route group labs: Fishing, Dunk Toss, Cursive Log, Day Clock.

### Wiki/Lore Content Pattern

For wiki-style labs with markdown content, use the block-based parser from the `sveltekit-lab-route-authoring` skill. That skill covers the full pattern: `parseBlocks()`, sidebar with section groups, content footer with canon legend, and the two theme palettes (Dark/Gold for mechanical pages, Ocean/Teal for lore pages).

**Load the `sveltekit-lab-route-authoring` skill alongside this one** when building wiki/lore labs.

## Workspace Panel Authoring

### Workspace Layout

The workspace route (`src/routes/(devops)/workspace/+page.svelte`) uses `AuroraShell variant="workspace" statusResizable`:

- **Rail (left):** SceneOutline (top) + WorkspaceExplorer (bottom, file tree)
- **Main (center):** WorkspaceToolbar + WorkspaceViewport + WorkspaceConsole
- **Status (right):** Tabbed — "Project" tab (ProjectHealthCard, ContextGraph, TaskQueue, AssetBrowser, PropertiesInspector, ActivityFeed) or "Adaptive" tab (LabPanel with SPIKE_LAB_SCHEMA)

### Adding a New Status Panel

1. Create component in `src/lib/suite/aurora/workspace/MyPanel.svelte`
2. Follow the existing panel pattern:
```svelte
<script lang="ts">
  let { title = 'My Panel' }: { title?: string } = $props();
</script>

<section class="my-panel aurora-border-gradient-subtle">
  <span class="aurora-section-header">{title}</span>
  <!-- panel content -->
</section>

<style>
  .my-panel {
    padding: 0.8rem;
    border-radius: var(--aurora-radius-lg);
    font-family: var(--aurora-font-sans);
  }
</style>
```
3. Import and add to the status stack in `workspace/+page.svelte`
4. The panel renders inside a flex column with `gap: 0.7rem`

### Adding a New Rail Panel

1. Create component in `src/lib/suite/aurora/workspace/`
2. Import in `workspace/+page.svelte`
3. Add to the `rail` snippet alongside or replacing SceneOutline/WorkspaceExplorer

### Adaptive LabPanel in Workspace

The workspace's "Adaptive" tab embeds LabPanel with `dock="inline"` — this strips fixed positioning and makes it a flex child. Essential pattern:
```svelte
<LabPanel
  schema={SPIKE_LAB_SCHEMA}
  values={labValues}
  ctx={labCtx}
  dock="inline"
  persistKey="workspace-adaptive-lab"
  hideSearch
  onNavigate={handleNavigate}
/>
```

## Aurora UI Primitives

Location: `src/lib/suite/aurora/ui/`

### AuroraModal

```svelte
<script lang="ts">
  import AuroraModal from '$lib/suite/aurora/ui/AuroraModal.svelte';
  let open = $state(false);
</script>

{#if open}
  <AuroraModal title="My Dialog" close={() => open = false}>
    <p>Content here. Escape key also closes.</p>
  </AuroraModal>
{/if}
```

### Badge

```svelte
import Badge from '$lib/suite/aurora/ui/Badge.svelte';

<Badge value={5} color="var(--aurora-red)" />
<Badge dot color="var(--aurora-green)" />
```

### Dropdown + DropdownItem

```svelte
import Dropdown from '$lib/suite/aurora/ui/Dropdown.svelte';
import DropdownItem from '$lib/suite/aurora/ui/DropdownItem.svelte';

<Dropdown width="14rem">
  {#snippet trigger({ open })}
    <span>Actions {open ? '▲' : '▼'}</span>
  {/snippet}
  {#snippet children({ close })}
    <DropdownItem label="Save" onSelect={() => { save(); close(); }} />
    <DropdownItem label="Settings" href="/settings" />
  {/snippet}
</Dropdown>
```

### ContextMenu + ContextMenuItem

For right-click context menus. See the `pixelboats-aurora-right-click-context-boundary` skill for the full pattern and route ownership rules.

### TagChip

```svelte
import TagChip from '$lib/suite/aurora/ui/TagChip.svelte';

<TagChip label="active" style="--tc-pad:0.25rem 0.5rem; --tc-radius:0.5rem" />
```

CSS custom properties: `--tc-pad`, `--tc-radius`, `--tc-font`, `--tc-bg`, `--tc-color`.

### IconButton

```svelte
import IconButton from '$lib/suite/aurora/ui/IconButton.svelte';
import { Settings } from 'lucide-svelte';

<IconButton icon={Settings} label="Settings" onclick={openSettings} />
```

## Design Token System

**File:** `src/lib/suite/aurora/aurora-theme.css`

Imported once in root `+layout.svelte`. All values available as CSS variables everywhere.

### Surface Tokens

```css
--aurora-app: #050a1e;         /* Deepest background */
--aurora-sidebar: #07132f;      /* Rail/sidebar */
--aurora-header: #0b1738;       /* Top header bar */
--aurora-surface: #0b1738;      /* Card/panel default */
--aurora-surface-2: #111d4a;    /* Elevated surface */
--aurora-border: #253a74;       /* Default border */
--aurora-border-soft: rgba(156, 170, 229, 0.14);  /* Subtle border */
```

### Text Tokens

```css
--aurora-text: #eef4ff;         /* Primary text */
--aurora-text-2: #9caae5;       /* Secondary text */
--aurora-text-muted: #6b7bb5;   /* Muted/tertiary text */
```

### Accent Colors

```css
--aurora-primary: #7c3dff;      /* Purple — primary brand */
--aurora-cyan: #13d6ff;
--aurora-blue: #3478ff;
--aurora-magenta: #ea4dff;
--aurora-green: #28e8a3;
--aurora-amber: #ffc857;
--aurora-red: #ff5c7a;
--aurora-sea: #0b84b8;          /* Nautical */
--aurora-harbor-gold: #f3a83b;  /* Nautical gold */
--aurora-glow-rgb: 124, 61, 255; /* For rgba() glow effects */
```

### Radius Scale

```css
--aurora-radius-xs: 0.375rem;   /* 6px */
--aurora-radius-sm: 0.625rem;   /* 10px */
--aurora-radius: 0.875rem;      /* 14px — default */
--aurora-radius-lg: 1.25rem;    /* 20px */
```

### Fonts

```css
--aurora-font-sans: "Geist", ui-sans-serif, ...;
--aurora-font-mono: "Geist Mono", "Cascadia Mono", ...;
--aurora-ease: cubic-bezier(0.16, 1, 0.3, 1);
```

Self-hosted variable fonts at `/fonts/Geist-Variable.woff2` and `/fonts/GeistMono-Variable.woff2`.

### CSS Utility Classes

| Class | Effect |
|---|---|
| `.aurora-glass` | Frosted glass background |
| `.aurora-glass-dark` | Darker glass variant |
| `.aurora-border-gradient-subtle` | Subtle gradient border |
| `.aurora-glow-strong` | Strong purple glow |
| `.aurora-text-gradient` | Purple gradient text |
| `.aurora-section-header` | Standard section heading style |
| `.aurora-scroll` | Styled scrollbar |
| `.aurora-hover-lift` | Subtle lift on hover |
| `.aurora-pulse` | Pulse animation |
| `.aurora-tabular` | Tabular numbers (monospace digits) |
| `.aurora-skyline` | Skyline decorative effect |
| `.aurora-viewport-bg` | Viewport background |
| `.aurora-grid-overlay` | Grid overlay pattern |

### Custom Component Styling

Always reference tokens, never hardcode:
```css
.my-component {
  background: var(--aurora-surface);
  border: 1px solid var(--aurora-border);
  border-radius: var(--aurora-radius-sm);
  color: var(--aurora-text);
  font-family: var(--aurora-font-sans);
}
.my-component:hover {
  box-shadow: 0 0 24px -4px rgba(var(--aurora-glow-rgb), 0.4);
}
```

### CSS Scoping Strategy

Svelte's `<style>` blocks are scoped by default. This interacts with design tokens and utility classes in specific ways:

- **CSS variables (`var(--aurora-*)`) work naturally in scoped styles.** The custom properties cascade through the DOM regardless of Svelte's scoping. Use them freely in any `<style>` block.
- **Utility classes (`.aurora-glass`, `.aurora-glow-strong`, etc.) need `:global()` when applied inside scoped styles:**
  ```css
  /* Inside a Svelte <style> block */
  .my-card :global(.aurora-glass) {
    /* Only use this if you need to OVERRIDE a utility class */
  }
  ```
- **Applying utilities directly to elements** (the common case) works without any special handling:
  ```svelte
  <div class="aurora-glass aurora-border-gradient-subtle">
    <!-- Utility classes on the element itself — no :global() needed -->
  </div>
  ```
- **Don't scope utility classes.** If you write `.aurora-glass { ... }` inside a scoped `<style>`, Svelte adds a data attribute and the selector no longer matches the utility — it only matches elements with BOTH the utility class AND the scoped attribute. This almost never what you want.

### Lucide Icon Sizing Trap

Tailwind is NOT bundled on devops routes. `aurora-theme.css` sets baseline lucide sizing. Use explicit size classes:
```svelte
<Settings class="w-3 h-3" />   <!-- maps to 0.75rem via aurora-theme.css -->
<Menu class="w-4 h-4" />       <!-- maps to 1rem -->
```

## Navigation Integration

### AuroraDock (Bottom Module Dock)

**File:** `src/lib/suite/aurora/AuroraDock.svelte`

Shows favorites first, then curated `KEY_APP_IDS`, deduplicated, capped at 12. To add your app:

1. Add its `id` to the `KEY_APP_IDS` array
2. Appears after user favorites, before the cap
3. Icon resolved via `resolveIconSrc()` → domain accent color

### AuroraFooter (Bottom Status Bar)

**File:** `src/lib/suite/aurora/AuroraFooter.svelte`

Hardcoded `shortcuts` array — NOT auto-derived from registry. To add a shortcut:
```typescript
import { Beaker } from 'lucide-svelte';  // import the icon

const shortcuts = [
  // ... existing ...
  { href: "/lab/my-lab", label: () => "My Lab", icon: Beaker, exact: false },
];
```

### HeaderMenuBar

**File:** `src/lib/suite/aurora/header/HeaderMenuBar.svelte`

Menu items defined in `header-menus.ts`. Add entries there for header-level navigation.

### HudLabNav Pipeline

If your app is HUD pipeline, set `pipeline: 'hud'` and `order: N` in registry. HudLabNav auto-discovers pipeline apps from SUITE_REGISTRY.

### Sitemap

Auto-derived from SUITE_REGISTRY — no manual update needed. Any registered app appears.

## UI Kit Components

**Location:** `src/lib/pixelboats/ui/kit/`
**Barrel:** `src/lib/pixelboats/ui/kit/index.ts`

Token-driven via `--pb-*` CSS variables with hardcoded fallbacks. Each has a `data-material` hook for GPU/HUD-Studio targeting.

| Component | Use |
|---|---|
| `KitPanel` | Content block panel with `variant` prop (gold, teal, etc.) |
| `KitButton` | Action button with multiple variants |
| `KitProgress` | Progress bar |
| `KitPill` | Rounded pill/chip |
| `KitBadge` | Count/status badge |
| `KitListRow` | List item row |
| `KitStatBar` | Stat display bar |
| `KitTabBar` + `KitTab` | Tab bar with typed tabs |

```svelte
<script lang="ts">
  import { KitPanel, KitButton, KitProgress, KitBadge } from '$lib/pixelboats/ui/kit';
</script>

<KitPanel title="Ship Status" variant="gold">
  <KitStatBar label="Hull" value={78} max={100} />
  <KitButton variant="primary" onclick={repair}>Repair</KitButton>
</KitPanel>
```

### UI Primitives (Lower Level)

Located at `src/lib/pixelboats/ui/primitives/`:
`GameIcon`, `GamePopover`, `GlassPanel`, `PanelFrame`, `IconButton`, `UiSprite`, `MeterBar`, `CountUp`, `HotkeyBadge`, `FactionFlagIcon`, `LoadingSpinner`.

### When to Use Kit vs Primitives vs Aurora UI

| Layer | Use For |
|---|---|
| Aurora UI (`suite/aurora/ui/`) | Dev OS chrome: modals, dropdowns, badges in shell context |
| Kit (`pixelboats/ui/kit/`) | Product/pack UI: panels, buttons, progress in game-facing surfaces |
| Primitives (`pixelboats/ui/primitives/`) | Low-level atoms both layers can compose |

## Route Policy

**File:** `src/lib/suite/aurora/header/header-route-policy.ts`

### DEVOS_ROUTE_PREFIXES

Routes that get the full AuroraHeader:
```typescript
"/", "/settings", "/features", "/docs", "/keyboard-shortcuts",
"/about", "/sitemap", "/insights", "/workspace", "/design-system",
"/design-map", "/archive", "/npc-editor", "/quest-editor",
"/port-editor", "/boat-editor"
```

### Key Functions

| Function | Returns |
|---|---|
| `isDevOsRoute(pathname)` | True if path matches a DEVOS_ROUTE_PREFIX |
| `isWorkspaceRoute(pathname)` | True for `/workspace` and `/workspace/*` |
| `isWorkspaceEmbed(search)` | True if `?workspace=1` or `?embedded=workspace` |
| `wantsStandaloneChrome(search)` | True if `?standalone=1` or `?shell=0` |
| `wantsCompactHeader(search)` | True if `?fullscreen=1` or `?live=1` |
| `routeOwnsAuroraHeader(pathname)` | True ONLY for `/lab/pixelgen` |

### How Root Layout Decides

`src/routes/+layout.svelte` imports `aurora-theme.css` globally, then:
1. Checks `isDevOsRoute()` → full GameShell + AuroraHeader
2. Checks `wantsStandaloneChrome()` → compact header
3. Checks `isWorkspaceEmbed()` → no header (bare content)
4. For standalone-registered labs: derives `STANDALONE_ROUTES` from `SUITE_REGISTRY.filter(a => a.standalone).map(a => a.href)`, checks if path starts with any standalone href → compact header

### To Add a New DevOS Route

Add its prefix to `DEVOS_ROUTE_PREFIXES` in `header-route-policy.ts`.

## Aurora Import

**Location:** `src/lib/aurora-import/`

A separate library of Svelte components, stores, and i18n imported from GLM 5.2. NOT part of the canonical Aurora shell — these are alternate implementations available as a component library.

**Components:**
- `components/Header.svelte` — Alternate header with menu bar, search, controls
- `components/MainContent.svelte` — Main content area
- `components/LeftSidebar.svelte`, `components/RightSidebar.svelte` — Side panels
- `components/BottomPanel.svelte` — Bottom panel
- `components/Taskbar.svelte` — Status bar
- `components/ParticleField.svelte` — Background particles
- `components/ResizablePanelGroup.svelte` — Resizable panel container
- `components/controls/LanguageSwitcher.svelte`, `ThemeSwitcher.svelte`, `ProfileSwitcher.svelte`

**Stores:** `$lib/aurora-import/stores/layout.svelte`, `$lib/aurora-import/i18n/language.svelte`

**Lab showcase:** `/lab/aurora-import` — demonstrates the imported components.

**When to use Aurora Import vs canonical Aurora:** Prefer canonical Aurora shell (`src/lib/suite/aurora/`) for Dev OS pages. Use aurora-import components when you need a quick alternate layout or want to prototype with the imported design. The two systems are independent — they don't share state.

## Pitfalls and Traps

### 1. `standalone: true` ≠ automatic compact header
The root layout checks BOTH the URL param (`?standalone=1`) AND `STANDALONE_ROUTES` (derived from registry). If your standalone route is at `/lab/my-lab`, navigating to it directly gets compact header. But if another route iframe-embeds your lab, the chrome decision comes from the PARENT route, not your registry entry.

### 2. Lab routes have NO +layout.svelte
`(lab)/lab/` routes inherit from root layout directly. Do NOT create a `+layout.svelte` in the lab group — it applies to ALL labs. The `(devops)/+layout.svelte` only wraps devops routes (/, /workspace, /insights, etc.).

### 3. `routeOwnsAuroraHeader` is only `/lab/pixelgen`
If your lab needs a custom full header (not compact, not shell), add its path to this function in `header-route-policy.ts`. Currently only pixelgen has this privilege.

### 4. statusResizable grid quirks
When `statusResizable` is enabled on AuroraShell, the grid is 4 columns (rail : main : 7px handle : status). The status pane is 220-520px. At 1100px viewport, everything collapses to single column. Test responsive behavior.

### 5. Lucide icons on devops routes
Tailwind is NOT bundled on product/devops routes. `aurora-theme.css` sets baseline lucide sizes (1rem × 1rem). Use explicit classes `w-3 h-3`, `w-4 h-4` etc. Do NOT assume Tailwind classes work.

### 6. LabPanel persistKey collision
Each LabPanel instance persists dock/position to localStorage using `persistKey`. Always use a unique key per consuming site (e.g., `"workspace-adaptive-lab"`, `"my-lab-controls"`) to avoid state cross-talk. Default is `"pb-labpanel"` — don't use the default.

### 7. Suite registry drift
`suite-discovery.server.ts` compares disk vs registry at load time. An "unfiled" route (exists on disk, not in registry) or "missing" route (in registry, no file) is flagged. Always verify both are in sync after registration.

### 8. KitPanel ≠ LabPanel ≠ GlassPanel
- **KitPanel** — Content blocks in asset-pack UIs (`--pb-*` tokens, `data-material` hook)
- **GlassPanel** — Low-level glassmorphic primitive
- **LabPanel** — Schema-driven control panel for lab interactivity
Each has a distinct use case. Don't confuse them.

### 9. Footer shortcuts are hardcoded
`AuroraFooter` shortcuts array is manual. Adding a registry entry does NOT add a footer shortcut. You must edit `AuroraFooter.svelte`.

### 10. AuroraDock cap
Favorites render first, then `KEY_APP_IDS`, deduplicated, capped at 12. Adding to `KEY_APP_IDS` doesn't guarantee visibility if 12 favorites are set.

### 11. GameHost persistence
The GameHost iframe in `(devops)/+layout.svelte` persists across ALL devops route navigations. It loads once and stays alive. Don't try to remount it or load a second instance.

### 12. LabPanel values reactivity
Values passed to LabPanel MUST be a `$state` object. A plain object won't trigger Svelte 5 reactivity and controls won't update.

### 13. `dock="inline"` for workspace embedding
When embedding LabPanel in workspace status, use `dock="inline"` — it strips fixed positioning, backdrop, and makes it a flex child. Without this, the panel overlays the workspace as a fixed-position drawer.

### 14. Svelte scoped styles vs utility classes
Svelte `<style>` blocks add data attributes to selectors. Utility classes (`.aurora-glass`, `.aurora-glow-strong`) applied directly to elements work fine. But if you write `.aurora-glass { ... }` inside a scoped `<style>`, Svelte transforms it to `.aurora-glass[svelte-abc123]` which won't match the element's plain `.aurora-glass` class. Either apply utilities on elements directly, or use `:global(.aurora-glass)` in scoped styles.

### 15. `(mechanics)` and `(legacy)` route groups exist
The skill primarily covers `(lab)` and `(devops)`. But `(mechanics)` (Fishing, Dunk Toss, Cursive Log, Day Clock) and `(legacy)` (archived labs) are also valid route groups with the same "no group layout, inherit root" rule. Don't try to add a layout to these groups either.

### 16. Paraglide messages are expected in Dev OS pages
Dev OS panels use `import { m } from '$lib/paraglide/messages.js'` for i18n. Plain English strings in Dev OS chrome will look out of place. Lab pages can use plain strings, but Dev OS shell panels should use `m.key_name()`.

## Verification Checklist

### Before Committing

- [ ] `bun run check` clean (route type errors)
- [ ] No circular imports introduced
- [ ] Route returns 200 (navigate in browser)
- [ ] `consoleErrors=0` in browser console
- [ ] `reconcileSuite()` returns no "unfiled" and no "missing" for the new route

### Runtime Smoke

- [ ] Route renders without JS errors
- [ ] Standalone labs show compact header (FAB badge at top)
- [ ] Dev OS routes show full AuroraHeader with brand/menus/search
- [ ] AuroraShell variant correct (dashboard padded, workspace edge-to-edge)
- [ ] LabPanel docks correctly and persistKey doesn't collide
- [ ] LabFab opens/closes panel (threshold-based click/drag detection works)
- [ ] Status resizer drags smoothly if enabled
- [ ] Favorites/recents persist across reload

### Navigation Verification

- [ ] App appears in DomainRail filter under correct domain
- [ ] App appears in AuroraDock if added to KEY_APP_IDS
- [ ] App appears in AuroraFooter if added to shortcuts
- [ ] Sitemap shows the new entry
- [ ] `?standalone=1` hides Dev OS chrome
- [ ] `?workspace=1` bypasses header

### Responsive

- [ ] Test at 1100px (grid collapse), 720px, 360px

### Accessibility

- [ ] Interactive elements have aria-label
- [ ] Escape closes modals, dropdowns
- [ ] Tab order is logical

## Interaction with Existing Skills

| Skill | Relationship | When to Load Together |
|---|---|---|
| `sveltekit-lab-route-authoring` | Covers markdown block parser, wiki sidebar, SPA navigation, theme palettes (dark/gold, ocean/teal). This skill covers shell, registration, workspace, navigation wiring. | Load BOTH for wiki/lore labs. Lab-route-authoring handles content; this handles infrastructure. |
| `pixelboats-game-dev-orchestrator` | Decides WHAT to build. This skill teaches HOW to build it within the Dev OS shell. | Load orchestrator first (scope/priority), then this skill (implementation). |
| `pixelboats-production-architecture` | Module boundary decisions. | When the new panel crosses module boundaries (e.g., reading from `$lib/world/`). |
| `pixelboats-skill-authoring` | For extracting repeatable patterns into new skills. | After finishing a lab that introduces a new reusable pattern. |
| `pixelboats-aurora-right-click-context-boundary` | Context menu behavior within Dev OS routes. | When adding ContextMenu to a workspace panel or lab. |
| `pixelboats-performance-budget-loop` | Performance verification. | When the lab involves WebGL2, shaders, or particles. |

## References

### Core Shell
- `src/lib/suite/aurora/AuroraShell.svelte` — Primary layout wrapper (CSS Grid, 3 snippet slots)
- `src/lib/suite/aurora/AuroraHeader.svelte` — Full header with 7 sub-component regions
- `src/lib/suite/aurora/AuroraFooter.svelte` — Status bar with shortcuts + live metrics
- `src/lib/suite/aurora/AuroraDock.svelte` — Bottom module dock (favorites + KEY_APP_IDS)
- `src/lib/suite/aurora/AuroraModal.svelte` — Modal dialog overlay
- `src/lib/suite/aurora/GameHost.svelte` — Persistent 3D game iframe
- `src/lib/suite/aurora/header/header-route-policy.ts` — Route-to-chrome policy functions

### Suite Registry
- `src/lib/suite/suite-registry.ts` — SUITE_REGISTRY array + SuiteApp type
- `src/lib/suite/suite-os.svelte.ts` — Client state (query, domain, recents, favorites)
- `src/lib/suite/suite-discovery.server.ts` — Disk vs registry reconciler
- `src/lib/suite/suite-query.ts` — Filter/group/match helpers
- `src/lib/suite/domains.ts` — 9 domain definitions
- `src/lib/suite/status.ts` — 6 status definitions

### Lab UI
- `src/lib/pixelboats/ui/lab/LabPanel.svelte` — Schema-driven control panel
- `src/lib/pixelboats/ui/lab/LabFab.svelte` — Floating toggle button
- `src/lib/pixelboats/ui/lab/HudLabNav.svelte` — HUD process pipeline rail
- `src/lib/pixelboats/ui/lab/MechanicLabNav.svelte` — Mechanics scene nav
- `src/lib/pixelboats/ui/lab/lab-types.ts` — LabSchema, LabControl, LabSection types

### Design Tokens
- `src/lib/suite/aurora/aurora-theme.css` — All design tokens + utility classes

### UI Components
- `src/lib/suite/aurora/ui/` — Aurora UI primitives (Badge, Dropdown, ContextMenu, TagChip, IconButton)
- `src/lib/pixelboats/ui/kit/index.ts` — Kit component barrel
- `src/lib/pixelboats/ui/primitives/` — Low-level primitives (GameIcon, GlassPanel, etc.)

### Workspace
- `src/routes/(devops)/workspace/+page.svelte` — Canonical workspace implementation
- `src/routes/(devops)/workspace/+page.server.ts` — Server load (tree, git, reconciliation)
- `src/lib/suite/aurora/workspace/` — Workspace panel components (SceneOutline, WorkspaceExplorer, WorkspaceViewport, etc.)
- `src/lib/suite/aurora/ActivityFeed.svelte` — Activity feed (adjacent to workspace, not in the subdirectory)

### Routes
- `src/routes/+layout.svelte` — Root layout (chrome decision, aurora-theme import)
- `src/routes/(devops)/+layout.svelte` — DevOS group layout (AuroraHeader + GameHost)
- `src/routes/(devops)/+page.svelte` — Dashboard home page

### Aurora Import
- `src/lib/aurora-import/components/` — GLM 5.2 imported components
- `src/routes/(lab)/lab/aurora-import/+page.svelte` — Import showcase

### Documentation
- `docs/DEV_SUITE_PLAN.md` — Suite phases, Aurora asset pack reference
- `.fusion/game-fusion-pack/reports/bedrock-foundation-architecture.md` — Bedrock architecture
- `$lib/paraglide/messages.js` — i18n message functions (import as `m`)
