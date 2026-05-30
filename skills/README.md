# Agent Skills

This directory is the owned skill library for `ryanspice/agent-skills`.

The current AI Wiki `04_skills/generated` route has been ingested directly into this `skills/` tree instead of being kept under a generated-export folder. The AI Wiki route remains source provenance; this repository is the distribution surface.

Every ingested skill document carries provenance fields:

- `provenance_origin`: `original` or `modified`.
- `provenance_credit`: `Ryan Spice-Finnie` for generated and locally mutated AI Wiki skills.
- `provenance_ingested_as`: `ryanspice/agent-skills owned skill`.
- `provenance_upstream`: present when a skill was adapted from an upstream/source reference.

Text files are normalized to placeholders such as `<AI_WIKI_ROOT>`, `<DEV_ROOT>`, `<SEARCH_ROOT>`, `<DOWNLOADS_ROOT>`, `<USER_HOME>`, and `<LOCAL_HOST>`. Binary package/image files are copied byte-for-byte. See `skills/provenance.json` for the full file manifest.

## Skill Index

| Skill | Origin | Credit | Path | Source |
|---|---|---|---|---|
| `ai-wiki-file-management` | `original` | Ryan Spice-Finnie | `skills/ai-wiki-file-management/SKILL.md` | `04_skills/generated/ai-wiki-file-management/SKILL.md` |
| `AI Wiki Command Layer Notes` | `original` | Ryan Spice-Finnie | `skills/aiwiki-command-layer-notes/SKILL.md` | `04_skills/generated/aiwiki-command-layer-notes/SKILL.md` |
| `aiwiki-command-run-fragments` | `original` | Ryan Spice-Finnie | `skills/aiwiki-command-run-fragments/SKILL.md` | `04_skills/generated/aiwiki-command-run-fragments/SKILL.md` |
| `AI Wiki Console Output` | `original` | Ryan Spice-Finnie | `skills/aiwiki-console-output/SKILL.md` | `04_skills/generated/aiwiki-console-output/SKILL.md` |
| `aiwiki-deep-research-orchestrator` | `original` | Ryan Spice-Finnie | `skills/aiwiki-deep-research-orchestrator/SKILL.md` | `04_skills/generated/aiwiki-deep-research-orchestrator/SKILL.md` |
| `aiwiki-external-skill-intake` | `original` | Ryan Spice-Finnie | `skills/aiwiki-external-skill-intake/SKILL.md` | `04_skills/generated/aiwiki-external-skill-intake/SKILL.md` |
| `aiwiki-skill-registry-mcp-workflow` | `original` | Ryan Spice-Finnie | `skills/aiwiki-skill-registry-mcp-workflow/SKILL.md` | `04_skills/generated/aiwiki-skill-registry-mcp-workflow/SKILL.md` |
| `AI Wiki Svelte Lab Workflow` | `original` | Ryan Spice-Finnie | `skills/aiwiki-svelte-lab-workflow/SKILL.md` | `04_skills/generated/aiwiki-svelte-lab-workflow/SKILL.md` |
| `deep-research-workflow-candidate` | `modified` | Ryan Spice-Finnie | `skills/candidates/deep-research-workflow-candidate-v0.1.0/SKILL.md` | `04_skills/generated/candidates/deep-research-workflow-candidate-v0.1.0/SKILL.md` |
| `Enterprise Deep Research Workflow Candidate` | `modified` | Ryan Spice-Finnie | `skills/candidates/enterprise-deep-research-workflow-candidate-v0.1.0/SKILL.md` | `04_skills/generated/candidates/enterprise-deep-research-workflow-candidate-v0.1.0/SKILL.md` |
| `creating-skills` | `original` | Ryan Spice-Finnie | `skills/creating-skills/SKILL.md` | `04_skills/generated/creating-skills/SKILL.md` |
| `replace-with-context-skill-name` | `original` | Ryan Spice-Finnie | `skills/creating-skills/templates/background-context-skill/SKILL.md` | `04_skills/generated/creating-skills/templates/background-context-skill/SKILL.md` |
| `replace-with-skill-name` | `original` | Ryan Spice-Finnie | `skills/creating-skills/templates/basic-skill/SKILL.md` | `04_skills/generated/creating-skills/templates/basic-skill/SKILL.md` |
| `replace-with-code-tool-skill-name` | `original` | Ryan Spice-Finnie | `skills/creating-skills/templates/code-tool-skill/SKILL.md` | `04_skills/generated/creating-skills/templates/code-tool-skill/SKILL.md` |
| `replace-with-research-skill-name` | `original` | Ryan Spice-Finnie | `skills/creating-skills/templates/research-backed-skill/SKILL.md` | `04_skills/generated/creating-skills/templates/research-backed-skill/SKILL.md` |
| `replace-with-side-effect-skill-name` | `original` | Ryan Spice-Finnie | `skills/creating-skills/templates/safe-side-effect-skill/SKILL.md` | `04_skills/generated/creating-skills/templates/safe-side-effect-skill/SKILL.md` |
| `decorated-wait-action-output` | `original` | Ryan Spice-Finnie | `skills/decorated-wait-action-output-v0.0.1/SKILL.md` | `04_skills/generated/decorated-wait-action-output-v0.0.1/SKILL.md` |
| `decorated-wait-action-output` | `modified` | Ryan Spice-Finnie | `skills/decorated-wait-action-output-v0.0.5/SKILL.md` | `04_skills/generated/decorated-wait-action-output-v0.0.5/SKILL.md` |
| `gpt55-webapp-builder-codex-bridge` | `original` | Ryan Spice-Finnie | `skills/gpt55-webapp-builder-codex-bridge/SKILL.md` | `04_skills/generated/gpt55-webapp-builder-codex-bridge/SKILL.md` |
| `hermes-local-llamacpp-aiwiki-agent` | `original` | Ryan Spice-Finnie | `skills/hermes-local-llamacpp-aiwiki-agent/SKILL.md` | `04_skills/generated/hermes-local-llamacpp-aiwiki-agent/SKILL.md` |
| `image-to-ui-sveltekit` | `original` | Ryan Spice-Finnie | `skills/image-to-ui-sveltekit/SKILL.md` | `04_skills/generated/image-to-ui-sveltekit/SKILL.md` |
| `local-first-storage-architecture` | `original` | Ryan Spice-Finnie | `skills/local-first-storage-architecture/SKILL.md` | `04_skills/generated/local-first-storage-architecture/SKILL.md` |
| `neanderthal` | `original` | Ryan Spice-Finnie | `skills/neanderthal/SKILL.md` | `04_skills/generated/neanderthal/SKILL.md` |
| `pixelboats-fish-water-ecology` | `original` | Ryan Spice-Finnie | `skills/pixelboats-fish-water-ecology/SKILL.md` | `04_skills/generated/pixelboats-fish-water-ecology/SKILL.md` |
| `pixelboats-stormy-hud-lab` | `original` | Ryan Spice-Finnie | `skills/pixelboats-stormy-hud-lab/SKILL.md` | `04_skills/generated/pixelboats-stormy-hud-lab/SKILL.md` |
| `powershell-script-authoring` | `original` | Ryan Spice-Finnie | `skills/powershell-script-authoring/SKILL.md` | `04_skills/generated/powershell-script-authoring/SKILL.md` |
| `book-graphics-design` | `original` | Ryan Spice-Finnie | `skills/prompt-ops-book-skills-v0.2.1/book-graphics-design/SKILL.md` | `04_skills/generated/prompt-ops-book-skills-v0.2.1/book-graphics-design/SKILL.md` |
| `book-reading-review` | `original` | Ryan Spice-Finnie | `skills/prompt-ops-book-skills-v0.2.1/book-reading-review/SKILL.md` | `04_skills/generated/prompt-ops-book-skills-v0.2.1/book-reading-review/SKILL.md` |
| `book-repo-automation` | `original` | Ryan Spice-Finnie | `skills/prompt-ops-book-skills-v0.2.1/book-repo-automation/SKILL.md` | `04_skills/generated/prompt-ops-book-skills-v0.2.1/book-repo-automation/SKILL.md` |
| `ebook-pdf-accessibility-qa` | `original` | Ryan Spice-Finnie | `skills/prompt-ops-book-skills-v0.2.1/ebook-pdf-accessibility-qa/SKILL.md` | `04_skills/generated/prompt-ops-book-skills-v0.2.1/ebook-pdf-accessibility-qa/SKILL.md` |
| `manuscript-editing` | `original` | Ryan Spice-Finnie | `skills/prompt-ops-book-skills-v0.2.1/manuscript-editing/SKILL.md` | `04_skills/generated/prompt-ops-book-skills-v0.2.1/manuscript-editing/SKILL.md` |
| `programming-book-design` | `original` | Ryan Spice-Finnie | `skills/prompt-ops-book-skills-v0.2.1/programming-book-design/SKILL.md` | `04_skills/generated/prompt-ops-book-skills-v0.2.1/programming-book-design/SKILL.md` |
| `prompt-operations-handbook` | `original` | Ryan Spice-Finnie | `skills/prompt-ops-book-skills-v0.2.1/prompt-operations-handbook/SKILL.md` | `04_skills/generated/prompt-ops-book-skills-v0.2.1/prompt-operations-handbook/SKILL.md` |
| `prompt-operations-release-kit` | `original` | Ryan Spice-Finnie | `skills/prompt-ops-book-skills-v0.2.1/prompt-operations-release-kit/SKILL.md` | `04_skills/generated/prompt-ops-book-skills-v0.2.1/prompt-operations-release-kit/SKILL.md` |
| `prompt-operations-storefront` | `original` | Ryan Spice-Finnie | `skills/prompt-ops-book-skills-v0.2.1/prompt-operations-storefront/SKILL.md` | `04_skills/generated/prompt-ops-book-skills-v0.2.1/prompt-operations-storefront/SKILL.md` |
| `publishing-release-operations` | `original` | Ryan Spice-Finnie | `skills/prompt-ops-book-skills-v0.2.1/publishing-release-operations/SKILL.md` | `04_skills/generated/prompt-ops-book-skills-v0.2.1/publishing-release-operations/SKILL.md` |
| `university-textbook-design` | `original` | Ryan Spice-Finnie | `skills/prompt-ops-book-skills-v0.2.1/university-textbook-design/SKILL.md` | `04_skills/generated/prompt-ops-book-skills-v0.2.1/university-textbook-design/SKILL.md` |
| `repo-skill-recommender` | `modified` | Ryan Spice-Finnie | `skills/repo-skill-recommender - Copy/SKILL.md` | `04_skills/generated/repo-skill-recommender - Copy/SKILL.md` |
| `repo-skill-recommender` | `original` | Ryan Spice-Finnie | `skills/repo-skill-recommender/SKILL.md` | `04_skills/generated/repo-skill-recommender/SKILL.md` |
| `sprite-pixel-art-sprite-sheets-gpt55` | `original` | Ryan Spice-Finnie | `skills/sprite-pixel-art-sprite-sheets-gpt55/SKILL.md` | `04_skills/generated/sprite-pixel-art-sprite-sheets-gpt55/SKILL.md` |
| `Svelte Lab Demo Ingestion` | `original` | Ryan Spice-Finnie | `skills/svelte-lab-demo-ingestion/SKILL.md` | `04_skills/generated/svelte-lab-demo-ingestion/SKILL.md` |
| `sveltekit2-bootstrap-discipline` | `original` | Ryan Spice-Finnie | `skills/sveltekit2-bootstrap-discipline/SKILL.md` | `04_skills/generated/sveltekit2-bootstrap-discipline/SKILL.md` |
| `sveltekit2-svelte5-engineering` | `original` | Ryan Spice-Finnie | `skills/sveltekit2-svelte5-engineering/SKILL.md` | `04_skills/generated/sveltekit2-svelte5-engineering/SKILL.md` |
| `universal-prompt-pack-builder` | `modified` | Ryan Spice-Finnie | `skills/universal-prompt-pack-builder/SKILL.md` | `04_skills/generated/universal-prompt-pack-builder/SKILL.md` |
| `verbose-console-output` | `original` | Ryan Spice-Finnie | `skills/verbose-console-output-v0.0.1/SKILL.md` | `04_skills/generated/verbose-console-output-v0.0.1/SKILL.md` |
| `verbose-console-output` | `modified` | Ryan Spice-Finnie | `skills/verbose-console-output-v0.0.5/SKILL.md` | `04_skills/generated/verbose-console-output-v0.0.5/SKILL.md` |
| `vibe-check` | `modified` | Ryan Spice-Finnie | `skills/vibe-guard-pack-aiwiki-adapted/vibe-check/SKILL.md` | `04_skills/generated/vibe-guard-pack-aiwiki-adapted/vibe-check/SKILL.md` |
| `vibe-explain` | `modified` | Ryan Spice-Finnie | `skills/vibe-guard-pack-aiwiki-adapted/vibe-explain/SKILL.md` | `04_skills/generated/vibe-guard-pack-aiwiki-adapted/vibe-explain/SKILL.md` |
| `vibe-guard` | `modified` | Ryan Spice-Finnie | `skills/vibe-guard-pack-aiwiki-adapted/vibe-guard/SKILL.md` | `04_skills/generated/vibe-guard-pack-aiwiki-adapted/vibe-guard/SKILL.md` |
| `vibe-secure` | `modified` | Ryan Spice-Finnie | `skills/vibe-guard-pack-aiwiki-adapted/vibe-secure/SKILL.md` | `04_skills/generated/vibe-guard-pack-aiwiki-adapted/vibe-secure/SKILL.md` |
| `walking-cycle-generation` | `original` | Ryan Spice-Finnie | `skills/walking-cycle-generation/SKILL.md` | `04_skills/generated/walking-cycle-generation/SKILL.md` |
| `windows-phone-metro-design` | `modified` | Ryan Spice-Finnie | `skills/windows-phone-metro-design/SKILL.md` | `04_skills/generated/windows-phone-metro-design/SKILL.md` |
| `windows-tar-package-installer-workflow` | `original` | Ryan Spice-Finnie | `skills/windows-tar-package-installer-workflow/SKILL.md` | `04_skills/generated/windows-tar-package-installer-workflow/SKILL.md` |
