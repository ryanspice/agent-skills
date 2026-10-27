---
title: Universal Windows Phone / Metro Design Skill
version: 1.0.0
date: 2026-05-18
target_models:
  - ChatGPT 5.5
  - Claude
  - Hermes
  - Trae
  - Codex
primary_use:
  - Windows Phone-like UI design
  - Metro / Lumia / Zune-inspired shells
  - Android Jetpack Compose mockups
  - SvelteKit 2 + Svelte 5 route UI mockups
  - Tauri / desktop shell UI
  - Prompt packs and design recreation guides
preferred_output_style:
  - code-first when implementing
  - structured design spec when planning
  - concise acceptance checklist
---

# Universal Windows Phone / Metro Design Skill

Use this skill whenever the user asks for UI, UX, prompts, mockups, asset packs, design descriptions, implementation guidance, or app-shell concepts inspired by:

- Windows Phone 7 / 8 / 8.1 / 10
- Lumia apps
- Zune
- Metro / Modern UI
- Baconit-era Reddit clients
- black/OLED mobile shells
- Pivot / Panorama navigation
- Action Center / quick actions
- live tiles
- command bars
- large clean typography
- 4K / 120 Hz touch-first UI

This skill is **not** a nostalgia skin. Treat it as a practical, modern 2026 UI system that borrows the best of Windows Phone: readable typography, confident spacing, direct manipulation, gesture-first navigation, and clean visual hierarchy.

---

## 0. Default Role

You are a senior product/UI engineer designing or implementing a Windows Phone-like interface.

Your job is to produce something that feels:

- crisp
- black/OLED-first
- fast
- typographic
- touch-native
- structured
- restrained
- useful
- slightly futuristic without becoming fake sci-fi clutter

Do not over-Materialize it.
Do not turn it into generic iOS glass.
Do not bury everything in cards.
Do not make the design cute unless explicitly requested.

---

## 1. Core Design Philosophy

### 1.1 Metro Is Content-First

The UI should feel like the content is the interface.

Prefer:

- text as structure
- motion as context
- grids as rhythm
- pivots as navigation
- command bars as action surfaces
- negative space as hierarchy

Avoid:

- heavy chrome
- raised Material cards everywhere
- random gradients
- pill overload
- excessive rounded corners
- giant floating action buttons
- decorative shadows as the main depth system

### 1.2 Use Large Type, Not Loud Decoration

Windows Phone-like design works because headings and labels carry weight.

Use type scale aggressively:

| Purpose | Recommended Feel |
|---|---|
| App title | huge, light weight, lowercase or sentence case |
| Pivot labels | large, lowercase, horizontally arranged |
| Section labels | small uppercase or compact lowercase |
| List primary text | readable, direct |
| Metadata | dim, compact, secondary |
| Commands | icon + label, never mystery icons only |

Good labels:

- `social`
- `history`
- `account`
- `settings`
- `hot`
- `new`
- `top`
- `active`
- `live`
- `quick actions`
- `notifications`

Bad labels:

- vague marketing words
- unnecessary cleverness
- ambiguous icon-only controls

---

## 2. Visual Language

### 2.1 Canvas

Default background:

```css
--metro-bg: #000;
--metro-surface: #070707;
--metro-surface-2: #101010;
--metro-line: rgba(255,255,255,.14);
--metro-line-soft: rgba(255,255,255,.08);
--metro-text: rgba(255,255,255,.94);
--metro-text-soft: rgba(255,255,255,.68);
--metro-text-dim: rgba(255,255,255,.42);
--metro-accent: #1e9bff;
```

Use OLED black by default. Dark gray surfaces are allowed only to separate layers.

### 2.2 Accent Color

Use one strong accent at a time.

Default accent candidates:

- Windows blue
- Lumia cyan
- Zune magenta
- Xbox green
- warm amber for warnings
- deep red only for destructive/death/error states

The accent should appear in:

- pivot underline
- selected tile edge
- quick action active state
- progress/focus line
- key command icons
- selected toggles

Do not use accent as full background everywhere unless building a tile.

### 2.3 Geometry

Prefer:

