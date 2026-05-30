---
name: walking-cycle-generation
description: Use this skill when generating, editing, critiquing, or prompt-engineering walking animations, sprite sheets, or frame-by-frame character motion.
version: 0.1.0
status: generated
type: generated-agent-skill
risk: medium
tags: ["animation", "walk-cycle", "sprite", "sprite-sheets", "pixel-art"]
created_at: 2026-05-22
provenance_origin: "original"
provenance_source_path: "04_skills/generated/walking-cycle-generation/SKILL.md"
provenance_credit: "Ryan Spice-Finnie"
provenance_note: "Original AI Wiki generated skill credited to Ryan Spice-Finnie."

---

# Walking Cycle Generation Skill

Use this skill when generating, editing, critiquing, or prompt-engineering walking animations, sprite sheets, or frame-by-frame character motion.

The goal is to prevent fake walk cycles where the same foot repeats, both feet slide, the body floats, or the model redraws the character differently each frame.

## Core Rule

A walk cycle is not "several similar poses."

A walk cycle is an alternating left/right gait state machine.

Every frame must preserve:

- character identity
- left foot identity
- right foot identity
- planted-foot contact
- ground baseline
- body weight transfer
- consistent proportions
- consistent sprite cell size
- consistent camera/view angle

If left/right foot identity cannot be tracked, stop and make a labeled planning pass first.

## Required Gait Labels

Before generating final art, assign each foot a persistent identity:

- `L_FOOT`: character's left foot
- `R_FOOT`: character's right foot

Do not describe feet only as "front foot" and "back foot" unless also naming whether that foot is `L_FOOT` or `R_FOOT`.

Bad:

- front foot forward
- back foot lifted
- same pose again

Good:

- Frame 01: `L_FOOT` forward contact, `R_FOOT` rear toe contact
- Frame 03: `R_FOOT` passes under body while `L_FOOT` remains planted
- Frame 05: `R_FOOT` forward contact, `L_FOOT` rear toe contact

## Minimal 5-Key Walk Cycle

For a simple front-facing or side-facing cycle, use this as the minimum structural plan:

| Frame | Pose | Foot State | Body State |
|---:|---|---|---|
| 01 | Contact A | `L_FOOT` forward contact, `R_FOOT` rear contact | neutral height |
| 02 | Down A | `L_FOOT` planted/weighted, `R_FOOT` beginning lift | lowest body point |
| 03 | Passing A | `L_FOOT` planted, `R_FOOT` passing under body | rising |
| 04 | Up A | `L_FOOT` pushing off, `R_FOOT` swinging forward | highest body point |
| 05 | Contact B | `R_FOOT` forward contact, `L_FOOT` rear contact | neutral height |

A complete seamless loop mirrors the same logic back:

| Frame | Pose | Foot State | Body State |
|---:|---|---|---|
| 06 | Down B | `R_FOOT` planted/weighted, `L_FOOT` beginning lift | lowest body point |
| 07 | Passing B | `R_FOOT` planted, `L_FOOT` passing under body | rising |
| 08 | Up B | `R_FOOT` pushing off, `L_FOOT` swinging forward | highest body point |
| 09 | Contact A duplicate/check | Same as Frame 01 | loop closure only |

For sprite sheets, usually export Frames 01-08 and let the engine loop back to Frame 01. Do not include Frame 09 unless the target tool requires a duplicated loop frame.

## 16-Direction Rule

For 16-direction walking, do not ask the model to invent all directions at once.

Generate or plan each direction as a separate gait contract:

- N
- NNE
- NE
- ENE
- E
- ESE
- SE
- SSE
- S
- SSW
- SW
- WSW
- W
- WNW
- NW
- NNW

For each direction:

1. preserve the same character design
2. preserve the same frame count
3. preserve the same gait phase order
4. preserve the same left/right foot identity
5. preserve the same baseline and cell dimensions
6. only rotate/reinterpret the body orientation, not the gait logic

Never generate 16 directions as "sixteen random walking poses." That creates unusable animation sludge.

## Anti-Failure Rules

Reject or revise output if any of these happen:

- same foot is forward in both contact poses
- both contact poses look nearly identical
- planted foot slides horizontally during its support phase
- feet swap identity mid-cycle
- knees bend without a matching body height change
- body bobs randomly instead of down-after-contact and up-after-passing
- arms do not counter-swing against legs, unless intentionally disabled
- character redraws with different face, clothing, proportions, outline, or pose style
- sprite cells have inconsistent padding
- feet do not share the same ground baseline
- final frame does not loop cleanly back to first frame

## Planted Foot Lock

During support phase, the planted foot is locked to the ground.

Example:

- If `L_FOOT` is planted in Frames 02-03, its sole/heel contact point must stay visually anchored.
- The body may travel over it.
- The opposite foot may lift, pass, and swing.
- The planted foot must not slide unless the animation is intentionally stylized as skating.

This rule matters more than pretty posing.

## Body Height Contract

Use body height to show weight:

- Contact: neutral
- Down: lowest point, weight absorbed
- Passing: rising through center
- Up: highest point, push-off
- Opposite contact: neutral

