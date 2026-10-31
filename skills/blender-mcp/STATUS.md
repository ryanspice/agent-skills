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
- [ ] Push the branch and verify its remote commit.
- [x] Replace the earlier standalone harness copy with a link to this source.
- [ ] Deliver the exact skill and branch instructions to the requested target
  conversation; keep delivery separate from the recipient's completion.
- [ ] On the target machine, fetch the branch and confirm the received skill
  matches its Git commit. Preserve a dirty checkout; use a separate checkout
  if needed.
- [ ] Verify one Blender instance and one MCP server, then a successful MCP
  readiness call on the target machine.
- [ ] Observe a slow startup/file load and an uncertain timeout without a
  duplicate launch or mutation; record evidence from real use or a safe fixture.
- [ ] Complete a scoped MCP scene operation and verify its saved result and
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

## Receiving this branch

Fetch `unfinished/blender-mcp` from `https://github.com/ryanspice/agent-skills.git`.
Use a clean checkout or clone that branch into the Wiki's branch-checkout shelf.
Before using an existing checkout, confirm its remote and preserve dirty work.
After both machines are working on this same branch, use `git pull --ff-only`
when clean, update evidence-backed checkboxes, and commit/push scoped progress.
Do not force-push or rely on OneDrive to transfer Git state.