- square or near-square tiles
- thin separators
- clean rectangular panels
- simple icon circles only when the platform metaphor needs them
- subtle 2px to 8px rounding where modern polish requires it

Avoid:

- huge 24px+ rounded cards everywhere
- random bubble UI
- Material Design elevation stacks
- neumorphism
- fake glass unless explicitly requested

### 2.4 Depth

Depth should come from:

1. typography scale
2. motion
3. layer position
4. transparency
5. thin rules
6. subtle surface contrast

Use shadows sparingly. Metro does not need fake cardboard layers.

---

## 3. Typography

### 3.1 Preferred Fonts

Use, in order:

```css
font-family:
  "Segoe UI Variable",
  "Segoe UI",
  "Segoe WP",
  system-ui,
  sans-serif;
```

For Android Compose:

- Prefer platform sans if Segoe is unavailable.
- Simulate Metro through weight, spacing, and scale.
- Use thin/light weights for big headings when readable.
- Use regular/semibold for row titles and commands.

### 3.2 Type Scale

Suggested CSS tokens:

```css
--type-hero: clamp(3.2rem, 9vw, 7rem);
--type-title: clamp(2.4rem, 6vw, 4.8rem);
--type-pivot: clamp(1.45rem, 3vw, 2.35rem);
--type-section: .78rem;
--type-body: 1rem;
--type-row: 1.08rem;
--type-meta: .82rem;
```

### 3.3 Casing

Use lowercase for pivots where it fits:

```txt
social   history   account   settings
hot      new       top       active      live
```

Use sentence case for readable settings labels.

Use uppercase sparingly for technical metadata and section chips.

---

## 4. Layout System

### 4.1 Safe Area

Always account for:

- status bar
- notch/cutout
- gesture navigation
- bottom command bar
- high DPI / 4K scaling
- 120 Hz touch interaction

Do not shove text into the notch.
Do not let command bars cover content.

### 4.2 Page Skeleton

A default Windows Phone-like screen:

```txt
┌──────────────────────────────┐
│ status / small metadata       │
│                              │
│ app title                     │
│                              │
│ pivot row                     │
│ ━ selected underline          │
│                              │
│ content region                │
│ rows / tiles / panels         │
│                              │
│ bottom command bar            │
└──────────────────────────────┘
```

### 4.3 Spacing

Use strong left alignment.

Recommended mobile padding:

```css
--page-x: clamp(18px, 5vw, 48px);
--page-y: clamp(16px, 3vh, 40px);
--row-gap: 10px;
--section-gap: 28px;
```

Text should not feel centered unless it is a splash/waiting/death state.

### 4.4 Grid Rhythm

Tiles should feel intentional.

Good tile sizes:

- 1x1
- 2x1
- 2x2
- 4x2 panorama/wide tile

Use square rhythm even if content inside is asymmetric.

---

## 5. Navigation Patterns

## 5.1 Pivot

Pivot is the default Metro navigation primitive.

A pivot has:

- horizontally arranged labels
- selected underline
- content page
- drag-follow transition
- velocity-aware snap
- edge handoff rules

### Pivot Behavior Rules

1. Content follows the finger while dragging.
2. Underline follows the target label during drag.
3. Snap only after release.
4. Do not commit until threshold or velocity is met.
5. Child pivot owns gesture before parent pivot.
6. At the start/end of a secondary pivot, hand off to parent panorama only after clear edge intent.
7. Axis-lock early so vertical scrolling does not fight horizontal pivoting.

### Pivot Acceptance Criteria

- Dragging feels attached to the finger.
- No delayed “after release” jump pretending to be touch interaction.
- Underline tracks smoothly.
- Nested pivots do not steal each other’s gestures.
- Edge handoff feels intentional, not accidental.
- 120 Hz devices do not show visible jank.

---

## 5.2 Panorama

Use panorama for main shell sections.

Example:

```txt
social  history  account  settings
```

Each section may contain its own pivot:

```txt
social
hot  new  top  active  live
```

Rules:

- Main panorama handles high-level app sections.
- Secondary pivot handles local category switching.
- Secondary pivot must not accidentally drag the main panorama.
- At first/last local tab, a strong continued drag may hand off to the main panorama.

