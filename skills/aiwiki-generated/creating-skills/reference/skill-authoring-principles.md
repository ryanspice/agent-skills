# Skill Authoring Principles

## Core idea

A skill is a durable, filesystem-based capability: metadata, instructions, optional reference files, templates, and optional scripts. It should package procedural knowledge so the user does not have to keep rewriting the same prompt.

## Progressive disclosure

Use three layers:

1. **Metadata**: name and description. Always visible to skill discovery.
2. **Main instructions**: `SKILL.md`. Loaded when the skill is invoked.
3. **Resources and code**: reference files, templates, scripts. Loaded or executed only when needed.

The live `SKILL.md` should point to supporting files instead of swallowing them.

## Description quality

The description is selection logic. Write it like routing metadata, not marketing copy.

Good description shape:

```yaml
description: Creates reusable skill packages from prompts, notes, transcripts, examples, and codebase conventions. Use when the user asks to make, audit, split, improve, package, or validate an agent skill.
```

Bad description shape:

```yaml
description: Helps with skills.
```

## Composability

Build small capabilities that chain:

- `watch-video` extracts transcript/key frames.
- `article-optimizer` consumes transcript output.
- `creating-skills` consumes source patterns and creates a reusable skill.

Split skills when independent parts have different triggers, risks, update cadence, or reusable value.

## Tooling

When a task is deterministic, prefer a script. Examples:

- validate frontmatter
- inspect directories
- normalize filenames
- generate a file tree
- convert structured input to markdown
- verify required assets exist

A script makes future runs faster, more consistent, and less token-hungry.

## Evaluation-driven development

Do not create a giant instruction manual first. Make minimal instructions, then test on representative scenarios.

Useful eval set:

1. normal case
2. ambiguous source material
3. safety/side-effect case
4. composability/splitting case
5. regression case from a previous failure

## Improvement loop

After every useful failure, decide whether to update:

- `SKILL.md` for central workflow changes
- `reference/` for deeper context
- `templates/` for output structure
- `scripts/` for repeatable operations
- `examples/evals` for future regression checks

Small durable improvements beat grand rewrites.
