---
name: pixelboats-fish-water-ecology
description: Project-level PixelBoats skill for integrating fish schools, water interaction, ripples/splashes, food pickups, seagull/shark ecology hooks, and the giant fish net feature with debug-first WebGL2 architecture.
version: 0.1.1
status: project-canonical
project: PixelBoats
tags:
  - pixelboats
  - game-ecology
  - fish-schools
  - webgl2
  - water-effects
  - performance
  - handoff
  - grill-me
provenance_origin: "original"
provenance_source_path: "04_skills/agent-skills/skills/pixelboats-fish-water-ecology/SKILL.md"
provenance_credit: "Ryan Spice-Finnie"
provenance_ingested_as: "ryanspice/agent-skills owned skill"
provenance_note: "Original AI Wiki local skill credited to Ryan Spice-Finnie."

---

# PixelBoats Fish Water Ecology Skill

Use this skill when planning, implementing, or reviewing the fish-water ecology feature.

## Scope

This skill covers:

- fish school aggregate simulation;
- representative fish agents near player/camera;
- fish breach/skim/submerge behavior;
- water interaction events;
- ripples, splash particles, water impulses, debug surface distortion;
- fish landing on boat to grant food;
- giant fish net item/perk;
- seagulls/sharks responding to fish-school interest;
- debug-first WebGL2 integration.

It does not cover flamingo/easter-egg/sprite-sheet work.

## Required Reading

Before implementation, read:

```txt
docs/fish-water-ecology/FEATURE_PLAN_AND_MATRIX.md
docs/fish-water-ecology/NEXT_CHAT_HANDOFF_fish-water-ecology.md
docs/fish-water-ecology/GRILL_ME_QUESTIONS_fish-water-ecology.md
docs/fish-water-ecology/SETTINGS_BASELINE.json
docs/fish-water-ecology/references/fish-water-interaction.reference.html
```

Also read project-level state:

```txt
.thoughts
FEATURE_MATRIX.md
NEXT_CHAT_HANDOFF.md
```

## Handoff Discipline

When handing off:

- keep the handoff compact;
- reference existing docs and changed files;
- do not duplicate full matrices/plans/ADRs;
- state the next concrete action;
- list unresolved decisions only.

## Grill-Me Discipline

When a design choice is unclear:

- ask one question at a time;
- provide your recommended answer;
- if repo exploration can answer it, inspect the repo instead;
- do not use questions to stall obvious Phase 1 work.

## Implementation Order

1. School aggregate data.
2. Map/spawn integration.
3. Drift and avoidance.
4. Box debug rendering.
5. Water event emission.
6. Breach/skim behavior.
7. Food pickup.
8. Giant net.
9. Seagulls/sharks.
10. Sprite and shader polish.

## Hard Rules

- Box debug mode first.
- Do not simulate every fish globally.
- No hot-path allocations.
- No full-world scans.
- No heavy dependencies.
- Do not rewrite water rendering in Phase 1.
- Use existing game loop, water, collision, and spawn patterns where possible.
- Landing splash should depend primarily on entry angle, then velocity and scale.

## Architecture Target

```txt
FishSchoolSystem
WaterSurfaceSystem
WaterInteractionEmitter
FishWaterRenderer
```

Fish behavior emits events. Water/render systems consume them.

## Performance Tiers

| Tier | Simulation |
|---|---|
| Dormant | aggregate school only |
| Ambient | low-frequency school update |
| Active | representative fish agents |
| Interaction | collision, food/net, water events |

## Review Checklist

- [ ] School data is aggregate-first.
- [ ] Debug render proves school position/radius/density.
- [ ] Water sample is single source of truth.
- [ ] Ripples/splash particles are pooled or capped.
- [ ] Landing angle affects splash power.
- [ ] Fish-food pickup is event-driven.
- [ ] Seagulls/sharks consume school-interest events.
- [ ] Giant net has cooldown/caps.
- [ ] Existing boat/water/collision behavior is not regressed.