---

## 5.3 Command Bar

Bottom command bar rules:

- Use icon + label.
- Keep commands short.
- Prefer 3–5 primary commands.
- Use overflow for extras.
- Keep touch targets large.
- Do not use tiny mystery icons.

Example:

```txt
[ + add ] [ search ] [ refresh ] [ filter ] [...]
```

Visual:

- black/dark surface
- thin top divider
- white icons
- accent for selected/active
- compact labels

---

## 5.4 App Bar / Status Row

Top status row can include:

- time
- date
- network/service state
- account/source
- settings shortcut
- version/dev marker if in dev mode

Keep it quiet. It should not compete with the title.

---

## 6. Action Center / Shade Pattern

Use for Android shade replacements, overlays, dashboard drawers, or quick-control panels.

### 6.1 Structure

```txt
┌──────────────────────────────┐
│ time / date / status          │
│ quick actions collapsed row   │
│ expanded quick actions grid   │
│ brightness / audio sliders    │
│ system chips row              │
│ notifications                 │
└──────────────────────────────┘
```

### 6.2 Quick Actions

Collapsed mode:

- one or two rows
- large tap targets
- active state uses accent
- disabled state is dim

Expanded mode:

- grid of square/circular-icon actions
- labels visible
- brightness slider
- audio slider
- optional per-icon settings on long press

Drag behavior:

- dragging down expands controls first
- dragging up collapses expanded controls first
- notification list scroll begins after quick actions are resolved

### 6.3 Notifications

Notification rules:

- grouped by app/source
- images expanded by default if present and space allows
- inline actions visible when available
- swipe actions commit only on finger lift
- swipe can be canceled by reversing before release
- non-clearable/system notifications can collapse into a chip row under quick actions

Do not immediately delete/dismiss on partial swipe. That is sloppy.

---

## 7. Gesture Ownership

### 7.1 Priority

Gesture priority should usually be:

1. Direct child control
2. Horizontal child pivot
3. Vertical scroll
4. Parent panorama
5. Global drawer/back gesture

### 7.2 Rules

- A child pane owns its local pivot.
- Comment/detail panes own comment-sort pivots.
- Parent route should not steal nested gestures.
- Edge handoff only happens at bounds.
- Vertical scroll must remain reliable.
- Swipe-to-dismiss should require release commitment.

### 7.3 Interaction Tuning

Recommended thresholds:

```txt
tap slop:       6–10 px
axis lock:      after 8–14 px
pivot commit:   30–40% page width or high velocity
swipe action:   35–45% row width
fling velocity: platform-specific; tune manually
```

Use these as starting points, not religion.

---

## 8. Motion Language

### 8.1 Motion Feel

Metro motion should feel:

- direct
- fast
- weighted
- clean
- connected to touch
- slightly cinematic for page transitions

Avoid:

- bouncy toy springs
- excessive blur
- slow easing everywhere
- motion that hides poor layout

### 8.2 Common Motions

| Motion | Behavior |
|---|---|
| Pivot drag | content and underline follow finger |
| Pivot release | snap with velocity-aware easing |
| Page enter | slight horizontal slide + opacity |
| Command bar | subtle upward reveal |
| Quick action expand | height/grid expansion, not random fade |
| Notification swipe | row translates with action reveal |
| Tile press | small scale/opacity response |
| Waiting screen | slow ambient drift only |

### 8.3 Easing

Good CSS defaults:

```css
--ease-metro: cubic-bezier(.16, 1, .3, 1);
--ease-snap: cubic-bezier(.2, .8, .2, 1);
--ease-out: cubic-bezier(0, 0, .2, 1);
```

---

## 9. Component Recipes

## 9.1 Pivot Header

Required parts:

- label row
- active index
- underline position
- drag progress
- aria-current or selected state
- keyboard navigation

CSS concept:

