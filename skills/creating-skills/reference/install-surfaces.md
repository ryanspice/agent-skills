# Install Surfaces

## AI Wiki canonical shelf

For this workflow, install reusable skills into the AI Wiki first:

```txt
<AI_WIKI_ROOT>/04_skills/universal/skill-name/SKILL.md
```

This is the source of truth for MCP/agent loading.

Recommended supporting files:

```txt
<AI_WIKI_ROOT>/04_skills/universal/skill-name/mcp-skill.json
<AI_WIKI_ROOT>/03_indexes/skills/skill-name.md
<AI_WIKI_ROOT>/03_indexes/skills/skills-registry.json
```

## Project overlays

Use project overlays when a universal skill needs repo-specific context:

```txt
<AI_WIKI_ROOT>/projects/project-slug/.ai/skills/skill-name/SKILL.md
```

Use repo working copies when the agent is operating inside the repo:

```txt
<repo>/.ai/skills/skill-name/SKILL.md
```

## MCP loading

MCP servers/agents should point at narrow skill directories, not the whole vault.

Good:

```txt
<AI_WIKI_ROOT>/04_skills/universal
<AI_WIKI_ROOT>/projects/pixelboats/.ai/skills
```

Avoid:

```txt
<AI_WIKI_ROOT>
```

## Claude Code mirror

Claude Code personal install paths are mirrors only for this workflow:

```txt
~/.claude/skills/skill-name/SKILL.md
```

Project Claude Code mirror:

```txt
.claude/skills/skill-name/SKILL.md
```

Use these only when Claude Code is actually installed and should see the skill.

## claude.ai

Package the skill folder as a zip and upload it through custom skill settings where available.

Keep in mind:

- custom skills may be user-specific
- code execution and network behavior depend on plan/admin/runtime settings
- large support files should still be progressive-disclosure references

## Claude API

Custom skills are managed separately from Claude Code and claude.ai. Plan for a separate upload/management process.

## Portability rules

- Use forward-slash paths in skill instructions.
- Avoid assuming global packages.
- Avoid network requirements unless explicitly part of the skill.
- Document runtime assumptions.
- Keep scripts dependency-free when possible.
- Treat tool-specific mirrors as generated copies, not canonical source.
