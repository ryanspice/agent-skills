---
name: pixelboats-stormy-hud-lab
description: Use when creating, auditing, refactoring, or packaging the PixelBoats Stormy HUD lab at /lab/stormy-hud, including HUD shell layout, command/bag bars, inventory/cargo/stash panels, progression panels, Captain Log page-flip, fixtures/state, and UI integration boundaries.
risk: medium
version: 0.5.8
source_kind: generated-project-skill
canonical_generated_path: <AI_WIKI_ROOT>\04_skills\generated\pixelboats-stormy-hud-lab\SKILL.md
canonical_project_path: <AI_WIKI_ROOT>\04_skills\projects\pixelboats\pixelboats-stormy-hud-lab\SKILL.md
repo_mirror_path: <DEV_ROOT>\PixelBoats\.ai\skills\pixelboats-stormy-hud-lab\SKILL.md
provenance_origin: "original"
provenance_source_path: "04_skills/generated/pixelboats-stormy-hud-lab/SKILL.md"
provenance_credit: "Ryan Spice-Finnie"
provenance_note: "Original AI Wiki generated skill credited to Ryan Spice-Finnie."

---

# PixelBoats Stormy HUD Lab Skill

## Goal

Build and stabilize the PixelBoats Stormy HUD lab as a production-minded SvelteKit/Svelte 5 UI playground without derailing P0 gameplay stabilization.


## Canonical Skill Layout

This generated project skill belongs in the AI Wiki first. Treat the AI Wiki project skill as the canonical active copy and repo-local files as mirrors/pointers for coding agents.

Canonical generated record:

```txt
<AI_WIKI_ROOT>\04_skills\generated\pixelboats-stormy-hud-lab\SKILL.md
```

Canonical active project skill:

```txt
<AI_WIKI_ROOT>\04_skills\projects\pixelboats\pixelboats-stormy-hud-lab\SKILL.md
```

Repo-local working mirror:

```txt
<DEV_ROOT>\PixelBoats\.ai\skills\pixelboats-stormy-hud-lab\SKILL.md
```

Compatibility pointer paths may exist here, but they are not the source of truth:

```txt
<AI_WIKI_ROOT>\projects\pixelboats\.ai\skills\pixelboats-stormy-hud-lab\SKILL.md
<AI_WIKI_ROOT>\projects\pixelboats\skills\pixelboats-stormy-hud-lab\SKILL.md
<DEV_ROOT>\PixelBoats\skills\pixelboats-stormy-hud-lab\SKILL.md
```

When updating this skill, update the canonical AI Wiki project copy first, then refresh generated/archive and repo mirror copies. Do not treat `.ai/skills` as canonical.

This skill is specifically for the SvelteKit route:

```txt
src/routes/(lab)/lab/stormy-hud
```

and the related UI component tree:

```txt
src/lib/pixelboats/ui/
  command/
  hud/
  panels/
  primitives/
  shell/
  state/
  types/
```

## When To Use

Use this skill for:

- `/lab/stormy-hud` feature work
- Stormy HUD visual/layout passes
- inventory/cargo/stash/progression panel work
- command bar and bag bar work
- minimap, compass, quest tracker, player status, hull stencil work
- Captain Log / book / page-flip work
- SvelteKit 2 + Svelte 5 route/component repair in the Stormy HUD lab
- packaging Stormy HUD lab drops into changes-only TAR.GZ artifacts
- creating agent handoffs for this HUD lab

Do not use this skill for:

- core WebGL water renderer changes
- boat physics/collision changes
- server/WebSocket gameplay changes
- map editor/Wake Lab implementation
- AudioForge/SFX manager work, except when a repo-wide check blocker must be noted
- broad P0 game stabilization unless the HUD directly caused the regression

## Required Baseline Reading

Before editing, read the relevant current files:

```txt
<AI_WIKI_ROOT>\04_skills\projects\pixelboats\pixelboats-stormy-hud-lab\SKILL.md
.ai/skills/pixelboats-stormy-hud-lab/SKILL.md
.ai/skills/pixelboats-p0-stabilization/SKILL.md
.ai/skills/sveltekit2-svelte5-engineering/SKILL.md, if present
.thoughts
FEATURE_MATRIX.md
NEXT_CHAT_HANDOFF.md
src/routes/(lab)/lab/stormy-hud/+page.svelte
src/routes/(lab)/lab/stormy-hud/+page.ts
src/lib/pixelboats/ui/state/ui-types.ts
src/lib/pixelboats/ui/state/game-ui-state.svelte.ts
src/lib/pixelboats/ui/state/game-ui-fixtures.ts
src/lib/pixelboats/ui/shell/GameHudShell.svelte
```