```css
.pivot {
  display: flex;
  gap: clamp(18px, 5vw, 44px);
  overflow-x: auto;
  scrollbar-width: none;
}

.pivot button {
  appearance: none;
  border: 0;
  background: transparent;
  color: rgba(255,255,255,.55);
  font: inherit;
  font-size: var(--type-pivot);
  font-weight: 300;
  text-transform: lowercase;
}

.pivot button[aria-current="page"] {
  color: rgba(255,255,255,.96);
}

.pivot-underline {
  height: 3px;
  background: var(--metro-accent);
  transform-origin: left center;
}
```

---

## 9.2 Feed Row

Good for Threadpane/Baconit-like lists.

```txt
[source] title text
metadata • comments • score • time
optional excerpt/image
```

Rules:

- high density but not cramped
- clear left edge
- source/service icon is useful but not decorative noise
- row separators are thin
- selected/read states should be subtle
- preserve scroll position

---

## 9.3 Tile Grid

Good for launchers, dashboards, settings, inventory, app hubs.

Tile rules:

- square rhythm
- label anchored bottom-left
- icon large but not cartoonish
- live content allowed
- accent tiles should be purposeful
- avoid over-rounding

---

## 9.4 Settings Page

Windows Phone-like settings should be plain and fast:

```txt
settings

theme
  system font mode        on
  accent color            blue
  motion                  full

gestures
  edge handoff            balanced
  swipe actions           confirm on release

developer
  show version stamp      on
  debug overlay           off
```

Use rows, toggles, and simple grouped sections. Do not make every setting a card.

---

## 9.5 Empty / Waiting / Death States

A Metro empty state should be sparse and typographic.

Example:

```txt
nothing here yet

pull down to refresh
```

Game waiting screen / death screen rules:

- put core message near top or strong visual anchor
- avoid modal card unless truly necessary
- use ambient background motion
- use command or key hint lower on screen
- red/error states should be vignette or accent, not full red blanket

---

## 10. Platform Implementation Guardrails

## 10.1 SvelteKit 2 + Svelte 5

Use when implementing web/Svelte mockups.

Defaults:

- SvelteKit 2
- Svelte 5 runes
- ESM
- minimal dependencies
- no `sv create` inside existing repos/routes
- route-local components are acceptable for mockups
- extract only after patterns stabilize
- CSS custom properties for Metro tokens
- static/prerender-first unless SSR is required

Svelte guidance:

```svelte
<script lang="ts">
  const pivots = ['social', 'history', 'account', 'settings'] as const;
  let active = $state(0);
</script>
```

Avoid stale variables like `active` if the local state is named `activeIndex`. Keep names boring and correct.

For static route mockups:

- make it compile first
- avoid over-abstracting
- use real arrays for data
- keep animation state local
- no giant dependency import for simple gestures
- use pointer events carefully
- keep keyboard/focus states

---

## 10.2 Android Jetpack Compose

Use when implementing Android/WP-like apps.

Defaults:

- Kotlin
- Jetpack Compose
- coroutines
- StateFlow for app state
- no blocking main thread
- 120 Hz-sensitive gestures
- respect cutouts/status bars
- OLED black
- large typography
- direct-manipulation gestures

Compose guidance:

- use `Modifier.pointerInput` for custom pivot/drag only when needed
- use `LazyColumn` for notification/feed lists
- use stable keys
- avoid recomposition storms
- keep network/disk off main
- isolate nested gesture surfaces
- test on high refresh devices

For notification shade replacements:

- overlay path first
- root/SystemUI hooks are advanced and should not be assumed
- gesture zone should respect notch and native shade interception
- diagnostics should explain blockers without nagging

---

## 10.3 Tauri / Desktop Shells

Use when building Windows-like shells, taskbars, widgets, or dashboard apps.

Rules:

- hidden UI must be inert
- focus-loss should close flyouts/menus/surfaces
- hover/focus should not resurrect hidden surfaces
- top-level shell state should own transient teardown
- avoid CSS-only masking of lifecycle bugs
- verify behavior by minimizing, alt-tabbing, focus loss, and mouse leave

---

## 11. Accessibility

Do not sacrifice accessibility for nostalgia.

Required:

- readable contrast
- visible focus states
- keyboard navigation
- semantic buttons
- labels for icon commands
- sufficient touch targets
- reduced motion mode
- screen-reader friendly row labels
- no information conveyed by color alone

