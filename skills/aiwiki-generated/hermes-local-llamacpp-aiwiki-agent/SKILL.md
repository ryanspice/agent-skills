---
name: hermes-local-llamacpp-aiwiki-agent
description: Operate Hermes as a local-first AI Wiki agent with llama.cpp/local models, OpenRouter fallback models, MCP vault tools, native AI Wiki skills, and strict no-autonomous-edit guardrails.
version: 0.1.0
platforms: [windows]
tags: [hermes, llama-cpp, ai-wiki, mcp, local-agent, windows, powershell, openrouter, nemotron]
provenance_origin: "original"
provenance_source_path: "04_skills/generated/hermes-local-llamacpp-aiwiki-agent/SKILL.md"
provenance_note: "Original AI Wiki generated skill."

---

# Hermes Local llama.cpp / AI Wiki Agent

## Purpose

Use this skill when configuring or operating Hermes as Ryan's local-first terminal agent for AI Wiki search, reading, summarization, planning, handoffs, MCP-backed vault access, native AI Wiki skills, and future llama.cpp / LM Studio local model workflows.

Hermes is not the primary autonomous builder in this workflow. Treat it as a controlled local operations / research / planning assistant.

## Core Principles

1. Keep Hermes local-first and workspace-scoped.
2. Do not point Hermes at the entire AI Wiki for skill scanning.
3. Do not allow autonomous file edits by default.
4. Prefer read-only MCP tools for AI Wiki work.
5. Use native AI Wiki skills for operating rules and project context.
6. Stage generated outputs into inbound/review areas unless the user explicitly approves direct edits.
7. Use Windows PowerShell launchers and repeatable scripts.
8. Measure model behavior empirically: speed, tool obedience, accuracy, and output usefulness.

## Canonical Paths

Canonical AI Wiki:

```text
<AI_WIKI_ROOT>
```

Downloads / staging:

```text
<DOWNLOADS_ROOT>
```

Hermes stack launcher:

```text
<AI_WIKI_ROOT>\00_Kit\scripts\hermes\start-aiwiki-hermes-stack.ps1
```

AI Wiki generated skills shelf:

```text
<AI_WIKI_ROOT>\04_skills\generated
```

Universal AI Wiki skills:

```text
<AI_WIKI_ROOT>\04_skills\universal
```

Project skills example:

```text
<AI_WIKI_ROOT>\projects\pixelboats\.ai\skills
```

Nemotron performance eval:

```text
<AI_WIKI_ROOT>\_agent-evals\hermes-nemotron-perf-accuracy-eval-v0.1.1
```

## Hermes Launch Pattern

Preferred launch:

```powershell
haiwiki-stack.ps1 -Workspace aiwiki
```

Other workspaces:

```powershell
haiwiki-stack.ps1 -Workspace dev
haiwiki-stack.ps1 -Workspace pixelboats
haiwiki-stack.ps1 -Workspace here
```

The stack launcher starts the local AI Wiki MCP HTTP server, sets AI Wiki root environment variables, launches Hermes from the requested workspace, and avoids editing or restructuring the wiki.

Expected MCP server:

```text
obsidian_ai_wiki [http]: 5 tools
```

Expected AI Wiki MCP tools:

```text
mcp_obsidian_ai_wiki_context_pack
mcp_obsidian_ai_wiki_graph_neighbors
mcp_obsidian_ai_wiki_inbound_list
mcp_obsidian_ai_wiki_vault_read
mcp_obsidian_ai_wiki_vault_search
```

## Native AI Wiki Skills

Expected custom skills visible through:

```powershell
hermes skills list
```

Known loaded custom skills:

```text
ai-wiki-file-management
pixelboats-adaptive-audio
pixelboats-p0-stabilization
pixelboats-production-architecture
pixelboats-release-packaging
webgl2-mobile-performance-pass
```

If skills do not appear, repair Hermes config by setting external dirs to narrow absolute paths:

```yaml
skills:
  external_dirs:
    - "<AI_WIKI_ROOT>/04_skills/universal"
    - "<AI_WIKI_ROOT>/projects/pixelboats/.ai/skills"
```

