# Repo Skill Recommender v0.2.0 Audit Model

This reference defines the improved repo recommendation flow.

## Purpose

The recommender should not dump a default shortlist. It should inspect the target repo, identify concrete signals, generate repo-specific questions, then propose a minimal skill set.

## Sources

Use:

- active canonical universal skills from `03_indexes/skills/skills-registry.json`
- project canonical skills from `04_skills/projects/<project>/`
- candidate skills from `03_indexes/skills/external-sources/external-candidate-skills.json`
- skill provenance from `03_Indexes/skills/skill-provenance.json`
- repo evidence from `package.json`, source tree, `.ai`, `.thoughts`, `AGENTS.md`, scripts, docs, source matches, and verification scripts

## Rules

1. Candidate skills are source snapshots until selected, adapted, and promoted.
2. Generated skills are Ryan-directed generated/history/package records; keep that source record even after promotion.
3. Repo setup should not copy all candidate skills.
4. Already-promoted candidate-derived skills should be reported as promoted support skills, not as review candidates.
5. Questions must be derived from actual repo evidence.
6. Prefer pointer mirrors over full repo-local copies.
7. Use `powershell-script-authoring` for generated repo/apply scripts.
8. Use `--scan --registry` when validating the AI Wiki root.
9. Use Bun commands when `bun.lock` is present.
10. Do not mutate repo files during recommendation dry runs.

## Question Quality

Bad questions are generic:

- Should we create AGENTS.md?
- Should we promote candidates?

Good questions include evidence and defaults:

- AGENTS.md already exists. Should setup patch it, leave it alone, or stage a proposed change?
- Audio terms dominate the repo scan. Should adaptive-audio be the primary next setup lane?
- WebGL/canvas signals are strong. Should performance work start with measurement/culling before shader polish?

## Output

The report should include:

- repo audit signals
- evidence samples
- recommended active skill set with modes
- already-promoted candidate-derived support skills with reasons
- unpromoted candidate review shortlist with reasons
- deferred candidates with reasons
- repo-derived questions
- proposed repo setup strategy
- paste-ready next prompt