If the repo does not contain all of these files, inspect the nearest existing equivalents. Do not invent paths.

## Bootstrap Discipline

This is not a scaffold task.

Do not run:

```powershell
npx sv create
```

inside PixelBoats.

For this existing repo:

1. Inspect `package.json`.
2. Prefer Bun when `bun.lock`, repo scripts, or project convention indicate Bun.
3. Make the smallest useful change.
4. Verify with the repo's existing scripts.

Preferred verification:

```powershell
cd "<DEV_ROOT>\PixelBoats"
bun install
bun run check
bun run build
bun run dev -- --host 127.0.0.1
```

Open:

```txt
http://localhost:5173/lab/stormy-hud
```

## Svelte 5 Rules

Use Svelte 5 runes for new or heavily edited Stormy HUD code:

- `$props()` for props
- `$state()` for local mutable state
- `$derived()` for computed state
- `$effect()` only for real side effects with cleanup

Avoid:

- legacy `$:` for new code
- component-wide stores for local panel state
- hidden global coupling
- giant catch-all components
- unnecessary dependencies
- disabling SSR globally to dodge a browser-only bug

Browser-only APIs must be guarded with `browser` from `$app/environment` or moved into client-only effects.

## Stormy HUD Product Shape

The lab should feel like a futuristic naval/roguelike HUD:

- stormy ocean/game background behind the UI
- glass/metal panels with readable contrast
- compact but legible upper HUD stack
- right-side inventory/menu composite under the minimap
- bottom command bar with strong game affordance
- bag slots that can become real player-facing shortcuts
- panels that look like game systems, not random web cards

The UI can be dramatic, but it must remain readable at 4K and usable at normal laptop sizes.

## Layout Rules

### Shell

`GameHudShell.svelte` owns composition, not business logic.

Keep these concerns separate:

- shell layout
- HUD widgets
- command/bag bars
- panels
- fixtures/state
- primitive visual components

Do not bury inventory mutation logic or page-flip logic directly in the shell unless it is only simple orchestration.

### Right-Side Inventory Composite

The right inventory area should remain one continuous surface under/near the minimap.

Rules:

- keep Inventory, Cargo, Ship Equipment, and Stash visually related
- use accordion sections when screen space is tight
- active section expands; inactive sections show one preview row
- keep a compact 6-column inventory grid unless a deliberate redesign changes this
- show empty slots visibly; empty space is useful in inventory UI
- default detail panel should show boat/RPG stats
- item detail appears only after item selection
- do not bring back a separate floating quest-log column inside the inventory workspace

### Quest Tracker

When inventory/menu state is open, the compact quest tracker can move to the left side and replace or temporarily displace the compass.

Quest tracker rules:

- remain glanceable
- do not compete with item details
- do not grow into a full journal in the HUD shell
- deeper quest log belongs in a panel, not the always-visible HUD

### Command Bar / Bag Bar

Command bar rules:

- keep strong TRADER / ship-console styling
- center XP value/bar clearly
- preserve keyboard affordances
- keep Ctrl+1..4 bag slot behavior obvious
- bag bar can support 2x2 and row-capable layouts
- buttons must remain real buttons with labels/aria text where needed

## Captain Log / Page-Flip Rules

Captain Log is a special browser-only integration using `page-flip` / StPageFlip.

Rules:

- dynamically import `page-flip` only in browser-safe code
- bind the book container with `bind:this`
- wait for `tick()` before querying page elements
- pass real page HTML nodes to `loadFromHTML` / `loadFromHtml`
- listen to plugin events for page state updates
- destroy the PageFlip instance on cleanup and component destroy
- preserve Previous/Next toolbar buttons as reliable fallback controls
- keep buttons disabled at boundaries
- do not fake page preview with a separate overlay
- do not manually mutate current page early during drag gestures
- let StPageFlip own right-to-left and left-to-right page drag behavior
- avoid non-interactive div pointer/keyboard listeners that create Svelte a11y warnings
- avoid multiple top-level `<style>` blocks in a Svelte component
- keep paper texture and book shadows scoped to Captain Log

Expected interaction:

```txt
Open /lab/stormy-hud -> Captain Log -> drag right page toward left.
The current page should lift and reveal the next page underneath during the turn.
```

## Inventory / Stack Interaction Rules

Inventory work should preserve stack-aware behavior:

- drag/drop moves stacks intentionally
- Ctrl+click can split stacks when implemented
- mouse wheel can nudge stack counts where supported
- inventory/cargo/stash movement should not silently delete items
- selected-item detail should update predictably
- empty slots must remain selectable/visible when useful
- no mutation should depend on display order alone when item IDs exist

