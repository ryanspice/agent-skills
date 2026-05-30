---
name: replace-with-code-tool-skill-name
description: Runs a deterministic local helper script for a repeated workflow. Use when the user needs repeatable validation, extraction, transformation, packaging, or inspection.
provenance_origin: "original"
provenance_source_path: "04_skills/generated/creating-skills/templates/code-tool-skill/SKILL.md"
provenance_note: "Original AI Wiki generated skill."

---

# Code Tool Skill Template


<!-- Replace placeholders. Keep SKILL.md concise. Move bulk details to reference/. -->


## Purpose

Use this skill when a deterministic script is safer or faster than repeated model reasoning.

## Workflow

1. Inspect the user's input and decide whether the script applies.
2. Run the helper script from the project root or user-specified path.
3. Read the script output.
4. Fix only the reported issue or produce the requested artifact.
5. Re-run validation if files changed.

## Script

```bash
python3 ${CLAUDE_SKILL_DIR}/scripts/helper.py --help
```

On Windows, use:

```powershell
python "${CLAUDE_SKILL_DIR}/scripts/helper.py" --help
```

## Safety

- Do not install global packages.
- Do not send data externally.
- Do not modify files unless the user requested edits.
- Prefer dry-run mode when available.
