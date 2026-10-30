# Agent Skills

[![Status: development](https://img.shields.io/badge/status-development-b88a3b)](https://github.com/ryanspice/agent-skills) [![Skill validation](https://github.com/ryanspice/agent-skills/actions/workflows/validate.yml/badge.svg)](https://github.com/ryanspice/agent-skills/actions/workflows/validate.yml)

A practical library of reusable skills for AI-assisted engineering, research,
planning, and creative work. Ryan's AI Wiki uses this repository as the
maintained source for its repo-backed skills. Individual skills describe when
to use them, their boundaries, and any supporting material.

## Release and downloads

**Development collection; no repository release or version has been published.**
Individual skill versions do not represent a version of the full library.

- [Download the current main branch as a ZIP](https://github.com/ryanspice/agent-skills/archive/refs/heads/main.zip)
- [Browse source and releases](https://github.com/ryanspice/agent-skills)
- [Review open skill changes](https://github.com/ryanspice/agent-skills/pulls)

The main branch ZIP is a source snapshot, not a versioned release package.

## Get started

Clone the source with Git, then browse the [skill catalog](#skill-inventory-and-fleet-references)
and read the selected skill's `SKILL.md` and supporting files. For example:

```powershell
git clone https://github.com/ryanspice/agent-skills.git
Set-Location agent-skills
npm run check
```

Node.js 18 or newer is required for the repository validator. Installing a
skill into a particular harness is a separate step: a catalog entry alone does
not make it available or prove compatibility. The Codex linker can preview a
single skill and, when ready, create the link:

```powershell
npm run aiwiki:link-codex -- --name send-it
npm run aiwiki:link-codex -- --name send-it --apply
```

The linker uses directory junctions on Windows. Confirm the selected skill is
present in your checkout. The linker's `--all` mode includes candidates and
templates, so select individual skills unless
that broader scope is intentional. Other harnesses need their own supported
installation or discovery process.

## Featured workflows

- **Send It** ? organize authorized work into reviewable pull requests.
- **Code n' Plan** ? use focused code-backed questions to build an actionable plan.
- **Grill Spice** ? pressure-test decisions, with credit to its upstream inspiration.
- **Cross-machine media** ? coordinate creative work and handoffs across machines.
- **Chalk It Up** ? wrap up a finished change using its documented workflow.

### Skill categories

- [Ryan's orchestration workflows](skills/categories/orchestration/README.md)
  bring together his own ways of coordinating work and decisions.
- [Customized supporting skills](skills/categories/customized-support/README.md)
  include technical, research, and decision skills shaped for his needs.
- [External skills](skills/categories/external/README.md) retain substantial
  upstream work, authorship, and applicable license information.

These folders are browsing indexes; canonical skill files remain at their
existing paths. The adapted Vibe Guard pack retains CodeCoincognition's credit
and awaits comparison with upstream before classification. Wayfinder Spice's
origin is unverified. SpiceFlow's earlier influence has not yet been identified.

## Collection scope

The collection includes planning, research, SpiceFlow, workbench, publishing,
and cross-machine media workflows. Review individual skill requirements and
provenance before use; runtime and harness compatibility vary by skill.

<!-- SKILL_INVENTORY_START -->
## Skill inventory and fleet references

Catalog snapshot of the integrated collection. Recheck the source after updates,
as skill content, sizes, and available versions can change. ⭐ pins recently added skills at the top: Cross-machine
Media, Send It, Code n' Plan, and Grill Spice. The remaining order is an
editorial estimate of broadly useful workflows, followed by alphabetical
order; invocation counts are not available, so this is not measured usage.
Size is the exact byte length of `SKILL.md`, not the
whole skill folder or runtime footprint. An origin marked "recorded" is a
repository claim, not independent verification. Adaptations retain the source
credits in the linked skill and `skills/provenance.json`.

For fleet use, the canonical repo source is `AI-Wiki/04_skills/agent-skills/skills`;
link or route a harness to the selected skill rather than making an unmanaged
copy. A listed skill is not necessarily installed, active, or compatible with
every harness. Candidates and templates are not automatic production skills.
Unregistered entries need provenance review.

| Skill | Recorded origin | SKILL.md bytes | Suggested fleet reference |
| --- | --- | ---: | --- |
| ⭐ [cross-machine-media](skills/cross-machine-media/SKILL.md) | Recorded original (Ryan/AI Wiki) | 6,304 | AI Wiki repo skill source |
| ⭐ [send-it](skills/send-it/SKILL.md) | Recorded original (Ryan/AI Wiki) | 3,992 | AI Wiki repo skill source |
| ⭐ [code-and-plan](skills/code-and-plan/SKILL.md) | Recorded original (Ryan/AI Wiki) | 10,285 | AI Wiki repo skill source |
| ⭐ [grill-spice](skills/grill-spice/SKILL.md) | Ryan adaptation; Matt Pocock | 7,366 | AI Wiki repo skill source |
| [chalk-it-up](skills/chalk-it-up/SKILL.md) | Recorded original (Ryan/AI Wiki); not in manifest | 3,003 | Repo checkout; reconcile provenance |
| [spiceflow](skills/spiceflow/SKILL.md) | Customized; influence unknown; unregistered | 28,903 | Repo checkout; reconcile provenance |
| [evidence-first-engineering](skills/evidence-first-engineering/SKILL.md) | Not established; not in manifest | 4,608 | Repo checkout; reconcile provenance |
| [deep-research-workflow](skills/deep-research-workflow/SKILL.md) | Ryan adaptation; external research sources | 3,629 | AI Wiki repo skill source |
| [enterprise-deep-research-workflow](skills/enterprise-deep-research-workflow/SKILL.md) | Ryan adaptation; external research sources | 4,070 | AI Wiki repo skill source |
| [tauri-sveltekit](skills/tauri-sveltekit-svelte/SKILL.md) | Not established; not in manifest | 5,130 | Repo checkout; reconcile provenance |
| [sveltekit2-svelte5-engineering](skills/sveltekit2-svelte5-engineering/SKILL.md) | Recorded original (Ryan/AI Wiki) | 11,053 | AI Wiki repo skill source |
| [blog-publish](skills/blog-publish/SKILL.md) | Recorded original (Ryan/AI Wiki) | 8,446 | AI Wiki repo skill source |
| [systematic-debugging](skills/systematic-debugging/SKILL.md) | Hermes adaptation; obra/superpowers | 10,480 | Repo checkout; reconcile provenance |
| [requesting-code-review](skills/requesting-code-review/SKILL.md) | Hermes adaptation; obra/superpowers, MorAlekss | 8,483 | Repo checkout; reconcile provenance |
| [ai-wiki-file-management](skills/ai-wiki-file-management/SKILL.md) | Recorded original (Ryan/AI Wiki) | 12,337 | AI Wiki repo skill source |
| [powershell-script-authoring](skills/powershell-script-authoring/SKILL.md) | Recorded original (Ryan/AI Wiki) | 13,841 | AI Wiki repo skill source |
| [repo-skill-recommender](skills/repo-skill-recommender/SKILL.md) | Recorded original (Ryan/AI Wiki) | 4,914 | AI Wiki repo skill source |
| [hermes-subprocess-delegation](skills/hermes-subprocess-delegation/SKILL.md) | Recorded original (Ryan/AI Wiki) | 5,878 | AI Wiki repo skill source |
| [fugu-free-model-fleet-operator](skills/fugu-free-model-fleet-operator/SKILL.md) | Recorded original (Ryan/AI Wiki) | 5,706 | AI Wiki repo skill source |
| [repo-skill-recommender](skills/repo-skill-recommender-copy/SKILL.md) | Recorded adaptation; see provenance | 5,809 | AI Wiki repo skill source |
| [resume-tailoring](skills/resume-tailoring/SKILL.md) | Recorded author: Ryan Spice-Finnie (ryanspice), Hermes Agent; not in manifest | 7,314 | Repo checkout; reconcile provenance |
| [seo-live-audit](skills/seo-live-audit/SKILL.md) | Recorded author: Ryan Spice-Finnie (ryanspice), Hermes Agent; not in manifest | 12,612 | Repo checkout; reconcile provenance |
| [Svelte 5 Virtual List](skills/svelte5-virtual-list/SKILL.md) | Not established; not in manifest | 17,009 | Repo checkout; reconcile provenance |
| [sveltekit-lab-route-authoring](skills/sveltekit-lab-route-authoring/SKILL.md) | Not established; not in manifest | 28,507 | Repo checkout; reconcile provenance |
| [agent-conversation-recovery](skills/agent-conversation-recovery/SKILL.md) | Not established | 4,604 | AI Wiki repo skill source |
| [aiwiki-command-layer-notes](skills/aiwiki-command-layer-notes/SKILL.md) | Recorded original (Ryan/AI Wiki) | 1,066 | AI Wiki repo skill source |
| [aiwiki-command-run-fragments](skills/aiwiki-command-run-fragments/SKILL.md) | Recorded original (Ryan/AI Wiki) | 4,582 | AI Wiki repo skill source |
| [aiwiki-console-output](skills/aiwiki-console-output/SKILL.md) | Recorded original (Ryan/AI Wiki) | 1,156 | AI Wiki repo skill source |
| [aiwiki-deep-research-orchestrator](skills/aiwiki-deep-research-orchestrator/SKILL.md) | Recorded original (Ryan/AI Wiki) | 3,775 | AI Wiki repo skill source |
| [aiwiki-external-skill-intake](skills/aiwiki-external-skill-intake/SKILL.md) | Recorded original (Ryan/AI Wiki) | 6,764 | AI Wiki repo skill source |
| [aiwiki-skill-registry-mcp-workflow](skills/aiwiki-skill-registry-mcp-workflow/SKILL.md) | Recorded original (Ryan/AI Wiki) | 3,765 | AI Wiki repo skill source |
| [aiwiki-svelte-lab-workflow](skills/aiwiki-svelte-lab-workflow/SKILL.md) | Recorded original (Ryan/AI Wiki) | 1,049 | AI Wiki repo skill source |
| [spiceflow-artifact-forge](skills/artifact-forge/SKILL.md) | Not established; not in manifest | 5,014 | Repo checkout; reconcile provenance |
| [aurora-dev-os-devops](skills/aurora-dev-os-devops/SKILL.md) | Not established; not in manifest | 55,640 | Repo checkout; reconcile provenance |
| [bmo-agent-benchmark](skills/bmo-agent-benchmark/SKILL.md) | Not established | 15,502 | AI Wiki repo skill source |
| [deep-research-workflow-candidate](skills/candidates/deep-research-workflow-candidate-v0.1.0/SKILL.md) | Ryan adaptation; external research sources | 7,254 | Repo candidate; review before use |
| [deepseek-research-api-substrate](skills/candidates/deepseek-research-api-substrate-v0.1.0/SKILL.md) | Recorded original (Ryan/AI Wiki) | 2,425 | Repo candidate; review before use |
| [enterprise-deep-research-workflow-candidate-v0.1.0](skills/candidates/enterprise-deep-research-workflow-candidate-v0.1.0/SKILL.md) | Ryan adaptation; external research sources | 5,347 | Repo candidate; review before use |
| [cjk-ui-lab](skills/cjk-ui-lab/SKILL.md) | Recorded original (Ryan/AI Wiki) | 8,402 | AI Wiki repo skill source |
| [creating-skills](skills/creating-skills/SKILL.md) | Recorded original (Ryan/AI Wiki) | 14,071 | AI Wiki repo skill source |
| [replace-with-context-skill-name](skills/creating-skills/templates/background-context-skill/SKILL.md) | Recorded original (Ryan/AI Wiki) | 1,185 | Repo template; scaffold only |
| [replace-with-skill-name](skills/creating-skills/templates/basic-skill/SKILL.md) | Recorded original (Ryan/AI Wiki) | 1,272 | Repo template; scaffold only |
| [replace-with-code-tool-skill-name](skills/creating-skills/templates/code-tool-skill/SKILL.md) | Recorded original (Ryan/AI Wiki) | 1,391 | Repo template; scaffold only |
| [replace-with-research-skill-name](skills/creating-skills/templates/research-backed-skill/SKILL.md) | Recorded original (Ryan/AI Wiki) | 1,526 | Repo template; scaffold only |
| [replace-with-side-effect-skill-name](skills/creating-skills/templates/safe-side-effect-skill/SKILL.md) | Recorded original (Ryan/AI Wiki) | 1,452 | Repo template; scaffold only |
| [decorated-wait-action-output](skills/decorated-wait-action-output-v0.0.1/SKILL.md) | Recorded original (Ryan/AI Wiki) | 4,500 | AI Wiki repo skill source |
| [decorated-wait-action-output](skills/decorated-wait-action-output-v0.0.5/SKILL.md) | Ryan revision of decorated-wait v0.0.1 | 7,706 | AI Wiki repo skill source |
| [gpt55-webapp-builder-codex-bridge](skills/gpt55-webapp-builder-codex-bridge/SKILL.md) | Recorded original (Ryan/AI Wiki) | 10,752 | AI Wiki repo skill source |
| [hermes-local-llamacpp-aiwiki-agent](skills/hermes-local-llamacpp-aiwiki-agent/SKILL.md) | Recorded original (Ryan/AI Wiki) | 8,683 | AI Wiki repo skill source |
| [hermes-table-renderer](skills/hermes-table-renderer/SKILL.md) | Recorded original (Ryan/AI Wiki) | 9,557 | AI Wiki repo skill source |
| [image-to-ui-sveltekit](skills/image-to-ui-sveltekit/SKILL.md) | Recorded original (Ryan/AI Wiki) | 15,068 | AI Wiki repo skill source |
| [local-first-storage-architecture](skills/local-first-storage-architecture/SKILL.md) | Recorded original (Ryan/AI Wiki) | 4,030 | AI Wiki repo skill source |
| [spiceflow-mcp-bridge](skills/mcp-bridge/SKILL.md) | Not established; not in manifest | 4,863 | Repo checkout; reconcile provenance |
| [neanderthal](skills/neanderthal/SKILL.md) | Recorded original (Ryan/AI Wiki) | 2,451 | AI Wiki repo skill source |
| [pixelboats-authority-resolution](skills/pixelboats-authority-resolution/SKILL.md) | Not established; not in manifest | 4,529 | Repo checkout; reconcile provenance |
| [pixelboats-fish-water-ecology](skills/pixelboats-fish-water-ecology/SKILL.md) | Recorded original (Ryan/AI Wiki) | 3,748 | AI Wiki repo skill source |
| [pixelboats-lab-to-runtime-promotion](skills/pixelboats-lab-to-runtime-promotion/SKILL.md) | Not established; not in manifest | 4,817 | Repo checkout; reconcile provenance |
| [pixelboats-stage-verification](skills/pixelboats-stage-verification/SKILL.md) | Not established; not in manifest | 4,354 | Repo checkout; reconcile provenance |
| [pixelboats-stormy-hud-lab](skills/pixelboats-stormy-hud-lab/SKILL.md) | Recorded original (Ryan/AI Wiki) | 13,821 | AI Wiki repo skill source |
| [book-graphics-design](skills/prompt-ops-book-skills-v0.2.1/book-graphics-design/SKILL.md) | Recorded original (Ryan/AI Wiki) | 778 | AI Wiki repo skill source |
| [book-reading-review](skills/prompt-ops-book-skills-v0.2.1/book-reading-review/SKILL.md) | Recorded original (Ryan/AI Wiki) | 755 | AI Wiki repo skill source |
| [book-repo-automation](skills/prompt-ops-book-skills-v0.2.1/book-repo-automation/SKILL.md) | Recorded original (Ryan/AI Wiki) | 971 | AI Wiki repo skill source |
| [ebook-pdf-accessibility-qa](skills/prompt-ops-book-skills-v0.2.1/ebook-pdf-accessibility-qa/SKILL.md) | Recorded original (Ryan/AI Wiki) | 789 | AI Wiki repo skill source |
| [manuscript-editing](skills/prompt-ops-book-skills-v0.2.1/manuscript-editing/SKILL.md) | Recorded original (Ryan/AI Wiki) | 764 | AI Wiki repo skill source |
| [programming-book-design](skills/prompt-ops-book-skills-v0.2.1/programming-book-design/SKILL.md) | Recorded original (Ryan/AI Wiki) | 823 | AI Wiki repo skill source |
| [prompt-operations-handbook](skills/prompt-ops-book-skills-v0.2.1/prompt-operations-handbook/SKILL.md) | Recorded original (Ryan/AI Wiki) | 1,377 | AI Wiki repo skill source |
| [prompt-operations-release-kit](skills/prompt-ops-book-skills-v0.2.1/prompt-operations-release-kit/SKILL.md) | Recorded original (Ryan/AI Wiki) | 1,321 | AI Wiki repo skill source |
| [prompt-operations-storefront](skills/prompt-ops-book-skills-v0.2.1/prompt-operations-storefront/SKILL.md) | Recorded original (Ryan/AI Wiki) | 1,191 | AI Wiki repo skill source |
| [publishing-release-operations](skills/prompt-ops-book-skills-v0.2.1/publishing-release-operations/SKILL.md) | Recorded original (Ryan/AI Wiki) | 1,032 | AI Wiki repo skill source |
| [university-textbook-design](skills/prompt-ops-book-skills-v0.2.1/university-textbook-design/SKILL.md) | Recorded original (Ryan/AI Wiki) | 835 | AI Wiki repo skill source |
| [research-harness-archive-operator](skills/research-harness-archive-operator/SKILL.md) | Not established | 6,060 | AI Wiki repo skill source |
| [spiceflow-skill-forge](skills/skill-forge/SKILL.md) | Not established; not in manifest | 5,408 | Repo checkout; reconcile provenance |
| [social-preview-unfurl-verification](skills/social-preview-unfurl-verification/SKILL.md) | Recorded original (Ryan/AI Wiki); not in manifest | 6,871 | Repo checkout; reconcile provenance |
| [sprite-pixel-art-sprite-sheets-gpt55](skills/sprite-pixel-art-sprite-sheets-gpt55/SKILL.md) | Recorded original (Ryan/AI Wiki) | 7,248 | AI Wiki repo skill source |
| [svelte-lab-demo-ingestion](skills/svelte-lab-demo-ingestion/SKILL.md) | Recorded original (Ryan/AI Wiki) | 1,112 | AI Wiki repo skill source |
| [sveltekit2-bootstrap-discipline](skills/sveltekit2-bootstrap-discipline/SKILL.md) | Recorded original (Ryan/AI Wiki) | 3,790 | AI Wiki repo skill source |
| [universal-prompt-pack-builder](skills/universal-prompt-pack-builder/SKILL.md) | Ryan revision of local source reference | 30,427 | AI Wiki repo skill source |
| [verbose-console-output](skills/verbose-console-output-v0.0.1/SKILL.md) | Recorded original (Ryan/AI Wiki) | 4,668 | AI Wiki repo skill source |
| [verbose-console-output](skills/verbose-console-output-v0.0.5/SKILL.md) | Ryan revision of verbose-console v0.0.1 | 9,645 | AI Wiki repo skill source |
| [vibe-check](skills/vibe-guard-pack-aiwiki-adapted/vibe-check/SKILL.md) | Ryan adaptation; CodeCoincognition | 4,596 | AI Wiki repo skill source |
| [vibe-explain](skills/vibe-guard-pack-aiwiki-adapted/vibe-explain/SKILL.md) | Ryan adaptation; CodeCoincognition | 4,596 | AI Wiki repo skill source |
| [vibe-guard](skills/vibe-guard-pack-aiwiki-adapted/vibe-guard/SKILL.md) | Ryan adaptation; CodeCoincognition | 4,825 | AI Wiki repo skill source |
| [vibe-secure](skills/vibe-guard-pack-aiwiki-adapted/vibe-secure/SKILL.md) | Ryan adaptation; CodeCoincognition | 5,234 | AI Wiki repo skill source |
| [vibe-guard](skills/vibe-guard/SKILL.md) | Not established; not in manifest | 16,629 | Repo checkout; reconcile provenance |
| [walking-cycle-generation](skills/walking-cycle-generation/SKILL.md) | Recorded original (Ryan/AI Wiki) | 10,590 | AI Wiki repo skill source |
| [windows-phone-metro-design](skills/windows-phone-metro-design/SKILL.md) | Ryan revision of local source reference | 5,946 | AI Wiki repo skill source |
| [windows-tar-package-installer-workflow](skills/windows-tar-package-installer-workflow/SKILL.md) | Recorded original (Ryan/AI Wiki) | 4,187 | AI Wiki repo skill source |
| [workbench-console-safety-operator](skills/workbench-console-safety-operator/SKILL.md) | Not established | 8,137 | AI Wiki repo skill source |
<!-- SKILL_INVENTORY_END -->

## AI Wiki and fleet integration

The canonical repo-backed source in the Wiki is
`AI-Wiki/04_skills/agent-skills/skills`. Keep one authoritative skill source;
use the harness's supported links or pointers instead of unmanaged copies.
Project overlays and candidate shelves remain separate and may intentionally
have different scope.

On a machine with an AI Wiki checkout, set the actual root before running the
integration helpers; do not assume another computer's drive letter:

```powershell
$env:AIWIKI_ROOT = '<absolute path to AI-Wiki>'
npm run aiwiki:status
npm run aiwiki:rebuild-indexes
```

Index rebuilding defaults to a dry run; use `-- --apply` only after reviewing
the results and the repository's duplicate-selection policy. Inspect the
linker's help for `--copy`, `--replace`, and destination options.

## Validation

```powershell
npm run check
npm test
npm run build
```

The three commands currently run the same dependency-free provenance
validator, which also checks Git-tracked and nonignored text files for common
personal absolute paths. The CI badge reflects that workflow; it does not
establish that every skill is registered, valid for every harness, or tested at runtime.
Validate the relevant skill and harness separately before relying on it.

## Attribution and license

The collection includes Ryan-authored workflows, customized adaptations, and
skills retaining third-party authorship. See the skill files and
[provenance records](skills/provenance.json) for recorded credits. Some entries
still need provenance reconciliation; a repository location alone does not
establish authorship.

No repository-wide license has been established. Individual skills may state
their own terms; review those terms and upstream sources before reuse.
