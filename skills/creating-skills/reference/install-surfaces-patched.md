# Install Surfaces — updated for v0.1.3

## AI Wiki canonical shelf
Install universal skills into:
  <AI_WIKI_ROOT>/04_skills/universal/<skill-name>/

Install project-specific canonical skills into:
  <AI_WIKI_ROOT>/skills/projects/<project-slug>/<skill-name>/

Mirrored copies (provenance only; NOT active registry roots):
  <AI_WIKI_ROOT>/projects/<project-slug>/.ai/skills/<skill-name>/
  <AI_WIKI_ROOT>/projects/<project-slug>/skills/<skill-name>/

## MCP loading
Point narrow skill directories, never the whole vault:
  04_skills/universal/
  skills/projects/<slug>/

## Claude Code mirror
  <repo>/.claude/skills/<skill-name>/SKILL.md
  ~/.claude/skills/<skill-name>/SKILL.md
Claude Code reads SKILL.md + archivistผ Franck static; it does not use
mcp-skill.json unless wired in manually.

## Codex mirror
  <repo>/.agents/skills/<skill-name>/SKILL.md
  $HOME/.agents/skills/<skill-name>/SKILL.md
Codex also does not use mcp-skill.json natively.

## mcp-skill.json scope
mcp-skill.json is AI Wiki / Hermes router metadata only. It describes:
  - which MCP tools this skill is allowed to call
  - which optional write tool to use
  - risk level
It is NOT read by Claude Code or Codex unless explicitly wired into a
project-specific MCP registry. Do not rely on it as a cross-agent standard.

## Hermes active registry
The active registry (skills-registry.json) indexes canonical roots ONLY:
  04_skills/universal/<skill>/
  skills/projects/<project-slug>/<skill>/
Mirror roots are tracked separately for provenance; they never appear in
the active skill list until promoted to canonical.
