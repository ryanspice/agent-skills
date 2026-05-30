---
name: image-to-ui-sveltekit
description: Use when converting screenshots, mockups, generated image assets, UI references, or visual design packs into SvelteKit 2 / Svelte 5 implementation plans, components, routes, asset extraction specs, and QA checklists for PixelBoats.
status: active
type: project-agent-skill
project: pixelboats
risk: medium
tags: ["project/pixelboats", "image-to-ui", "sveltekit", "svelte5", "ui-implementation"]
provenance_origin: "original"
provenance_source_path: "04_skills/agent-skills/skills/image-to-ui-sveltekit/SKILL.md"
provenance_credit: "Ryan Spice-Finnie"
provenance_ingested_as: "ryanspice/agent-skills owned skill"
provenance_note: "Original AI Wiki local skill credited to Ryan Spice-Finnie."

---
# PixelBoats Image-to-UI-to-SvelteKit Skill

## Purpose

Use this skill when turning **reference screenshots, generated UI concepts, mockups, sketches, or pasted images** into a maintainable **SvelteKit 2 + Svelte 5** implementation for PixelBoats.

The goal is not to trace a screenshot into a brittle PNG-backed webpage. The goal is to extract the design language, layout contracts, interaction model, component hierarchy, state model, and assets needed to build the UI properly.

## Default Stack

- SvelteKit 2
- Svelte 5 runes
- TypeScript
- Bun-first commands
- Native nested CSS or existing project CSS conventions
- Minimal dependencies
- Static/prerender-first unless the route already needs SSR
- No jQuery
- No heavy UI kit unless explicitly justified

## Canonical Install Paths

Project canonical skill:

```text
<AI_WIKI_ROOT>\skills\projects\pixelboats\image-to-ui-sveltekit\SKILL.md
```

Project mirrors / pointer paths:

```text
<AI_WIKI_ROOT>\projects\pixelboats\.ai\skills\image-to-ui-sveltekit\SKILL.md
<AI_WIKI_ROOT>\projects\pixelboats\skills\image-to-ui-sveltekit\SKILL.md
```

Registry:

```text
<AI_WIKI_ROOT>\03_indexes\skills\skills-registry.json
<AI_WIKI_ROOT>\03_indexes\skills\skill-mirrors.json
```

---

# Operating Rules

## Hard Rules

1. **Do not use the screenshot as the UI.**
   - A temporary reference background is allowed only for visual measurement/debugging.
   - Final UI must be semantic Svelte components.

2. **Do not create or worsen one giant `+page.svelte`.**
   - Extract major surfaces into components unless the target route is deliberately a one-file prototype.
   - Do not add duplicate top-level `<style>` blocks. Svelte components get one top-level style block.

3. **Use Svelte 5 syntax.**
   - Prefer `$state`, `$derived`, `$effect`, `$props`, and `.svelte.ts` state modules where useful.
   - Use `onclick`, `oninput`, etc. for Svelte 5 event attributes.
   - Use attachments for reusable DOM lifecycle behavior when the project/runtime supports them; otherwise use a small local action only when necessary.

4. **Respect the existing route.**
   - Inspect current files first.
   - Preserve existing state, game loops, keyboard shortcuts, stores, and data contracts unless explicitly replacing them.
   - Do not flatten gameplay state into UI-only mock data.

5. **Build from component contracts, not from vibes.**
   - Every visible surface should map to a named component.
   - Every repeated thing should map to data.
   - Every button/hotkey should map to an interaction contract.

6. **Keep the game readable at runtime.**
   - Glass panels, bloom, fog, and texture are allowed, but text and hit targets must survive dark water, storm effects, scaling, and motion.

---

# Workflow

## Phase 0 — Intake

Before editing, identify:

```text
Project root:
Target route:
Reference image paths:
Existing UI files:
Existing state files:
Can run commands? yes/no
Scope: prototype | production route | feature pass | visual audit only
```

If the user attached screenshots, record:

