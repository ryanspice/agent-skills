---
name: windows-phone-metro-design
version: 1.1.0
type: universal-agent-skill
status: active
risk: low
description: Creates, critiques, and implements Windows Phone, Metro, Lumia, Zune, Pivot, Panorama, Action Center, command-bar, tile-grid, and OLED black UI designs. Use when the user asks for Windows Phone-like design, Metro UI, WP8/WP10/Lumia/Zune styling, mobile shell layouts, SvelteKit/Compose/Tauri implementations, screenshot recreation, prompt packs, asset packs, or QA of Metro-inspired UI.
tags: ["ui", "metro", "windows-phone", "lumia", "sveltekit", "compose", "tauri"]
---

# Windows Phone / Metro Design Skill

Use this skill when the user wants UI/UX, implementation, prompts, screenshots, assets, QA, or app-shell direction inspired by Windows Phone, Metro, Lumia, Zune, Baconit-era apps, Pivot/Panorama navigation, Action Center, command bars, live tiles, or OLED black mobile/desktop shells.

This is not a nostalgia skin. Treat it as a modern product design system: content-first, typographic, touch-native, fast, accessible, and implementation-ready.

## Load only what is needed

Read these files only when the task needs them:

- `references/design-language.md` — visual language, typography, spacing, colors, tiles, rows, settings.
- `references/navigation-motion.md` — Pivot/Panorama behavior, drag-follow, gesture ownership, command bars, Action Center.
- `references/platform-implementation.md` — SvelteKit 2/Svelte 5, Android Compose, Tauri, performance/a11y guardrails.
- `references/screenshot-recreation.md` — how to describe/recreate screenshots, including bounding boxes and image-to-asset notes.
- `references/prompt-pack-template.md` — prompt-pack structure and paste-ready agent prompt.
- `references/qa-checklists.md` — acceptance criteria, anti-patterns, trigger tests, regression checks.
- `examples/example-outputs.md` — examples of compact design reads, implementation prompts, and QA reviews.
- `evals/trigger-evals.json` — trigger/near-miss examples for improving the skill description.

Do not load every file by default. Pick the smallest useful reference set.

## First response behavior

1. Identify the task type:
   - design description
   - UI implementation
   - prompt pack
   - screenshot recreation
   - asset pack
   - QA/review
   - platform-specific fix
2. If the task is simple, answer directly.
3. If implementation is requested, prefer code-first output, then commands, then verification.
4. If generating a prompt pack, produce a reusable prompt and checklist.
5. If reviewing a screenshot, describe what is visibly wrong before prescribing changes.
6. If creating files, include a compact README/checklist and version notes.

## Default design standard

The UI should feel:

- black/OLED-first
- typographic
- spacious but not empty
- fast
- direct-manipulation/touch-native
- left-aligned
- useful before decorative
- modernized Windows Phone, not generic dark Material

## Required Metro principles

Always favor:

- large Segoe-like type
- strong left alignment
- Pivot/Panorama navigation for categories
- command bars for primary actions
- thin dividers instead of card soup
- square tile rhythm where useful
- accent color for selected/active/progress states
- motion that follows the finger
- low-friction touch targets
- clear state restoration and scroll persistence

Reject or revise:

- generic Material cards everywhere
- random gradients and border-glow decoration
- giant rounded pills as the main design language
- icon-only mystery controls
- fake glass/iOS blur unless explicitly requested
- tiny type pretending to be Metro
- parent gestures stealing child gestures
- swipe actions committing before release
- pretty mockups that cannot compile

## Output modes

### Design read

Return:

```txt
Visual read:
Hierarchy:
Components:
Motion:
Implementation notes:
Risks:
```

### Implementation prompt

Return:

```txt
Goal:
Target route/files:
Visual language:
Required sections:
Interactions:
Data/mock state:
Constraints:
Acceptance checklist:
```

### Code implementation

Return:

1. targeted code or file content
2. Windows PowerShell commands when useful
3. verification command/checklist
4. known risks

### QA/review

Group by severity:

```txt
P0 broken/blocks usage:
P1 design/interaction regressions:
P2 polish:
Do now:
```

## Platform defaults

When not otherwise specified:

- Web: SvelteKit 2 + Svelte 5 runes, TypeScript, ESM, minimal dependencies.
- Android: Kotlin + Jetpack Compose, StateFlow/coroutines, no blocking main thread.
- Desktop shell: Tauri/Svelte, transient surfaces must close on focus loss and hidden UI must be inert.
- Styling: CSS variables/tokens, OLED black, thin dividers, restrained accent.
- Tests: lean compile/build/smoke checks first; avoid ceremony.

## Accessibility and performance floor

Never trade these away:

- readable contrast
- visible focus states
- keyboard navigation where relevant
- semantic controls and labels
- 44px+ touch targets where practical
- reduced motion accommodation
- transform/opacity animation over layout thrash
- long-list virtualization or cheap rendering
- 60 fps minimum target; 120 Hz feel where practical

## When unsure

Prefer a small, useful Metro correction over a large redesign. Fix hierarchy, typography, gesture ownership, and compile safety before decoration. If an implementation gets messy, reduce scope and ship the next concrete move.
