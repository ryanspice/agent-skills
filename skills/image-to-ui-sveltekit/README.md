# PixelBoats Image-to-UI-to-SvelteKit Skill v0.1.0

Project-level skill for converting UI reference images into maintainable SvelteKit 2 + Svelte 5 components.

## Canonical target

```text
<AI_WIKI_ROOT>\skills\projects\pixelboats\image-to-ui-sveltekit\SKILL.md
```

## Mirrors

```text
<AI_WIKI_ROOT>\projects\pixelboats\.ai\skills\image-to-ui-sveltekit\SKILL.md
<AI_WIKI_ROOT>\projects\pixelboats\skills\image-to-ui-sveltekit\SKILL.md
```

## Included

```text
skills/projects/pixelboats/image-to-ui-sveltekit/SKILL.md
03_indexes/skills/skills-registry.snippet.json
03_indexes/skills/skill-mirrors.snippet.json
examples/pixelboats-stormy-seas-ui-reference.md
templates/image-ui-spec.template.json
templates/agent-prompt.md
references/images/*.png
INSTALL_TO_AI_WIKI_PIXELBOATS.ps1
.thoughts
```

## Install

From the extracted package folder:

```powershell
powershell -ExecutionPolicy Bypass -File .\INSTALL_TO_AI_WIKI_PIXELBOATS.ps1
```

Override the AI Wiki root if needed:

```powershell
powershell -ExecutionPolicy Bypass -File .\INSTALL_TO_AI_WIKI_PIXELBOATS.ps1 -AiWikiRoot "<AI_WIKI_ROOT>"
```

## Use

Paste this in a new agent/chat working inside the PixelBoats repo:

```text
Use skill: pixelboats-image-to-ui-sveltekit.
Use the attached/reference images as the UI direction.
First audit image layout and existing route files, then implement the smallest semantic SvelteKit/Svelte 5 component pass.
```

## Notes

This is a project skill, not a universal skill. It intentionally bakes in PixelBoats HUD, cargo, perk, minimap, and command-bar assumptions.