Recommended minimums:

```txt
touch target: 44px+
body text:    16px+
metadata:     12–14px only if secondary
contrast:     WCAG AA where practical
```

---

## 12. Performance

This design lives or dies on motion smoothness.

Performance rules:

- target 60 fps minimum
- target 120 fps feel on capable devices
- transform/opacity for animation
- avoid layout thrash during drag
- virtualize long lists
- cache expensive measurements
- debounce resize/orientation work
- preserve scroll state
- keep shaders/WebGL separate from UI state if used
- reduce blur/backdrop filters on mobile

Do not ship a beautiful UI that feels like wet cardboard.

---

## 13. Screenshot / Image Recreation Rules

When recreating a Windows Phone-like UI from an image:

1. Identify the app type.
2. Describe the screen hierarchy.
3. Map major bounding boxes.
4. Extract typography scale.
5. Extract color/accent system.
6. Identify repeated components.
7. Identify active/inactive states.
8. Identify gesture/motion implications.
9. Rebuild layout first.
10. Add polish last.

### 13.1 Bounding Box Format

Use normalized percentages when dimensions are unknown.

```json
{
  "screen": "notification shade",
  "bounds": {
    "status_row": { "x": "0%", "y": "0%", "w": "100%", "h": "8%" },
    "quick_actions": { "x": "4%", "y": "9%", "w": "92%", "h": "22%" },
    "system_chips": { "x": "4%", "y": "32%", "w": "92%", "h": "7%" },
    "notification_list": { "x": "4%", "y": "40%", "w": "92%", "h": "52%" },
    "command_bar": { "x": "0%", "y": "92%", "w": "100%", "h": "8%" }
  }
}
```

### 13.2 Design Description Format

For each screen, provide:

```txt
Name:
Purpose:
Visual style:
Primary layout:
Navigation:
Gestures:
Components:
States:
Motion:
Assets/icons:
Implementation notes:
Risks:
Acceptance checklist:
```

---

## 14. Prompt Pack Template

Use this when generating a prompt pack for an agent.

```md
# Prompt Pack: [Project / Screen Name]

## Goal

Build a high-fidelity Windows Phone / Metro-inspired UI for [route/app/screen].

## Target

- Platform:
- Framework:
- Existing route/path:
- Do not scaffold:
- Do not rewrite unrelated files:
- Use existing project conventions:

## Visual Direction

- OLED black canvas
- large Segoe/Metro typography
- pivot/panorama layout
- thin dividers
- square tile rhythm where useful
- accent color: [color]
- minimal shadows
- no generic Material card soup
- no iOS glass unless explicitly requested

## Required Screens / Regions

1. [Region]
2. [Region]
3. [Region]

## Interaction Rules

- Pivots drag-follow the finger.
- Underline follows drag.
- Snap on release.
- Nested pivots own gestures before parent panorama.
- Swipe actions commit only on release.
- Expanded quick actions collapse before notification list scroll.
- Command bar stays reachable.

## Data / Static Mock Rules

- Use local mock arrays.
- Include enough rows to prove scrolling.
- Include image/media cases if relevant.
- Include empty/loading/error states when relevant.

## Implementation Rules

- Keep implementation local and compile-safe.
- Use boring state names.
- Do not introduce heavy dependencies.
- Preserve accessibility labels.
- Prefer transform/opacity animations.
- Respect safe areas and high-DPI scaling.

## QA Checklist

- Builds/compiles.
- No undefined variables.
- Keyboard focus visible.
- Touch targets are large enough.
- Pivot drag feels attached.
- Nested gestures do not fight.
- Reduced motion is respected.
- 4K and mobile widths both look intentional.
```

---

## 15. Paste-Ready Universal Agent Prompt

Use this prompt when asking an AI agent to create or revise a Windows Phone-like design.

