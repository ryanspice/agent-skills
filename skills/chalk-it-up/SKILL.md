---
name: chalk-it-up
description: "Use when Ryan says 'chalk it up' or asks to wrap up a finished change: scope the commit to his own work, commit, push a branch, open a linked issue and PR, watch the checks, and merge only on green. Not for drafting a change, reviewing someone else's PR, or force-pushing."
license: MIT
provenance_origin: "original"
provenance_source_path: "04_skills/agent-skills/skills/chalk-it-up/SKILL.md"
provenance_credit: "Ryan Spice-Finnie"
provenance_ingested_as: "ryanspice/agent-skills owned skill"
version: "1.0.0"
status: "active"
---

# Chalk It Up

Wrap a finished change into a tracked issue, a PR, and a merge, without touching work that is not part of it.

## Steps

1. **Read state first.** `git status --short`, `git branch --show-current`, `git remote -v`, `gh auth status`. Note every uncommitted file that is not part of this change.
2. **Scope the commit.** Stage only the files for this change. If a file mixes this change with unrelated edits, stage a filtered version of it (write the intended content to a temp file, `git hash-object -w`, `git update-index --cacheinfo`). Never `git add -A`, never stash or reset others' work.
3. **Branch.** If on the default branch, create `next-build/<short-slug>` (or the name Ryan gives). Do not commit to `main`.
4. **Local checks.** Run the smallest checks that cover the change, plus any project gate it touches. Record each result as passed or failed with the command. Do not claim checks that did not run.
5. **Commit.** Conventional subject line, body explaining why. End with the attribution line from the current system reminder. Do not add attribution lines the reminder leaves out.
6. **Push** with `-u`.
7. **Issue.** `gh issue create` with Problem, Expected, and Fix. Fix any typo in the title right away with `gh issue edit`.
8. **PR.** `gh pr create --base main --head <branch>`, body starts with `Closes #<n>`, then Summary, Scope, Testing (what ran locally, what CI runs, what was not verified on a device), and the generated-with line from the reminder.
9. **Link and watch.** Call the T3 `link_pull_request`, then `watch_pull_request` if the tools are present. Then end the turn. Do not poll with sleep or loops.
10. **Merge only on green.** When required checks pass and there are no unresolved review comments, merge. If any check fails, report the failing job and its log lines, and stop. Do not merge.
11. **Report.** Issue number and URL, PR number and URL, commit SHA, local checks with results, CI result, what was merged and into which branch, and what remains unverified.

## Rules

- Merging is outward-facing. Merge only when the user asked for it in this request, and only after checks pass. If the target branch is unclear, ask before merging.
- If the change is unfinished or its checks are not run, stop before the PR and say what is missing.
- Never force-push, rewrite history, or bypass hooks with `--no-verify`.
- Keep uncommitted work of others intact. Mention it in the report.
