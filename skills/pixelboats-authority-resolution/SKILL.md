---
name: pixelboats-authority-resolution
description: "Resolve which source is authoritative for any claim about PixelBoats — runtime behavior, architectural completion, lore, planning, or prototypes. Prevents repo-local-only searching and authority conflation."
version: 0.1.0
status: candidate
type: project-agent-skill
risk: medium
tags: ["pixelboats", "authority", "lore", "architecture", "scope", "ai-wiki"]
project: pixelboats
created_at: 2026-07-21
metadata:
  review_status: staged-candidate
  reviewers: [Nemotron, Vibethinker]
  replaces: none
  conflicts_with: none
  related_skills: [evidence-first-engineering, pixelboats-mcp-verification-semantics]
---

# PixelBoats Authority Resolution

Load this skill before making any claim about what exists, what's missing, or what's complete in PixelBoats. It routes every claim to the correct authority root.

## Authority Hierarchy by Claim Type

### Runtime Behavior
"Is cannon audio playing in /game?"

```
Priority: runtime test > canonical runtime code > lab code > documentation
Scope: repo-runtime
Roots:
  1. Browser console / Playwright test (CONFIRMED_RUNTIME)
  2. src/routes/(game)/game/+page.svelte + imports
  3. src/lib/pixelboats/audio/ (canonical runtime)
  4. src/routes/(lab)/lab/aurora-audio/ (prototype, not authoritative)
```

### Architectural-Stage Completion
"Is S6 complete?"

```
Priority: formal exit criteria + implementation evidence + owner sign-off
Scope: formal-stage-criteria
Roots:
  1. BEDROCK_FOUNDATION.md — stage definition and exit gates
  2. Implementation evidence per criterion
  3. Performance measurements (must be measured, not inferred)
  4. Owner sign-off (manual-verification-required)
Never: route existence, gameplay behavior alone, file counts
```

### Lore Existence
"Does Caribbean/Atlantic lore exist?"

```
Priority: canonical AI-Wiki + adoption documents + repo-local catalogs
Scope: external-ai-wiki or repo-documentation
Roots (MUST search ALL before claiming absence):
  1. <AI_WIKI_ROOT> (canonical lore authority)
  2. <PIXELBOATS_ROOT>/docs/ (project documentation)
  3. <PIXELBOATS_ROOT>/src/lib/ (typed catalogs, lore modules)
  4. <PIXELBOATS_ROOT>/src/routes/(lab)/lab/lore/ (lore wiki)
Never: repo-local grep only, single-directory search
```

### Runtime Lore Availability
"Is Caribbean lore available at runtime?"

```
Priority: repo-local typed catalogs + runtime consumption
Scope: repo-runtime
Roots:
  1. src/lib/ — typed lore catalogs, imports from lore modules
  2. Runtime console — actual data available at runtime
  3. /game — lore surfaced in UI/dialogue
```

### Current Planning
"What's being worked on?"

```
Priority: lane board + roadmap + owner rulings
Scope: repo-documentation
Roots:
  1. .ai/lanes/board.md (active lane claims)
  2. BEDROCK_FOUNDATION.md (build order S0–S7)
  3. TODO.md (current task list)
  4. Owner directives (CLAUDE.md, AGENTS.md)
```

### Prototypes
"What labs exist?"

```
Priority: lab filesystem + route registry
Scope: repo-lab
Roots:
  1. src/routes/(lab)/lab/ (actual SvelteKit routes)
  2. src/lib/suite/suite-registry.ts (SUITE_REGISTRY)
  3. reconcileSuite() output (unfiled + missing)
```

## Scope Labels

Every claim must use one of these scope prefixes:

| Label | Meaning |
|---|---|
| `repo-runtime` | Behavior observed in running /game or lab route |
| `repo-lab` | Prototype, not yet in canonical runtime |
| `repo-documentation` | Written in repo docs, not necessarily implemented |
| `repo-static` | Found via code analysis only |
| `external-ai-wiki` | Found in `<AI_WIKI_ROOT>` |
| `formal-stage-criteria` | Measured against BEDROCK_FOUNDATION.md exit gates |
| `runtime-observation` | Seen during manual testing |
| `historical-archive` | In archived/superseded code |

## The AI-Wiki Path

The canonical external authority path is:

```
<AI_WIKI_ROOT>
```

Do not "correct" `Obsidan` to `Obsidian`. The established path uses `Obsidan`. This path is case-sensitive on some operations.

## Rules

1. **Repo-local grep never suffices for "does not exist."** Search AI-Wiki before absence claims.
2. **Lab behavior is not runtime behavior.** /lab/aurora-audio working does not mean /game audio works.
3. **Route existence is not architectural completion.** A lab's +page.svelte proves the route loads — nothing more.
4. **One authority per claim type.** Don't use lore docs to prove runtime behavior, or runtime tests to prove stage completion.
5. **When authorities conflict, report the conflict.** Don't resolve it silently.