```json
{
  "image": "example.png",
  "width": 1672,
  "height": 941,
  "view": "exploration-hud | inventory | progression | other",
  "notes": ["stormy water background", "glass HUD", "amber/cyan accent split"]
}
```

## Phase 1 — Image Audit

For each image, produce a concise UI inventory.

Required fields:

```json
{
  "surface": "MiniMap",
  "bounds_px": { "x": 1335, "y": 15, "w": 320, "h": 325 },
  "bounds_normalized": { "x": 0.798, "y": 0.016, "w": 0.191, "h": 0.345 },
  "z_layer": "overlay",
  "component": "MiniMap.svelte",
  "state": ["zoom", "playerPosition", "markers", "dangerZones"],
  "interactions": ["zoomIn", "zoomOut", "centerOnPlayer", "collapse"],
  "responsive_rule": "anchor top-right; clamp width; preserve square map viewport"
}
```

Audit these categories:

- global background/game canvas
- top status/weather/route pill
- player stats stack
- compass/wind widget
- minimap
- quick menu / panel launcher
- bottom hotbar / command bar
- modal panels
- inventory/cargo detail panel
- perk tree / quests / crew panels
- keyboard hints
- version/network footer
- notification/toast/event surfaces

## Phase 2 — Design Tokens

Extract and normalize:

```ts
export const uiTokens = {
  color: {
    bg: '#06111b',
    panel: 'rgba(3, 13, 22, 0.82)',
    panelStrong: 'rgba(2, 10, 18, 0.94)',
    border: 'rgba(163, 181, 198, 0.22)',
    borderWarm: 'rgba(245, 166, 52, 0.55)',
    text: '#f4f7fb',
    muted: '#a9b4bf',
    amber: '#f5a331',
    cyan: '#37d7ff',
    danger: '#ff4e48',
    success: '#55d986'
  },
  radius: {
    sm: '0.45rem',
    md: '0.75rem',
    lg: '1.1rem',
    xl: '1.5rem'
  },
  shadow: {
    panel: '0 20px 60px rgba(0, 0, 0, 0.45)',
    glowWarm: '0 0 24px rgba(245, 163, 49, 0.35)',
    glowCyan: '0 0 20px rgba(55, 215, 255, 0.22)'
  }
} as const;
```

Use project tokens if they already exist. Do not create conflicting token systems if the repo already has one.

## Phase 3 — Component Map

Recommended PixelBoats component tree:

```text
src/lib/pixelboats/ui/
  state/
    game-ui-state.svelte.ts
    ui-types.ts
  shell/
    GameHudShell.svelte
    HudLayer.svelte
    PanelLayer.svelte
  hud/
    PlayerStatusStack.svelte
    WeatherRoutePill.svelte
    WindCompass.svelte
    MiniMap.svelte
    QuickMenu.svelte
    VersionNetworkBadge.svelte
  command/
    CommandBar.svelte
    AmmoIndicator.svelte
    CommandSlot.svelte
  panels/
    InventoryPanel.svelte
    CargoGrid.svelte
    ItemDetailCard.svelte
    ShipEquipmentGrid.svelte
    StashStrip.svelte
    ProgressionPanel.svelte
    PerkTree.svelte
    QuestList.svelte
    CrewEventsPanel.svelte
  primitives/
    GlassPanel.svelte
    IconButton.svelte
    HotkeyBadge.svelte
    MeterBar.svelte
    ItemSlot.svelte
```

For a smaller pass, create only the components needed for the target route.

## Phase 4 — State Model

Use `.svelte.ts` state modules for UI state that spans multiple components.

Example:

```ts
// src/lib/pixelboats/ui/state/game-ui-state.svelte.ts
export type PanelId = 'none' | 'inventory' | 'map' | 'perks' | 'quests' | 'crew';

class GameUiState {
  activePanel = $state<PanelId>('none');
  minimalHud = $state(false);
  selectedInventoryId = $state<string | null>(null);

  isPanelOpen = $derived(this.activePanel !== 'none');

  openPanel(panel: Exclude<PanelId, 'none'>) {
    this.activePanel = panel;
  }

  closePanel() {
    this.activePanel = 'none';
  }

  togglePanel(panel: Exclude<PanelId, 'none'>) {
    this.activePanel = this.activePanel === panel ? 'none' : panel;
  }
}

export const gameUiState = new GameUiState();
```

