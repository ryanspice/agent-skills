---
name: replace-with-side-effect-skill-name
description: Performs a controlled side-effect workflow only when explicitly invoked by the user. Use for deploy, send, publish, delete, billing, infrastructure, or production-changing workflows.
disable-model-invocation: true
provenance_origin: "original"
provenance_source_path: "04_skills/generated/creating-skills/templates/safe-side-effect-skill/SKILL.md"
provenance_note: "Original AI Wiki generated skill."

---

# Safe Side-Effect Skill Template


<!-- Replace placeholders. Keep SKILL.md concise. Move bulk details to reference/. -->


## Purpose

Run a sensitive workflow only after explicit user invocation.

## Required confirmation

Before any irreversible or external action:

1. Summarize the action.
2. Show target environment/account.
3. Show files/resources affected.
4. Ask for explicit confirmation unless the user already gave clear send/deploy/delete-now instruction in the same turn.

## Workflow

1. Validate current state.
2. Run dry-run or preview if available.
3. Run tests/checks.
4. Perform the action.
5. Verify result.
6. Report exact outcome and rollback path if applicable.

## Never do automatically

- production deploy
- sending messages
- deleting files or data
- rotating credentials
- charging payments
- publishing public content
