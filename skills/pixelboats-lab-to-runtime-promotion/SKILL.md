---
name: pixelboats-lab-to-runtime-promotion
description: "Standard contract for migrating a system from /lab prototype to /game runtime. Extract the minimal stable boundary — never merge entire labs. Covers runtime engine integration (not GUI pipeline — see pixelboats-gui-promotion for that)."
version: 0.1.0
status: candidate
type: project-agent-skill
risk: high
tags: ["pixelboats", "promotion", "lab-to-game", "runtime", "integration", "migration"]
project: pixelboats
created_at: 2026-07-21
metadata:
  review_status: staged-candidate
  reviewers: [Nemotron, Vibethinker]
  replaces: none
  conflicts_with: none
  related_skills: [pixelboats-gui-promotion, pixelboats-authority-resolution, pixelboats-stage-verification]
---

# PixelBoats Lab-to-Runtime Promotion

Load this skill before migrating any system from a `/lab` prototype into the `/game` canonical runtime. This covers **runtime engine integration** — audio, physics, AI, simulation engines. For GUI/UI promotion, see `pixelboats-gui-promotion`.

## Core Rule

> **Extract the minimal stable boundary. Never merge entire labs.**

The lab remains as an experimentation and authoring surface. Only the production-ready interface moves to runtime.

## Required Contract Fields

Every promotion must document:

### 1. Ownership
- **Lab owner:** Where the prototype lives (e.g., `src/routes/(lab)/lab/aurora-audio/`)
- **Runtime owner:** Where the canonical runtime will live (e.g., `src/lib/pixelboats/audio/`)
- **Authority boundary:** What this system OWNS vs what it READS from other authorities
- **Interface name:** The stable public API (e.g., `AudioDirector`, `PhysicsWorld`)

### 2. Game Events Consumed
```typescript
// Example: AudioDirector consumes these game events
type ConsumedEvents = {
  'cannon:fired': { position: Vec2; caliber: number };
  'ship:collision': { impulse: number; material: 'wood' | 'rock' };
  'weather:changed': { windSpeed: number; seaState: number };
};
```

### 3. Lifecycle Hooks
```typescript
interface RuntimeLifecycle {
  initialize(): Promise<void>;   // Called once on /game mount
  start(): void;                 // Called on user gesture / game start
  suspend(): void;               // Called on tab blur / pause
  resume(): void;                // Called on tab focus / unpause
  destroy(): void;               // Called on /game unmount — MUST clean up
}
```

### 4. Settings & Persistence
- What settings does the runtime expose?
- Where are they stored (localStorage, gameSettings store)?
- What are the safe defaults?

### 5. Error Handling
- What errors can occur at runtime?
- How are they surfaced (console, HUD, silent fallback)?
- What is the degraded mode when resources fail to load?

### 6. Teardown Verification
- **No leaked AudioContexts.** Verify `audioContext.close()` on destroy.
- **No leaked WebGL contexts.** Verify `loseContext()` or equivalent.
- **No orphaned event listeners.** Verify `removeEventListener` for every `addEventListener`.
- **No running timers.** Verify `clearInterval`/`clearTimeout` for every `setInterval`/`setTimeout`.
- **Memory growth test.** Mount → unmount 5 times, observe heap. Should return to baseline.

### 7. Runtime Tests
- Focused test covering the stable interface
- Teardown verification script
- Performance budget check (frame time impact)

### 8. Performance Budget
- Target frame budget (e.g., <2ms per frame for audio)
- Startup cost (e.g., <500ms initialize)
- Memory budget (e.g., <50MB for audio buffers)

### 9. Browser/Device Constraints
- Minimum supported browsers
- AudioContext limits (mobile Safari requires user gesture)
- Web Worker availability
- WASM support requirement

### 10. Lab Retention
- **Lab code retained:** What stays in `/lab` for continued experimentation?
- **Lab code retired:** What gets archived?
- **Rollback process:** If runtime integration breaks, how does /game fall back?

## Promotion Checklist

Before committing:

- [ ] Stable interface defined and typed
- [ ] Runtime owner directory created under `src/lib/pixelboats/`
- [ ] Lifecycle hooks wired to /game mount/unmount
- [ ] All game events mapped to interface methods
- [ ] Teardown verified (no leaked contexts, listeners, timers)
- [ ] Performance measured and within budget
- [ ] Error handling tested (resource load failure, missing API)
- [ ] Lab code retained for experimentation
- [ ] Suite registry updated (lab status may change to `frozen`)
- [ ] Rollback instructions written

## What NOT to Do

- **Do not** copy the entire lab directory into runtime
- **Do not** import lab components directly into /game
- **Do not** remove the lab route (unless the owner explicitly requests archival)
- **Do not** create a second authority for the same data
- **Do not** skip teardown verification — it's the #1 source of memory leaks