Rules:

- Keep gameplay simulation state separate from UI presentation state.
- Do not invent permanent save data during a UI pass.
- Mock data is allowed only behind a clearly named fixture file.
- Prefer derived values over duplicated state.

## Phase 5 — Layout Strategy

Use layered UI:

```text
<GameCanvas />
<HudLayer />
<PanelLayer />
<CommandBar />
```

CSS strategy:

- `position: fixed` or route-local absolute overlay for HUD surfaces.
- `pointer-events: none` on passive shell layers.
- Re-enable `pointer-events: auto` on controls/panels.
- Use `clamp()` for panel widths and text scaling.
- Use `env(safe-area-inset-*)` around screen edges.
- Preserve minimap aspect ratio.
- Hotbar should remain keyboard-visible and not collide with modal panels.
- Modals should use `max-height`, scroll internally, and avoid blocking the bottom command bar unless deliberately full-screen.

Viewport baseline for the attached PixelBoats references:

```text
Reference viewport: 1672 × 941
Aspect: ~16:9
Primary UI density: desktop/laptop game HUD
```

## Phase 6 — Implementation Order

1. Create or identify a route-level shell.
2. Add design tokens.
3. Add primitives.
4. Add HUD components.
5. Add command bar.
6. Add one panel at a time.
7. Wire keyboard shortcuts.
8. Add responsive rules.
9. Add basic accessibility.
10. Verify build/check.
11. Only then polish animation/glow/texture.

Do not start with animation polish. That is how you get a beautiful swamp nobody can click through.

## Phase 7 — Interaction Contracts

Required interaction map for these screenshots:

```ts
type GameUiAction =
  | 'toggleMinimalHud'
  | 'openMap'
  | 'openInventory'
  | 'openPerks'
  | 'openQuests'
  | 'openCrew'
  | 'closePanel'
  | 'selectHotbarSlot'
  | 'useSelectedItem'
  | 'dropSelectedItem'
  | 'sellSelectedItem'
  | 'moveSelectedItemToStash'
  | 'resetPerkTree'
  | 'viewAllQuests'
  | 'viewEvents';
```

Default keyboard hints:

```text
H = Minimal HUD
M = Map
P = Perks
I or inventory hotbar = Inventory
J = Quests
E = Crew / Events
Esc = Close active panel
1–0 = Hotbar slots
```

Do not bind global listeners blindly. Use Svelte lifecycle/effect cleanup or `<svelte:window>` where appropriate.

## Phase 8 — Accessibility

Minimum requirements:

- Real `button` elements for clickable controls.
- `aria-label` on icon-only controls.
- Keyboard focus style visible on dark backgrounds.
- `aria-current` or selected state for active tabs.
- Modal/panel close with Esc.
- Avoid color-only state; pair color with text/icon/shape.
- Use text alternatives for inventory item icons.
- Use `prefers-reduced-motion`.
- Do not put all UI in canvas unless there is a separate accessible fallback.

## Phase 9 — Visual QA Checklist

Check at:

```text
1366 × 768
1440 × 900
1672 × 941
1920 × 1080
2560 × 1440
```

Verify:

- no duplicated `<style>` compile error
- no HUD collision with minimap
- hotbar remains reachable
- panel content scrolls internally
- minimap remains square/readable
- selected states are obvious
- contrast survives storm/fog background
- keyboard shortcuts work
- Esc closes panels
- active panel does not freeze gameplay unless intended
- mobile/narrow widths degrade gracefully or show a deliberate unsupported layout message

## Phase 10 — Build Verification

Prefer:

```powershell
bun install
bun run check
bun run build
```

If project scripts differ:

```powershell
bun run
```

Then pick the nearest existing scripts. Do not invent a new test stack for a visual UI pass unless the repo already supports it.

Optional screenshot pass if Playwright already exists:

```powershell
bunx playwright test
```