When behavior is placeholder-only, label it as fixture/demo behavior. Do not pretend the lab is already wired to the authoritative game inventory.

## State / Fixture Rules

Keep UI fixtures separate from state helpers:

```txt
state/game-ui-fixtures.ts       demo data
state/game-ui-state.svelte.ts   UI state helpers
state/ui-types.ts               durable types
```

Rules:

- update fixture version labels when packaging a visible UI pass
- keep fake values obvious enough for lab use
- avoid importing game-loop/WebGL internals into fixture files
- design types so later game-state integration can replace fixtures without rewriting every component

## Visual System Rules

Use existing primitives where possible:

```txt
GlassPanel.svelte
HotkeyBadge.svelte
IconButton.svelte
MeterBar.svelte
```

Prefer:

- scoped component CSS
- CSS variables/tokens already present in the lab
- semantic markup first
- readable contrast
- responsive grid/flex layouts
- reduced-motion fallbacks for heavy animation

Avoid:

- global CSS sprawl
- fragile `:global()` except for third-party DOM like StPageFlip
- div soup for buttons
- hover-only controls
- huge UI libraries
- random glow soup that hides state

## Accessibility Rules

Before polishing visuals, check:

- action controls are `<button type="button">`
- buttons have visible labels or `aria-label`
- disabled buttons use actual `disabled`
- tab/focus order is not cursed
- keyboard fallback exists for important interactions
- `aria-pressed`, `aria-expanded`, and `aria-current` are used when appropriate
- reduced motion is respected for heavy visual effects
- text remains readable on stormy backgrounds

## Performance Rules

The Stormy HUD lab is UI, but it sits on top of a game.

Rules:

- no animation loops unless necessary
- avoid layout thrash from repeated measurements
- avoid deep object churn in hot UI interactions
- keep derived values derived, not recalculated heavily in markup
- do not use expensive filters across large full-screen surfaces unless visually justified
- keep `page-flip` isolated to Captain Log; do not initialize it when hidden if that causes visible or perf regressions

## Integration Boundaries

Do not touch these unless the request explicitly requires it:

```txt
index.html
server/dev-server.mjs
src/lib/game/*
src/routes/(lab)/lab/audioforge/*
```

Exception: if a repo-wide `bun run check` is blocked by an unrelated known compile error, report it clearly and patch it only if the user requested a verified package and the patch is tiny/safe.

Do not package or claim a full game release for a HUD-only lab pass.

## Common Failure Modes

Stop and diagnose if you see:

- Svelte duplicate `<style>` compile errors
- `window` / DOM use during SSR
- `page-flip` imported at module top level and breaking SSR
- duplicate keyed each values in log/inventory lists
- layout works at 4K but collapses at laptop width
- page-turn preview is fake overlay instead of real PageFlip behavior
- inventory panel reintroduces separated floating boxes
- quest tracker competes with inventory details
- disabled buttons still fire actions
- component state mutates fixtures permanently by accident

## Packaging Rules

For a Stormy HUD lab package:

- prefer changes-only TAR.GZ unless a full repo package is truly required
- preserve relative paths
- include a PowerShell installer
- back up touched files where practical
- add or preserve `page-flip` dependency only when Captain Log is included
- update package README
- update package `.thoughts`
- do not claim browser QA passed unless it actually ran

Recommended artifact names:

```txt
pixelboats-stormy-hud-lab-vX.Y.Z.tar.gz
install-pixelboats-stormy-hud-lab-vX.Y.Z.ps1
```

For skill-only updates, install into the AI Wiki canonical locations plus the repo mirror. Use:

```txt
pixelboats-stormy-hud-lab-skill-vX.Y.Z.tar.gz
install-pixelboats-stormy-hud-lab-skill-vX.Y.Z.ps1
```

## Verification Checklist

Run when code changed:

```powershell
cd "<DEV_ROOT>\PixelBoats"
bun install
bun run check
bun run build
bun run dev -- --host 127.0.0.1
```

Manual QA:

- open `/lab/stormy-hud`
- verify route loads without console errors
- verify minimap/right composite alignment
- open/close inventory/menu state
- verify quest tracker left-side behavior when inventory is open
- expand each accordion section
- drag/drop or select inventory items
- verify item detail/default boat stat behavior
- verify command bar and bag slots
- open Captain Log
- drag page right-to-left and left-to-right
- use Previous/Next buttons
- check narrow viewport behavior
- check reduced-motion behavior if animation changed

## Required Output When Used

Return:

1. scope classification
2. files touched
3. behavior changed
4. verification run
5. manual QA still needed
6. risks / known blockers
7. package links, if generated
8. exact PowerShell install/apply command