Do not scan the entire AI Wiki as a skill root.

## Model Role Split

### Hermes + Nemotron / free OpenRouter models

Use for AI Wiki read-only research, skill lookup, summaries, handoffs, planning, prioritization, safe diagnostics, and non-programming agent work.

Avoid for autonomous code edits, broad repo rewrites, AI Wiki migrations, production-ready implementation claims, and client-sensitive raw data unless redacted and approved.

### Codex / Claude / GPT-style builder agents

Use for implementation, code edits, refactors, build fixes, and tests.

### Local llama.cpp / LM Studio

Use for private/offline notes, small summaries, low-risk helper tasks, and cheap experimentation. Do not expect very large hosted-class models to replace builder agents on modest consumer hardware.

## Prompting Rules

For read-only AI Wiki tests:

```text
Use only these MCP tools:
- mcp_obsidian_ai_wiki_vault_search
- mcp_obsidian_ai_wiki_vault_read

Do not use terminal.
Do not call context_pack.
Do not create, modify, delete, or stage files.
Say "not verified" if you did not check it.
List exact tools used.
```

For native skill checks:

```text
Use native Hermes skills only.
Do not call MCP tools.
Do not use terminal.
Do not edit files.
```

For planning workflows:

```text
Use ai-wiki-file-management.
Do not edit files.
Create a practical workflow.
Writes go to 07_inbound/proposed unless explicitly approved.
```

## Tool Discipline

Important distinction:

- `vault_search` / `vault_read`: read-only vault tools.
- `context_pack`: can create/update output files.
- `inbound_list`: lists staged inbound content.
- writing/staging tools: require explicit user approval.

When the user says read-only, do not call `context_pack`.

## AI Wiki Write Policy

Default write target for agent-created content:

```text
<AI_WIKI_ROOT>\07_inbound\proposed
```

Durable/project content should be promoted only after review.

Preserve `.thoughts`, `README.md`, `NEXT_CHAT_HANDOFF.md`, and `SKILL.md`.

Use lowercase kebab-case for new files unless a required convention says otherwise.

## Performance Testing

Measure each prompt separately:

```powershell
$Start = Get-Date
# paste prompt into Hermes and wait for final answer
(Get-Date) - $Start
```

Record duration, tool calls, tool obedience, no-write discipline, accuracy, duplicated/looped output, and usefulness.

Do not queue eval prompts together.

## Known Pitfalls

- OpenRouter free models can be slow or queued.
- Large agent models may take 2–3 minutes when tool calls are broad.
- Hermes terminal may run through bash/MSYS in some modes; prefer scripts/launchers for Windows-safe behavior.
- `context_pack` writes files, so it is not appropriate for strict read-only tests.
- Native skills and MCP tools are separate systems.
- Runtime MCP connection matters more than config-file inference.
- Avoid broad "audit everything" prompts unless long tool-crawling is acceptable.

## Good Default Hermes Prompt

```text
Use these skills:
- ai-wiki-file-management

Use only these MCP tools:
- mcp_obsidian_ai_wiki_vault_search
- mcp_obsidian_ai_wiki_vault_read

Do not use terminal.
Do not call context_pack.
Do not create, modify, delete, or stage files.

Task:
Search the AI Wiki for the relevant context, summarize the decision or handoff needed, and clearly mark anything not verified.
Keep it concise.
```

## Verification Checklist

Run:

```powershell
hermes skills list | Select-String -Pattern "ai-wiki|pixelboats|webgl2|adaptive|file-management"
```

Expected result includes custom AI Wiki skills.

Run:

```powershell
haiwiki-stack.ps1 -Workspace aiwiki
```

Expected Hermes startup includes:

```text
obsidian_ai_wiki [http]: 5 tools
```

If MCP is missing, confirm the server:

```powershell
Get-NetTCPConnection -LocalPort 7950 -State Listen -ErrorAction SilentlyContinue
```

## When to Update This Skill

Patch this skill when Hermes changes config paths or external skill behavior, llama.cpp/local model workflow becomes stable, a new preferred free/cheap model is validated, MCP tool names or write behavior changes, or the AI Wiki taxonomy is migrated.
