# Install Surfaces

## AI Wiki generated skill shelf

Default install target:

```txt
<AI_WIKI_ROOT>\04_skills\generated\gpt55-webapp-builder-codex-bridge\SKILL.md
```

Use this while the skill is experimental or AI-generated.

## Promotion path

Only promote to universal after repeated successful use:

```txt
<AI_WIKI_ROOT>\04_skills\universal\gpt55-webapp-builder-codex-bridge\SKILL.md
```

Promotion should update registry/index metadata in the same pass.

## Repo mirrors

Repo-local copies are mirrors/pointers:

```txt
<repo>\.ai\skills\gpt55-webapp-builder-codex-bridge\SKILL.md
<repo>\skills\gpt55-webapp-builder-codex-bridge\SKILL.md
```

Do not treat repo mirrors as canonical unless the user explicitly makes it a project-level skill.

## MCP routing

MCP should read narrow skill roots, not the whole vault.

Recommended read tools:

```txt
vault_search
vault_read
graph_neighbors
context_pack
```

Write tools should stage proposed edits or require installer/apply script review.

## Codex/Trae/Hermes use

Use this skill as a prompt/context source, not as an unchecked local execution permission slip.

Good handoff:

```txt
Use skill: gpt55-webapp-builder-codex-bridge
Goal: generate a reviewable package/apply script.
Constraints: dry-run first, explicit paths, backup before overwrite, no secrets.
```
