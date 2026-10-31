# Skill authoring

Ryan-owned skills are authored in the AI Wiki checkout of this repository, at
`<AI_WIKI_ROOT>/04_skills/agent-skills/skills/<name>`. Harness skill folders are
links or managed mirrors, not the source of record.

- Create a dedicated branch before authoring a new skill. Use
  `unfinished/<name>` for work in progress. If the existing checkout has
  unrelated changes, preserve it and use a separate checkout of this same repo
  under `<AI_WIKI_ROOT>/04_skills/agent-skills-branches/<branch-slug>`.
- Mark a new skill `unfinished` in its metadata and include a `STATUS.md` with
  task-specific checkboxes. Check off work only with evidence. Keep structure,
  live tool behavior, visual inspection, and human acceptance separate.
- Commit only the intended files. For an authorized cross-machine handoff,
  push the branch and provide its remote, branch, commit, relative skill path,
  and remaining checks. Git fetch/pull is the handoff mechanism; do not depend
  on OneDrive catching up or switch a dirty receiving checkout.
- If sync or fetch is delayed, send the exact skill text and necessary support
  files to the explicitly requested conversation. Name the eventual Wiki path;
  machine-local absolute paths must be validated on the receiving machine.
- Update the checklist as work completes. Keep unfinished work on its branch;
  publication of that branch does not mean acceptance, activation, or merge.
- Keep public source portable and register added/changed skill files in
  `skills/provenance.json`. Run `npm run check`; `npm test` and `npm run build`
  currently invoke that same validator. Do not rebuild global Wiki indexes or
  install every skill as a side effect of authoring one.

For skill design guidance, consult the active harness's skill-creator or
`skills/creating-skills/SKILL.md`. This branch-first source workflow takes
precedence over historical local-install or proposal-shelf examples.
