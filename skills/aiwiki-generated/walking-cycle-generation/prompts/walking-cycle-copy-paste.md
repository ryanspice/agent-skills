# Walking Cycle Generation — Copy/Paste Prompts

## GPT-5.5 Planning Prompt

```text
Use the Walking Cycle Generation skill.

I need a production-usable walking cycle, not an idle bounce pretending to walk.

First, do not generate final art. Make a frame-by-frame gait plan.

Character:
[describe character]

View:
[front-facing / side-facing / 3/4 / direction]

Frame count:
[5 or 8]

Hard requirements:
- Treat the walk as an alternating left/right gait state machine.
- Assign persistent foot identities: L_FOOT and R_FOOT.
- Contact A and Contact B must use opposite forward feet.
- The planted foot must not slide during support frames.
- The shared ground baseline must be preserved.
- Body height must follow contact/down/passing/up/contact.
- Arms must counter-swing opposite the legs unless the arms are not visible.
- Preserve exact character identity across frames.

Output a table with:
Frame, Pose Name, L_FOOT State, R_FOOT State, Body Height, Arm Swing, Planted Foot Lock, Loop Note.

After the table, include a failure checklist and explicitly state whether the cycle is safe to render.
```

## Image Generation Prompt

```text
Create a single horizontal pixel-art walking-cycle sprite sheet.

This is a gait-accurate animation task, not a random pose sheet.

Character:
[describe character]

Frame count:
8 frames, one row

Canvas:
- transparent PNG
- fixed cell width
- fixed cell height
- one character per cell
- bottom-center aligned
- same shared foot baseline in every frame
- no labels, no grid, no background, no shadow, no props, no UI

Character consistency:
- preserve the same face, proportions, palette, outfit, outline thickness, and pixel-art style in every frame
- do not redraw the character differently between frames

Foot identity contract:
- internally label the character's feet as L_FOOT and R_FOOT
- do not swap foot identity mid-cycle
- do not use the same forward foot for both contact poses
- do not let the planted foot slide during support frames

Required frame sequence:
Frame 01: Contact A — L_FOOT forward contact, R_FOOT rear toe/contact, body neutral
Frame 02: Down A — L_FOOT planted and weighted, R_FOOT beginning lift, body lowest
Frame 03: Passing A — L_FOOT planted, R_FOOT passing under body, body rising
Frame 04: Up A — L_FOOT pushing off, R_FOOT swinging forward, body highest
Frame 05: Contact B — R_FOOT forward contact, L_FOOT rear toe/contact, body neutral
Frame 06: Down B — R_FOOT planted and weighted, L_FOOT beginning lift, body lowest
Frame 07: Passing B — R_FOOT planted, L_FOOT passing under body, body rising
Frame 08: Up B — R_FOOT pushing off, L_FOOT swinging forward, body highest

Loop rule:
Frame 08 must flow naturally back to Frame 01.
Do not include a duplicated ninth frame.

Final verification before output:
1. Contact A has L_FOOT forward.
2. Contact B has R_FOOT forward.
3. Planted feet do not slide.
4. Ground baseline is stable.
5. Body height changes are readable.
6. Character identity is unchanged.
```

## Repair Prompt

```text
Use the Walking Cycle Generation skill to repair this animation.

Failure observed:
[example: same foot leads twice / planted foot slides / feet float / frame 5 does not loop / body only bounces]

Repair only the gait mechanics.

Do not redraw the character from scratch.
Do not change the face, outfit, palette, proportions, outline, or style.
Do not add props, text, labels, grid lines, background, shadows, or extra frames.

Required fixes:
- Contact A and Contact B must show opposite forward feet.
- Preserve persistent L_FOOT and R_FOOT identity.
- Lock planted foot during support frames.
- Keep one shared ground baseline.
- Adjust body height to contact/down/passing/up/contact.
- Preserve bottom-center alignment and fixed cell size.
- Make the final frame loop cleanly back to Frame 01.
```

## One-Line Agent Reminder

```text
Do not accept the walk cycle unless Contact A and Contact B prove opposite-foot alternation and the planted foot does not slide.
```
