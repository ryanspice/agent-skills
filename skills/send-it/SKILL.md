---
name: send-it
description: Organize the current authorized work into one or more reviewable pull requests, updating relevant documentation and reporting verification and remaining work. Use when the user says "send it" or asks to prepare PRs for the current work; do not infer permission to merge, deploy, publish, or send messages.
license: MIT
metadata:
  version: "1.0.0"
  status: "active"
  provenance_origin: "original"
  provenance_source_path: "04_skills/agent-skills/skills/send-it/SKILL.md"
  provenance_credit: "Ryan Spice-Finnie"
  provenance_ingested_as: "ryanspice/agent-skills owned skill"
  provenance_note: "Created for Ryan's reviewable pull-request handoff workflow."
---

# Send It

Turn the current feature, repository state, or conversation into a reviewable PR or a small, ordered set of PRs. The user and higher-priority instructions determine scope and authorization; this skill does not authorize a merge, deployment, release, external message, or unrelated work.

## 1. Identify the work

- Read the user's request and relevant repository instructions. Inspect branch, upstream, working tree, commits, worktrees, remote state, and existing PRs. Determine which changes are requested, their dependencies, and whether work is unfinished or belongs to someone else.
- Preserve unrelated and concurrent work. Do not blanket-stage, reset, stash, clean, force-push, or overwrite it. If one file mixes scopes, isolate the requested change without changing the original, and verify the resulting diff. If ownership or scope cannot be established, do independent work and ask a focused question.
- Group coherent changes into the fewest useful PRs. Use separate PRs for independent changes and an explicit stack for dependent changes. Reuse an appropriate existing PR rather than creating duplicates.

## 2. Prepare each reviewable change

- Address required integration and small defects within the authorized scope. Update the README or operations guidance when it helps users or agents discover or use the change; preserve existing conventions and unrelated edits.
- Run the smallest meaningful checks and required repository gates. Review the final diff, including generated files and public-facing material. Record commands, results, and what remains unverified; never present plans or prior results as fresh verification.
- Use an existing safe branch or a separate checkout based on the appropriate current base. Preserve the user's work and backup consequential edits; do not rewrite published history. Confirm the scope before creating commits and pushing.

## 3. Hand off through PRs

- When the user asks to send the work, create or update the appropriate PRs using the host's available tools. Draft PRs are appropriate for incomplete work or unresolved checks; describe the limitation clearly.
- Give each PR a concrete title and a concise description of the problem, resulting behavior, scope, dependencies and actual validation. Reflect the final implementation, not abandoned approaches. Create an issue only when requested or required by the repository.
- Link each created, taken-over, or updated PR to the current task when the host provides that capability; obey host-specific linking and monitoring rules. Inspect checks and reviews when available. Watch only when requested or when an authorized action is waiting on them. Never poll with sleep loops.
- Merge, publish, deploy, or send external messages only when independently authorized. Do not treat a request for PRs as permission for those actions.

## 4. Report

Provide each PR link, base and head, what it changes, checks run and their results, CI/review state when known, and any remaining conflicts, unrelated work, or acceptance gaps. If a requested item cannot be made reviewable safely, explain the blocker and what has been completed.

`chalk-it-up` is a separate workflow for tracked issues and an explicitly authorized merge; use it only when its scope and the user's request match.
