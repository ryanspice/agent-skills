# Blender MCP progress

Status: **unfinished**. Branch: `unfinished/blender-mcp`.

Source: `ryanspice/agent-skills`, `skills/blender-mcp/`.
Eventual canonical Wiki location:
`<AI_WIKI_ROOT>/04_skills/agent-skills/skills/blender-mcp/`.
While this branch is isolated, use its checkout under
`<AI_WIKI_ROOT>/04_skills/agent-skills-branches/unfinished-blender-mcp/`.

## Checklist

- [x] Create a dedicated branch from main inside AI Wiki; preserve unrelated
  changes in the existing canonical checkout.
- [x] Author the general Blender MCP workflow with an unfinished status.
- [x] Add single-instance/server reuse, patient readiness checks, and protection
  against duplicate launches or retries after uncertain results.
- [x] Add the branch-first skill authoring rule to repository guidance.
- [x] Pass skill structure, provenance, public-path, and repository checks.
- [x] Push the branch and verify its remote commit.
- [x] Replace the earlier standalone harness copy with a link to this source.
- [x] Deliver the exact skill and branch instructions to the requested target
  conversation; keep delivery separate from the recipient's completion.
- [x] On the target machine, fetch the branch and confirm the received skill
  matches its Git commit. Preserve a dirty checkout; use a separate checkout
  if needed.
- [x] Verify one Blender instance and one MCP server, then a successful MCP
  readiness call on the target machine.
- [ ] Observe a slow startup/file load and an uncertain timeout without a
  duplicate launch or mutation; record evidence from real use or a safe fixture.
- [x] Complete a scoped MCP scene operation and verify its saved result and
  render/viewport evidence.
- [ ] Obtain user acceptance before marking finished or promoting/merging.

## Behavioral cases for remaining checks

1. **Existing ready scene:** reuse the existing Blender and server, preserve
   unrelated geometry, make the requested scoped edit, and verify the result.
2. **Slow startup or busy file load:** wait and inspect progress; no second
   launch, premature scene command, or timeout-driven mutation replay.
3. **Duplicates or uncertain result:** preserve unsaved work, establish ownership
   and operation state, and report unresolved conflicts instead of killing or
   duplicating processes.

These are acceptance cases, not executed test results. Static skill validation
does not establish live MCP, lifecycle, visual, or human acceptance.

Authoring evidence (2026-10-31): the skill-creator structure validator passed;
the repository validator passed for 68 registered skills, including provenance
hashes and the public-path audit. The harness junction resolves to this branch
checkout and its `SKILL.md` SHA-256 matches the source. The earlier standalone
copy was preserved in local runtime recovery storage with verified hashes.

Handoff evidence (2026-10-31): remote branch publication was verified at
`8d2cf631b3a14ecc4ca8e509abb14ebad8f918e6`. T3 returned `delivery: steered`
for the exact skill, support files, hashes, branch-fetch instructions, and
eventual Wiki path sent to the owner's requested conversation on the target
machine. This proves delivery, not that the recipient fetched or completed
the remaining checks. All three repository commands (`npm run check`,
`npm test`, `npm run build`) passed; they currently run the same validator.

## Receiving this branch

### Target-machine receipt (2026-10-31)

**Source transfer:** a new, clean checkout was cloned from Git under the
verified Wiki branch-checkout shelf. The unrelated dirty canonical checkout
was inspected and left untouched. The received head and a subsequent fetch
both matched `8de7385b5c2937b82d97626ef10ba287b6647936`.
The received `SKILL.md` SHA-256 was
`6806fa199656732c3b42ad371e679df3474fe19d8c23503dd03d780ea1781483`;
`agents/openai.yaml` matched
`bdcf59ae4af7e44528b9abbd1d41a160f34bea32085bcf8f85c2a50a61733b4f`.
Neither file was changed by this receipt.

**Current readiness snapshot:** bounded process inspection found one Blender
application process (PID 23496) and one MCP bridge launcher/child process tree.
The existing Blender process owned the connection on loopback port 9876.
Read-only MCP inspection confirmed one `BlenderMCPServer` object with
`running=True`, socket address `127.0.0.1:9876`, and
`SO_ACCEPTCONN=True`. A successful `get_scene_info` call identified the
Greek-house file, scene, selection, and camera. Blender was 5.2.3 LTS;
the installed add-on reported protocol 15 and version 1.8.0. This checks the
current single-instance/readiness item, not the full startup lifecycle.

**Scoped MCP and visual evidence:** `execute_blender_code` adjusted the
Greek-house roof materials, roof caps, rafters, and display path; exported
the house-only GLB; and saved the Blender project. A pre-edit recovery copy
and hash record were retained. `look` provided the actual camera material
viewport, and a subsequent render scheduled through MCP produced the final
1200-by-1100 PNG. `look(image=...)` inspected that saved render. The model
contains 480 profiled roof tiles and 197 mesh objects plus eight curves under
its asset root. The saved/exported deliverables were:

| File under the local model output directory | SHA-256 |
| --- | --- |
| `GreekHouse.blend` | `4f66d392d30c3e3d9854ad00593e521a175541db8cec6d4eeb4e8dbd53b4300e` |
| `GreekHouse.glb` | `6794ead053e59534029ac3c9ff4950817f6e1348e8ddcff11d7dd17900b79ae0` |
| `greek_house.png` | `50d5e7acc10c40277e40c8268fc6033dc5aa33147246d38cc00147dde2a69d80` |

**Limits:** initial construction and reopen/GLB-container checks used external
Blender Python while MCP was disconnected or before this exact workflow was
received. Some background validation overlapped another Blender instance;
those runs are not evidence of serialized lifecycle compliance. The GLB
container checks did not establish import into a downstream application.
The slow-startup/file-load and uncertain-timeout behavioral item remains
unchecked; no safe fixture established it, and earlier relaunch behavior
does not satisfy it. No user acceptance, completion, promotion, or merge is
claimed. Receipt checks reused the existing instance and launched no further
Blender process. The live session was left available with its dirty state
untouched, and the saved model and recovery files were preserved.

**Receipt validation:** `npm run check` passed for 68 registered skills,
including provenance and public-path checks; `git diff --check` passed.
`npm test` and `npm run build` were not repeated because this checkout maps
both to the same validator.

### Fetch instructions

Fetch `unfinished/blender-mcp` from `https://github.com/ryanspice/agent-skills.git`.
Use a clean checkout or clone that branch into the Wiki's branch-checkout shelf.
Before using an existing checkout, confirm its remote and preserve dirty work.
After both machines are working on this same branch, use `git pull --ff-only`
when clean, update evidence-backed checkboxes, and commit/push scoped progress.
Do not force-push or rely on OneDrive to transfer Git state.
