# Skill Anti-Patterns

## Mega-skill

One skill tries to do all research, writing, coding, packaging, asset generation, and QA.

Fix: split by trigger and reusable function.

## Prompt dump

A transcript or research report is pasted directly into `SKILL.md`.

Fix: summarize durable rules in `SKILL.md`; move source notes to `reference/`.

## Vague description

```yaml
description: Helps create things.
```

Fix: include what it does and when to use it.

## Tool theater

The prompt is detailed, but scripts/tools have unclear names, no docs, weird parameters, and no validation.

Fix: script APIs should be clear enough for a tired engineer to use without squinting.

## Excessive options

The skill lists every possible library, route, or method.

Fix: provide a default path and one escape hatch.

## Hidden side effects

The skill can send, deploy, delete, purchase, publish, or mutate production state without explicit user intent.

Fix: use `disable-model-invocation: true`, avoid broad `allowed-tools`, and require confirmation.

## Windows path leakage

Inside skill docs, avoid backslash paths such as:

```txt
scripts\validate.py
```

Use:

```txt
scripts/validate.py
```

## No evals

The skill exists but nobody knows whether it works.

Fix: add at least three representative scenarios.

## Over-explaining obvious concepts

Do not teach Claude what Markdown, folders, or JSON are unless the task has a special local convention.

Fix: assume the model is capable; document only the local delta.