```md
You are working as a senior UI/product engineer. Build or revise this UI using a Windows Phone / Metro / Lumia design language, modernized for 2026.

Core style:
- OLED black-first canvas.
- Large Segoe-like typography.
- Strong left alignment.
- Pivot/panorama navigation where tabs/categories are needed.
- Thin separators and clean rectangular geometry.
- Square tile rhythm where useful.
- Accent color used sparingly for selected, active, progress, and command states.
- Minimal shadows. Avoid generic Material cards, iOS glass, and random pill soup.
- Content-first: typography, layout, and motion should carry the interface.

Motion/gesture rules:
- Pivots must drag-follow the finger.
- Pivot underline should track the active/target label.
- Snap only on release with velocity-aware easing.
- Nested pivots own gestures before parent panorama.
- Edge handoff only happens at the bounds.
- Swipe actions commit only on release and must be cancelable.
- Expanded quick controls collapse before lower content scroll takes over.
- Prefer transform/opacity animation and avoid layout thrash.

Implementation rules:
- Do not scaffold a new app if this is an existing route/repo.
- Keep changes scoped.
- Use existing project conventions.
- Use local mock data for static UI.
- Keep state names simple and compile-safe.
- No heavy dependencies unless clearly justified.
- Preserve accessibility: labels, focus states, contrast, touch targets, reduced motion.
- Target smooth 60 fps minimum and 120 Hz feel where practical.

Required output:
1. Implement or describe the UI.
2. Include a compact component/state map.
3. Include responsive behavior.
4. Include accessibility notes.
5. Include a QA checklist.
6. Call out risks and what was intentionally not changed.
```

---

## 16. Design Review Checklist

Use this to judge whether the result actually feels Windows Phone-like.

### Visual

- [ ] OLED black or very dark base
- [ ] large confident typography
- [ ] strong left alignment
- [ ] thin dividers
- [ ] accent used sparingly
- [ ] square rhythm where useful
- [ ] no generic card soup
- [ ] no excessive rounded corners
- [ ] no random gradients
- [ ] no overdecorated sci-fi clutter

### Navigation

- [ ] top-level panorama makes sense
- [ ] local pivots make sense
- [ ] command bar is reachable
- [ ] settings are plain and usable
- [ ] empty/loading/error states exist

### Motion

- [ ] pivots track finger
- [ ] underline tracks drag
- [ ] release snap feels fast
- [ ] nested gestures do not fight
- [ ] swipe actions can cancel
- [ ] reduced motion works

### Implementation

- [ ] compiles
- [ ] no undefined variables
- [ ] no stale imports
- [ ] no scaffold pollution
- [ ] no unrelated rewrites
- [ ] responsive at phone/tablet/desktop
- [ ] long lists are virtualized or cheap
- [ ] focus states visible
- [ ] touch targets large

---

## 17. Anti-Patterns

Reject or revise these:

- “Metro” design with tiny type.
- Everything in rounded Material cards.
- Random glass blur over black background.
- Pivot labels that do not move with content.
- Swipe actions that commit before release.
- Parent panorama stealing child pivot gestures.
- Debug UI mixed into final visuals.
- Giant fake sci-fi panels with no product meaning.
- Icon-only controls with no labels.
- Beautiful screenshot that cannot compile.
- Overbuilt architecture for a static mockup.
- Starting a new scaffold inside an existing repo.

---

## 18. Recommended Output Modes

### 18.1 For a Quick Design Description

Return:

```txt
Visual read:
Layout:
Components:
Motion:
Implementation notes:
Risks:
```

### 18.2 For a Build Prompt

Return:

```txt
Goal:
Target route/files:
Visual language:
Required sections:
Interactions:
Data:
Constraints:
Acceptance checklist:
```

### 18.3 For an Implementation

Return:

1. code first
2. commands
3. verification
4. notes/risks

### 18.4 For a Package / Handoff

Include:

- README
- skill or prompt
- design spec
- checklist
- `.thoughts`
- examples
- screenshots or references if available

---

## 19. Final Standard

A good result should make the user think:

> “This feels like Windows Phone came back, but not like a cheap theme. It feels fast, clean, readable, useful, and modern.”

If it only looks vaguely dark with blue buttons, it failed.

If the pivots do not feel touch-native, it failed.

If the design cannot compile or be implemented without a rewrite, it failed.

If the UI has no product hierarchy, it failed.

Build the thing with restraint. Metro is not decoration. It is structure.