Do not make every frame the same height. That is a shuffle, not a walk.

## Arm Swing Contract

Unless the character has no visible arms:

- `L_ARM` swings opposite `L_FOOT`
- `R_ARM` swings opposite `R_FOOT`
- when `L_FOOT` is forward, `R_ARM` is forward
- when `R_FOOT` is forward, `L_ARM` is forward

Keep arm swing smaller than leg motion unless stylized.

## Pixel Art Sprite Sheet Requirements

When generating a sprite sheet:

- transparent PNG
- fixed cell width
- fixed cell height
- one character per cell
- bottom-center aligned
- shared foot baseline
- no labels in final image
- no grid in final image
- no shadows unless explicitly requested
- no background
- no camera angle change
- no style variation between frames

For drafting/debugging, a labeled planning sheet is allowed. For final export, remove labels.

## Recommended Generation Workflow

Use three passes.

### Pass 1: Gait Plan

Create a text-only frame table.

Must include:

- frame number
- pose name
- `L_FOOT` state
- `R_FOOT` state
- body height
- arm swing
- planted foot lock
- loop note

Do not generate art yet.

### Pass 2: Rough Pose Sheet

Generate a rough or simple visual pose sheet.

Prioritize:

- left/right foot alternation
- baseline
- silhouette readability
- body height
- loop continuity

Do not add detail yet.

### Pass 3: Final Sprite Sheet

Only after the gait is correct, generate final art.

Preserve:

- exact character identity
- exact outfit/design
- exact palette
- exact outline thickness
- exact proportions
- exact sprite scale
- exact cell size

## Default Prompt Template

Use this prompt when asking GPT-5.5 or an image model to create a walking cycle.

```text
Create a proper frame-by-frame walking cycle as a gait state machine, not as unrelated poses.

Character:
[describe character]

View direction:
[front-facing / side-facing / 3/4 / direction name]

Frame count:
[5, 8, or custom]

Output:
[sprite sheet / frame table / critique / revised prompt]

Critical constraints:
- preserve persistent left/right foot identity across all frames
- label feet internally as L_FOOT and R_FOOT
- do not reuse the same forward foot for both contact poses
- do not let the planted foot slide during support
- keep all feet aligned to one shared ground baseline
- keep the same character identity, proportions, palette, outline, and camera angle
- use fixed cell width and fixed cell height
- bottom-center align every frame
- transparent background if generating final art

Required gait sequence:
Frame 01: Contact A — L_FOOT forward contact, R_FOOT rear toe/contact, body neutral
Frame 02: Down A — L_FOOT planted and weighted, R_FOOT beginning lift, body lowest
Frame 03: Passing A — L_FOOT planted, R_FOOT passing under body, body rising
Frame 04: Up A — L_FOOT pushing off, R_FOOT swinging forward, body highest
Frame 05: Contact B — R_FOOT forward contact, L_FOOT rear toe/contact, body neutral

If making an 8-frame loop:
Frame 06: Down B — R_FOOT planted and weighted, L_FOOT beginning lift, body lowest
Frame 07: Passing B — R_FOOT planted, L_FOOT passing under body, body rising
Frame 08: Up B — R_FOOT pushing off, L_FOOT swinging forward, body highest

Loop rule:
Frame 08 must flow cleanly back into Frame 01.
Do not include a duplicated Frame 09 unless requested.

Before final output, verify:
1. Contact A and Contact B use opposite forward feet.
2. The planted foot remains locked during support frames.
3. Body height follows neutral/down/rising/up/neutral.
4. Arms counter-swing opposite legs.
5. No frame redraws the character differently.
```

## Critique Checklist

When reviewing a generated walking cycle, answer:

1. Which foot is forward in Contact A?
2. Which foot is forward in Contact B?
3. Are they opposite feet?
4. Which frames have a planted foot?
5. Does the planted foot slide?
6. Does the body go down after contact?
7. Does the body rise after passing?
8. Do arms counter-swing?
9. Is the ground baseline stable?
10. Does the final frame loop into the first frame?

If any answer is unclear, the cycle is not production-ready.

## Repair Prompt Template

Use this when a model gives broken frames.

```text
Repair this walking cycle. Do not redraw the character from scratch.

The current failure is:
[describe failure]

Fix only the gait mechanics:
- preserve the exact character design
- preserve the same sprite size and art style
- keep the shared foot baseline
- keep bottom-center alignment
- make Contact A and Contact B use opposite forward feet
- lock the planted foot during support frames
- adjust body height to neutral/down/passing/up/neutral
- make the arms counter-swing opposite the legs
- keep the output as [same format]

Do not add props, text, labels, background, shadows, or extra frames.
```

## One-Direction Front-Facing Special Case

Front-facing walks are harder because left/right depth is subtle.

For front-facing animation:

- exaggerate foot position with small left/right offsets
- show one knee/foot slightly forward/lower
- keep shoulders and hips counter-tilting
- make contact poses visibly different
- do not rely only on vertical bobbing

A front-facing walk with identical feet and only body bounce is not acceptable.

## Final Rule

Never accept a walking cycle until the contact poses prove foot alternation.

If the two contact poses do not show different feet leading, the animation is fake.
