# AI Wiki MCP Integration

## Canonical shape

Ryan's skills should be stored in the AI Wiki first:

```txt
<AI_WIKI_ROOT>/04_skills/universal
<AI_WIKI_ROOT>/skills/projects/<slug>
```

Repo-local and tool-local folders are mirrors or working copies.

## Skill discovery roots

Good external skill roots:

```txt
<AI_WIKI_ROOT>/04_skills/universal
<AI_WIKI_ROOT>/skills/projects/pixelboats
<DEV_ROOT>/PixelBoats/.ai/skills
```

Avoid:

```txt
<AI_WIKI_ROOT>
```

The whole vault includes raw notes, old exports, client material, archives, and generated clutter. Pointing an agent at all of that as a skill root makes discovery noisy and risky.

## Descriptor file

Each durable skill should preferably include:

```txt
mcp-skill.json
```

Minimum useful fields:

```json
{
  "slug": "skill-name",
  "name": "Skill Name",
  "version": "0.1.0",
  "type": "universal-agent-skill",
  "status": "active",
  "canonical_path": "04_skills/universal/skill-name/SKILL.md",
  "entrypoint": "04_skills/universal/skill-name/SKILL.md",
  "description": "What this skill does and when to use it.",
  "invocation_phrases": ["make a skill"],
  "allowed_mcp_tools": ["vault_search", "vault_read", "graph_neighbors", "context_pack"],
  "optional_write_tool": "stage_inbound_note",
  "write_policy": "Stage proposed durable edits into 07_inbound/proposed.",
  "risk": "low"
}
```

## Registry

The registry should summarize skills for fast discovery:

```txt
03_indexes/skills/skills-registry.json
```

It should contain a `skills` array. A single-object registry is a bug because it can only represent one skill.

## Write policy

Default to read-only MCP. If writing is needed, prefer staging:

```txt
07_inbound/proposed
```

Do not mutate `02_wiki` directly. Reviewed installer scripts may update `04_skills`, `skills/projects`, and `03_indexes` after backing up touched files.
