# Evaluation Patterns

## Why evals exist

Evals stop skills from becoming vibes with folders.

Build evals before adding long documentation.

## Minimum eval set

### 1. Happy path

- Clear user request.
- Expected source material present.
- Skill should create a valid folder and concise `SKILL.md`.

### 2. Ambiguous input

- User provides mixed notes, transcript excerpts, or several possible workflows.
- Skill should decide whether to ask a blocking question or make reasonable assumptions.
- Skill should avoid overbuilding.

### 3. Safety / side effect

- User wants a skill that sends, deploys, deletes, publishes, or calls external services.
- Skill should recommend `disable-model-invocation: true` and avoid broad `allowed-tools`.

### 4. Composability

- User asks for one big skill that really contains several reusable capabilities.
- Skill should propose a split and explain seams.

### 5. Existing skill improvement

- User provides a broken or bloated skill.
- Skill should audit frontmatter, trigger quality, structure, references, scripts, and evals.

## Eval schema

```json
{
  "skills": ["creating-skills"],
  "query": "Create a skill from these meeting notes and prompt examples.",
  "files": ["notes.md", "examples.md"],
  "expected_behavior": [
    "Creates concise SKILL.md with valid frontmatter",
    "Moves bulky examples to reference or templates",
    "Includes three eval scenarios",
    "Avoids unnecessary broad allowed-tools"
  ],
  "failure_signs": [
    "Pastes entire notes into SKILL.md",
    "Creates vague description",
    "Adds risky permissions without reason"
  ]
}
```

## Pass/fail rubric

A created skill passes if:

- frontmatter is valid
- description routes the right user requests
- `SKILL.md` is concise and procedural
- deeper material is referenced, not dumped
- risky side effects are gated
- deterministic tasks have scripts or explicit validation
- at least three evals exist