Only add Playwright if requested or the repo already depends on it.

---

# Attached Reference Screens

The current PixelBoats reference set contains three 1672 × 941 images:

1. Exploration HUD over stormy ocean.
2. Inventory/cargo panel over stormy ocean.
3. Perks/quests/crew panel over stormy ocean.

Use them as visual direction for:

- dark nautical glass UI
- amber/cyan status accents
- compact but readable desktop game HUD
- layered panels that preserve the visible game world
- icon-forward inventory and hotbar controls
- right-side minimap and quick navigation
- bottom command bar with numbered slots
- project-specific cargo/weight/stash economy surfaces

Do not copy defects from generated images:

- Do not bake text into images.
- Do not rely on fake icons that cannot be shipped.
- Do not use fixed pixel-only layout without responsive constraints.
- Do not make panels so translucent that readability dies.
- Do not ship unlicensed/generated art assets without a tracking note.

---

# Output Expectations

When asked to implement from image references, produce:

1. **Short image audit**
2. **Component map**
3. **Implementation plan**
4. **Changed files**
5. **Verification commands**
6. **Known gaps / deferred polish**

When asked to generate a prompt for an agent, include:

- target files
- reference image paths
- scope boundaries
- component map
- Svelte 5 rules
- verification commands
- “do not” list
- expected final report format

---

# Paste-Ready Agent Prompt

```text
Use skill: pixelboats-image-to-ui-sveltekit.

We are converting the provided image references into a maintainable SvelteKit 2 + Svelte 5 UI implementation for PixelBoats.

Goal:
Build semantic Svelte components matching the attached game HUD/panel direction: stormy ocean game HUD, minimap, player stats, wind/weather pill, command hotbar, inventory/cargo panel, perk/quest/crew panel.

Hard rules:
- Do not use the screenshot as the final UI.
- Do not create a giant one-file route unless this is explicitly a throwaway prototype.
- Do not add duplicate top-level <style> blocks.
- Use Svelte 5 runes and event attributes.
- Keep gameplay/simulation state separate from UI presentation state.
- Use Bun commands.
- No jQuery, no heavy UI kits, no broad refactor.

First:
1. Inspect the target route and existing UI/state files.
2. Produce a short image audit with approximate bounding boxes and component names.
3. Propose the smallest component map that fits the current route.
4. Implement one vertical slice first: HUD shell + top pill + left stats + minimap + hotbar.
5. Then add only the requested panel(s).

Use this target component direction if no better existing convention exists:
src/lib/pixelboats/ui/state/game-ui-state.svelte.ts
src/lib/pixelboats/ui/shell/GameHudShell.svelte
src/lib/pixelboats/ui/hud/PlayerStatusStack.svelte
src/lib/pixelboats/ui/hud/WeatherRoutePill.svelte
src/lib/pixelboats/ui/hud/WindCompass.svelte
src/lib/pixelboats/ui/hud/MiniMap.svelte
src/lib/pixelboats/ui/hud/QuickMenu.svelte
src/lib/pixelboats/ui/command/CommandBar.svelte
src/lib/pixelboats/ui/panels/InventoryPanel.svelte
src/lib/pixelboats/ui/panels/ProgressionPanel.svelte
src/lib/pixelboats/ui/primitives/GlassPanel.svelte

Verify:
bun run check
bun run build

Final response:
- Summary of what changed
- Files changed
- Verification result
- Remaining visual gaps
- Next best UI pass
```

<!-- AIWIKI_IMAGE_TO_UI_RESOURCES_START -->
## Local resources

This project skill may include `templates/` and `examples/` directories.

Use `templates/` for reusable SvelteKit/Svelte 5 implementation scaffolds, extraction specs, route/component structures, and prompt-pack shapes.

Use `examples/` or `examples/evals` for representative screenshot-to-UI conversion cases, acceptance checks, and regression examples.

Keep this skill project-specific unless the same workflow is useful across multiple projects. Promote a generalized version to `04_skills/universal` only after review.
<!-- AIWIKI_IMAGE_TO_UI_RESOURCES_END -->
