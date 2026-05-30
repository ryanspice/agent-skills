---
name: sprite-pixel-art-sprite-sheets-gpt55
description: Use this skill when working with sprite concepts, pixel-art character sheets, sprite sheets, animation frames, UI assets derived from pixel art, and GPT-5.5-assisted art-direction or prompt engineering.
version: 0.1.0
status: generated
type: generated-agent-skill
risk: medium
tags: ["sprite", "pixel-art", "sprite-sheets", "animation", "art-direction", "gpt55"]
created_at: 2026-05-22
provenance_origin: "original"
provenance_source_path: "04_skills/generated/sprite-pixel-art-sprite-sheets-gpt55/SKILL.md"
provenance_credit: "Ryan Spice-Finnie"
provenance_ingested_as: "ryanspice/agent-skills owned skill"
provenance_note: "Original AI Wiki generated skill credited to Ryan Spice-Finnie."

---

# Sprite, Pixel Art, Sprite Sheets, and GPT-5.5 Skill

Use this skill when working with sprite concepts, pixel-art character sheets, sprite sheets, animation frames, UI assets derived from pixel art, and GPT-5.5-assisted art-direction or prompt engineering.

This skill is for making GPT-5.5 useful in a sprite pipeline instead of letting it hallucinate pretty garbage that cannot ship.

## Core Position

GPT-5.5 is best used as:

- a planner
- a constraint writer
- a prompt engineer
- a frame-by-frame critic
- a repair/cleanup director
- an asset-pipeline organizer

GPT-5.5 is not trustworthy as a freeform one-shot sprite-sheet generator when exact continuity matters.

Treat the model as a director and QA brain, not as a magical pixel-perfect production artist.

## What We Found Out

### 1. Split the work into passes

Do not ask for everything at once.

Preferred passes:

1. intent and constraints
2. structural planning
3. rough frames or rough sheet
4. targeted repair / cleanup
5. deterministic assembly
6. QA and critique

### 2. Exactness beats vibes

If you need production-usable sprites, specify:

- frame count
- cell width and height
- transparent background
- view angle
- baseline
- bottom-center alignment
- palette constraints
- outline thickness
- no restyling
- no extra props/background/UI
- same character identity in every frame

### 3. Assembly is its own task

When approved frames already exist, do not ask for a new sprite sheet as if it were a fresh illustration.

Say:

- assembly task only
- use exact uploaded frame artwork
- do not redraw or reinterpret
- preserve exact identity and style
- align all frames to bottom center
- use one transparent PNG sprite sheet

### 4. Walking cycles need gait logic

For walks, require a gait contract, not "5 cool frames".

Use:

- Contact A
- Down A
- Passing A
- Up A
- Contact B
- then the opposite-side continuation if using 8 frames

Always preserve persistent left/right foot identity.

### 5. Use GPT-5.5 as critic after generation

After any generated frame set, ask GPT-5.5 to critique:

- frame-to-frame consistency
- baseline drift
- palette drift
- outline drift
- limb identity drift
- missing transparency cleanup
- looping continuity
- duplicate-pose failure

### 6. Use code or deterministic tools for normalization

When exact layout matters, prefer a deterministic follow-up step.

Examples:

- align frames by bottom baseline
- normalize cell size
- strip accidental background pixels
- order frames correctly
- assemble sprite sheets
- preview animation

GPT-5.5 should define or review the process, but exact pixel placement may be better handled by code or a constrained image-edit step.

## Recommended Workflow

### Lane A — New Sprite Concept

Use when you need a new character or object sheet.

1. make a style brief
2. make a sheet spec
3. generate a single direction or pose family first
4. review consistency
5. expand directions or animations only after approval

### Lane B — Animation Pass

Use when the base character already exists.

1. define the exact animation
2. define the key poses
3. generate rough motion
4. repair continuity and anchors
5. assemble sheet
6. preview loop

### Lane C — Exact Sheet Assembly

Use when frames are already approved.

1. gather approved frames
2. confirm order
3. normalize dimensions and alignment
4. assemble
5. export transparent sheet
6. test in playback

### Lane D — Pixel UI / Asset Extraction

Use when recreating UI from source images.

1. inspect source image
2. identify reusable assets and tile regions
3. reconstruct via code or deterministic slicing when possible
4. only generate missing pieces
5. preserve the source look

## Standard Prompting Rules

Always include:

- the task type
- output format
- exact constraints
- forbidden changes
- review checklist

### Good task type labels

- concept sheet task
- animation planning task
- assembly task only
- cleanup task only
- critique task only
- repair task only

These labels stop the model from trying to do every job badly.

## Failure Modes to Watch For

Reject or revise output if you see:

- style drift
- character face drift
- palette drift
- baseline drift
- frame order confusion
- same foot leading twice in walk cycles
- inconsistent outline thickness
- stray background pixels or halos
- smeared details mistaken for antialiasing
- the model inventing extra props or scenery
- random camera-angle changes
- inconsistent sprite padding

## Acceptance Checklist

Before accepting a sprite output, verify:

1. Is the output type correct?
2. Is the frame count correct?
3. Are the cells a consistent size?
4. Is the baseline stable?
5. Is the view angle consistent?
6. Is transparency clean?
7. Is the palette stable?
8. Is the character identity preserved?
9. Is the frame order correct?
10. Does the animation actually loop?

## Default Deep Research Plan

When researching sprites, pixel art, sprite sheets, and GPT-5.5 workflows, gather answers for:

1. Where GPT-5.5 helps most in the asset pipeline
2. Where direct image generation fails most often
3. What prompt structure yields the best continuity
4. What deterministic cleanup or assembly steps should follow generation
5. What QA checks catch production-breaking issues fastest
6. Which tasks should be split into separate prompts or tools

## Recommended Deliverables for Future Research Packs

A good pack should contain:

- one canonical skill
- one research summary note
- one project note for PixelBoats if relevant
- copy-paste prompts
- a critique checklist
- a repair checklist
- optional deterministic helper script later

## Copy-Paste Engage Prompt

```text
Use the Sprite, Pixel Art, Sprite Sheets, and GPT-5.5 skill.

Act as a pixel-art pipeline director and critic, not a freeform art generator.

Goal:
[describe the asset or animation goal]

Task type:
[concept sheet / animation planning / assembly only / cleanup only / critique only / repair only]

Output format:
[frame table / prompt pack / sprite sheet brief / critique report / repair instructions]

Hard constraints:
- preserve consistent character identity
- preserve palette and outline style
- preserve frame sizing and alignment
- do not invent extra scenery or props unless requested
- be explicit about frame order and baseline
- separate generation from assembly when exactness matters

First, restate the pipeline in passes.
Then produce the best working spec and prompts.
Then produce the QA checklist.
```
