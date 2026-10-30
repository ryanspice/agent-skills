# Attribution, provenance, and sources

Prepared for Ryan Spice-Finnie on 2026-10-16. `wayfinder-spice` is a substantially
rewritten personal adaptation, not an upstream Matt Pocock release or endorsement.
Upstream MIT attribution is retained in [LICENSE.txt](LICENSE.txt).

This public repository adaptation retains Ryan's workflow preferences and uses
placeholders for machine-specific roots. Source references below are provenance,
not instructions to execute remote content. Review any local output before sharing.

## S1 — Original WAYFINDER

- Source: https://github.com/mattpocock/skills/blob/main/skills/engineering/wayfinder/SKILL.md
- Retrieved through the GitHub connector on 2026-10-16.
- File blob SHA: `e28cf3018906d6d60fc5b25390b4eeea035dd290` (a blob ID, not a commit ID).
- License source: https://github.com/mattpocock/skills/blob/main/LICENSE
- License blob SHA: `f1dd2c09108dde1a5f56097cee8461b3ea834499`.
- Retained ideas: decision maps, a destination, a frontier of questions, progressive
  discovery, named ticket references, single-ticket answers, planning before execution.
- Deliberate changes: no mandatory grilling/domain-modeling/research skills; no automatic
  branch creation or pushes; no fixed token capacity; repo-native tracker fallback;
  clear permission gates; a single coordinator rather than treating assignment as a lock.

## S2 — Ryan's own skill conventions

- Source: https://github.com/ryanspice/agent-skills/blob/e72b7f5049030a41e10993b60dbcbfec052da5f9/skills/repo-skill-recommender/SKILL.md
- Retrieved 2026-10-16; file blob SHA `29cc3ec919d69f8ad2da19f8193c6886ee958afa`.
- Used for AI-Wiki canonical ownership, narrow skill retrieval, pointer mirrors,
  report-before-write setup, local helper discovery, and candidate-versus-active status.
- The source's recorded canonical skill path is under
  `04_skills/agent-skills/skills/`; the actual current install destination remains to be
  discovered and verified on the user's computer.
- Additional personalization comes from the supplied user profile, recent explicit
  workflow preferences, and dated Library operating notes.
  These are not a live audit of Windows or provider configuration.

## S3 — Agent Skills format

https://agentskills.io/specification — accessed 2026-10-16.
Used for standard frontmatter, matching skill/directory name, concise core instructions,
progressive resource loading, and relative references. The bundled validator checks
this package's deliberately narrow format; it is not the official skills-ref validator.

## S4 — Codex / ChatGPT skills

https://learn.chatgpt.com/docs/build-skills — accessed 2026-10-16
(the older `https://developers.openai.com/codex/skills` URL redirects here).
Used for local `.agents/skills` discovery, explicit `$skill` invocation in Codex,
and `agents/openai.yaml` with `policy.allow_implicit_invocation: false`.
Documentation support does not prove installation or discovery in Ryan's current build.

## S5 — Claude Code skills

https://code.claude.com/docs/en/skills — accessed 2026-10-16.
Used for `.claude/skills` discovery, `disable-model-invocation: true` in a thin native
wrapper, and manual `/name` invocation. Host-specific controls are not interchangeable
with the portable core or permissions. Alternate profile roots must be discovered.

## S6 — OpenCode skills

https://opencode.ai/docs/skills/ — accessed 2026-10-16.
Used for documented discovery paths and string-valued metadata:
`opencode/slash: "true"`, `opencode/autoinvoke: "false"`.
These controls are included in the portable core. Verify the installed client actually
supports them; old clients may require explicit file loading instead.

## S7 — Evaluating skills

https://developers.openai.com/blog/eval-skills — published 2026-01-22, accessed 2026-10-16.
Used for separating outcome/process/style/efficiency checks and evaluating captured
runs rather than declaring improvement from wording alone. Bundled behavioral cases
are proposed evals; no live model performance improvement is claimed.
