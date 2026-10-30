# Agent Skills

[![Version: v0.1.0](https://img.shields.io/badge/version-v0.1.0-b88a3b)](https://github.com/ryanspice/agent-skills/tree/v0.1.0) [![Status: development](https://img.shields.io/badge/status-development-b88a3b)](https://github.com/ryanspice/agent-skills) [![Skill validation](https://github.com/ryanspice/agent-skills/actions/workflows/validate.yml/badge.svg)](https://github.com/ryanspice/agent-skills/actions/workflows/validate.yml)

A practical library of reusable skills for AI-assisted engineering, research,
planning, and creative work. Ryan's AI Wiki uses this repository as the
maintained source for its repo-backed skills. Individual skills describe when
to use them, their boundaries, and any supporting material.

## Release and downloads

**v0.1.0 is the first development baseline** for the collection. Skills and
harness integrations will continue to evolve; individual skill versions do not
represent the version of the full library.

- [Download the v0.1.0 source ZIP](https://github.com/ryanspice/agent-skills/archive/refs/tags/v0.1.0.zip)
- [Download the current main branch as a ZIP](https://github.com/ryanspice/agent-skills/archive/refs/heads/main.zip)
- [Browse source and releases](https://github.com/ryanspice/agent-skills)
- [Review open skill changes](https://github.com/ryanspice/agent-skills/pulls)

The versioned ZIP captures the v0.1.0 source; the main branch ZIP follows
ongoing development.
PixelBoats-specific skills are maintained in the AI Wiki project shelf and
PixelBoats project, rather than distributed in this shared catalog.

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

- **Send It** - organize authorized work into reviewable pull requests.
- **Code n' Plan** - use focused code-backed questions to build an actionable plan.
- **Grill Spice** - pressure-test decisions, with credit to its upstream inspiration.
- **Cross-machine media** - coordinate creative work and handoffs across machines.
- **Chalk It Up** - wrap up a finished change using its documented workflow.

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
as skill content, sizes, and available versions can change. ⭐ highlights
skills selected as especially worth exploring, including new and established
workflows. Selection is case by case, not a usage or quality ranking. Browse
related skills in the collapsed groups below.
Size is the exact byte length of `SKILL.md`, not the
whole skill folder or runtime footprint. An origin marked "recorded" is a
repository claim, not independent verification. Adaptations retain the source
credits in the linked skill and `skills/provenance.json`.

For fleet use, the canonical repo source is `AI-Wiki/04_skills/agent-skills/skills`;
link or route a harness to the selected skill rather than making an unmanaged
copy. A listed skill is not necessarily installed, active, or compatible with
every harness. Candidates and templates are not automatic production skills.
Some registered entries still have unknown or unverified origins.

**Originality estimates:** The circle indicates estimated contribution: filled
is 100%, three-quarter is around 80%, half is around 50%, and `?` means there
isn't enough evidence to estimate. `~` marks a coarse, low-confidence judgment;
it is not a measured share of text, a claim of entirely novel ideas, or a legal
ownership determination. Estimates based on recorded provenance are provisional.
See the [assessment notes](docs/skill-originality-assessment.md) for the basis
and confidence for every skill. A question mark does not mean 0%.

### ⭐ Standout skills

Starred skills are curated for their distinctive workflows or practical value.
Grill Spice is customized support with upstream credit.

| Skill | Estimated originality and recorded origin | SKILL.md bytes | Suggested fleet reference | What sets it apart |
| --- | --- | ---: | --- | --- |
| ⭐ ⚙️ [cross-machine-media](skills/cross-machine-media/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 6,304 | AI Wiki repo skill source | Coordinates creative work across machines with workload and handoff checks. |
| ⭐ ⚙️ [send-it](skills/send-it/SKILL.md) | ● 100% (owner-confirmed); Recorded original (Ryan/AI Wiki) | 3,992 | AI Wiki repo skill source | Organizes authorized changes into reviewable PRs; no automatic merge. |
| ⭐ 🤓 [code-and-plan](skills/code-and-plan/SKILL.md) | ● 100% (owner-confirmed); Recorded original (Ryan/AI Wiki) | 10,285 | AI Wiki repo skill source | Alternates focused questions and code sketches to refine a build plan. |
| ⭐ 🤓 [grill-spice](skills/grill-spice/SKILL.md) | ◕ ~80% (low confidence); Ryan adaptation; Matt Pocock | 7,366 | AI Wiki repo skill source | Challenges one consequential decision at a time using evidence. |
| ⭐ 🧠 [neanderthal](skills/neanderthal/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 2,451 | AI Wiki repo skill source | Compressed, high-signal engineering mode for low-token handoffs and execution. |
| ⭐ 💻 [powershell-script-authoring](skills/powershell-script-authoring/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 13,841 | AI Wiki repo skill source | Focuses on Windows PowerShell scripts, installers, and packaging. |
| ⭐ 🔧 [chalk-it-up](skills/chalk-it-up/SKILL.md) | ● 100% (owner-confirmed); Recorded original (Ryan/AI Wiki) | 3,076 | AI Wiki repo skill source | Wraps up completed work through issue, PR, checks, and an explicitly requested merge. |
| ⭐ ❤️ [spiceflow](skills/spiceflow/SKILL.md) | ❔ ? (low confidence); Customized; influence unknown | 29,271 | AI Wiki repo skill source | A broad personal operating mode spanning engineering, research, and creative work. |
| ⭐ 🧭 [evidence-first-engineering](skills/evidence-first-engineering/SKILL.md) | ❔ ? (low confidence); Not established | 4,919 | AI Wiki repo skill source | Requires evidence before asserting gaps, absence, or severity. |

### ❤️ Personal orchestration

These workflows are shaped around Ryan's ways of working. SpiceFlow appears
here as well as among the standouts; its earlier influence remains unidentified.

| Skill | Estimated originality and recorded origin | SKILL.md bytes | Suggested fleet reference | What sets it apart |
| --- | --- | ---: | --- | --- |
| ⭐ ❤️ [spiceflow](skills/spiceflow/SKILL.md) | ❔ ? (low confidence); Customized; influence unknown | 29,271 | AI Wiki repo skill source | A broad personal operating mode spanning engineering, research, and creative work. |
| ❤️ [spiceflow-artifact-forge](skills/artifact-forge/SKILL.md) | ❔ ? (low confidence); Not established | 5,387 | AI Wiki repo skill source | Packages durable, versioned TAR.GZ handoffs and implementation bundles. |
| ❤️ [spiceflow-mcp-bridge](skills/mcp-bridge/SKILL.md) | ❔ ? (low confidence); Not established | 5,232 | AI Wiki repo skill source | Maps connected sources through capability-based MCP adapters. |
| ❤️ [spiceflow-skill-forge](skills/skill-forge/SKILL.md) | ❔ ? (low confidence); Not established | 5,778 | AI Wiki repo skill source | Derives reusable skills from repeated workflows and evidence. |

### Browse by topic

Groups are for navigation and do not by themselves establish authorship.

<details>
<summary>Deep research (7 skills)</summary>

| Skill | Estimated originality and recorded origin | SKILL.md bytes | Suggested fleet reference | What sets it apart |
| --- | --- | ---: | --- | --- |
| 🔬 [deep-research-workflow](skills/deep-research-workflow/SKILL.md) | ❔ ? (low confidence); Ryan adaptation; external research sources | 3,629 | AI Wiki repo skill source | A promoted research workflow with source-grounded synthesis. |
| 🔬 [deep-research-workflow-candidate](skills/candidates/deep-research-workflow-candidate-v0.1.0/SKILL.md) | ❔ ? (low confidence); Ryan adaptation; external research sources | 7,254 | Repo candidate; review before use | Candidate synthesis of external deep-research patterns; retained beside the promoted workflow. |
| 🔬 [deepseek-research-api-substrate](skills/candidates/deepseek-research-api-substrate-v0.1.0/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 2,425 | Repo candidate; review before use | Candidate API substrate for DeepSeek-backed research orchestration. |
| 🔬 [enterprise-deep-research-workflow](skills/enterprise-deep-research-workflow/SKILL.md) | ❔ ? (low confidence); Ryan adaptation; external research sources | 4,070 | AI Wiki repo skill source | Adds enterprise-oriented research controls and handoff structure. |
| 🔬 [enterprise-deep-research-workflow-candidate-v0.1.0](skills/candidates/enterprise-deep-research-workflow-candidate-v0.1.0/SKILL.md) | ❔ ? (low confidence); Ryan adaptation; external research sources | 5,347 | Repo candidate; review before use | Candidate enterprise research architecture retained beside the promoted workflow. |
| 📚 [aiwiki-deep-research-orchestrator](skills/aiwiki-deep-research-orchestrator/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 3,775 | AI Wiki repo skill source | Coordinates deep-research tasks in the AI Wiki environment. |
| 🧩 [research-harness-archive-operator](skills/research-harness-archive-operator/SKILL.md) | ❔ ? (low confidence); Not established | 6,060 | AI Wiki repo skill source | Curates research and multi-harness artifacts into the Wiki archive. |

</details>

<details>
<summary>Fugu, Hermes, and agent fleet (8 skills)</summary>

| Skill | Estimated originality and recorded origin | SKILL.md bytes | Suggested fleet reference | What sets it apart |
| --- | --- | ---: | --- | --- |
| 💬 [agent-conversation-recovery](skills/agent-conversation-recovery/SKILL.md) | ❔ ? (low confidence); Not established | 4,604 | AI Wiki repo skill source | Recovers and resumes persisted conversations across supported agent harnesses. |
| 📊 [bmo-agent-benchmark](skills/bmo-agent-benchmark/SKILL.md) | ❔ ? (low confidence); Not established | 15,502 | AI Wiki repo skill source | Defines a bounded, reproducible BMO agent comparison and scoring workflow. |
| 🤖 [fugu-free-model-fleet-operator](skills/fugu-free-model-fleet-operator/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 5,706 | AI Wiki repo skill source | Maintains exact free-model routes with staged configuration and canaries. |
| 🤖 [gpt55-webapp-builder-codex-bridge](skills/gpt55-webapp-builder-codex-bridge/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 10,752 | AI Wiki repo skill source | Bridges ChatGPT web-app sessions to reviewable Codex-style handoffs. |
| 🤖 [hermes-local-llamacpp-aiwiki-agent](skills/hermes-local-llamacpp-aiwiki-agent/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 8,683 | AI Wiki repo skill source | Runs a local-first Hermes Wiki agent using llama.cpp. |
| 🤖 [hermes-subprocess-delegation](skills/hermes-subprocess-delegation/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 5,878 | AI Wiki repo skill source | Dispatches bounded Hermes subprocess lanes through profile adapters. |
| 📊 [hermes-table-renderer](skills/hermes-table-renderer/SKILL.md) | ❔ ? (low confidence); Recorded original (Ryan/AI Wiki) | 9,557 | AI Wiki repo skill source | Defines a structured table contract across terminal and data formats. |
| 🛡️ [workbench-console-safety-operator](skills/workbench-console-safety-operator/SKILL.md) | ❔ ? (low confidence); Not established | 8,137 | AI Wiki repo skill source | Checks and restores console-safe operations across agent workbenches. |

</details>

<details>
<summary>Vibe Guard (5 skills)</summary>

| Skill | Estimated originality and recorded origin | SKILL.md bytes | Suggested fleet reference | What sets it apart |
| --- | --- | ---: | --- | --- |
| 🛡️ [vibe-check](skills/vibe-guard-pack-aiwiki-adapted/vibe-check/SKILL.md) | ◐ ~50% (low confidence); Ryan adaptation; CodeCoincognition | 4,596 | AI Wiki repo skill source | Focuses on production resilience and failure modes. |
| 💬 [vibe-explain](skills/vibe-guard-pack-aiwiki-adapted/vibe-explain/SKILL.md) | ◐ ~50% (low confidence); Ryan adaptation; CodeCoincognition | 4,596 | AI Wiki repo skill source | Focuses on comprehension and cognitive debt. |
| 🛡️ [vibe-guard](skills/vibe-guard-pack-aiwiki-adapted/vibe-guard/SKILL.md) | ◐ ~50% (low confidence); Ryan adaptation; CodeCoincognition | 4,825 | AI Wiki repo skill source | Orchestrates resilience, security, and comprehension review. |
| 🛡️ [vibe-guard](skills/vibe-guard/SKILL.md) | ❔ ? (low confidence); Not established | 16,940 | AI Wiki repo skill source | Broad repo-wide guardrails for AI-generated changes; distinct from the adapted audit pack. |
| 🔒 [vibe-secure](skills/vibe-guard-pack-aiwiki-adapted/vibe-secure/SKILL.md) | ◐ ~50% (low confidence); Ryan adaptation; CodeCoincognition | 5,234 | AI Wiki repo skill source | Focuses specifically on security risk in AI-assisted code. |

</details>

<details>
<summary>AI Wiki and skill discovery (10 skills)</summary>

| Skill | Estimated originality and recorded origin | SKILL.md bytes | Suggested fleet reference | What sets it apart |
| --- | --- | ---: | --- | --- |
| 📚 [ai-wiki-file-management](skills/ai-wiki-file-management/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 12,337 | AI Wiki repo skill source | Maintains canonical Wiki files, staging, and project overlays. |
| 📚 [aiwiki-command-layer-notes](skills/aiwiki-command-layer-notes/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 1,066 | AI Wiki repo skill source | Documents the AI Wiki command layer and its integration conventions. |
| 📚 [aiwiki-command-run-fragments](skills/aiwiki-command-run-fragments/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 4,582 | AI Wiki repo skill source | Loads Wiki Run and Search fragments with progress and health checks. |
| 📚 [aiwiki-console-output](skills/aiwiki-console-output/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 1,156 | AI Wiki repo skill source | Defines console output conventions for AI Wiki operations. |
| 📚 [aiwiki-external-skill-intake](skills/aiwiki-external-skill-intake/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 6,764 | AI Wiki repo skill source | Stages external skill imports with provenance and candidate review. |
| 📚 [aiwiki-skill-registry-mcp-workflow](skills/aiwiki-skill-registry-mcp-workflow/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 3,765 | AI Wiki repo skill source | Connects Wiki skill scans, candidate intake, and MCP wrappers. |
| 📚 [aiwiki-svelte-lab-workflow](skills/aiwiki-svelte-lab-workflow/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 1,049 | AI Wiki repo skill source | Connects Svelte lab work with AI Wiki workflow and handoffs. |
| 🛠️ [creating-skills](skills/creating-skills/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 14,071 | AI Wiki repo skill source | Builds and packages reusable skills and their supporting resources. |
| 🧭 [repo-skill-recommender](skills/repo-skill-recommender/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 4,914 | AI Wiki repo skill source | Selects skills and integration pointers based on a repository audit. |
| 🧭 [repo-skill-recommender](skills/repo-skill-recommender-copy/SKILL.md) | ● ~100% (low confidence); Recorded adaptation; see provenance | 5,809 | AI Wiki repo skill source | Retained modified duplicate; check the selection policy before use. |

</details>

<details>
<summary>Svelte, Tauri, and UI (8 skills)</summary>

| Skill | Estimated originality and recorded origin | SKILL.md bytes | Suggested fleet reference | What sets it apart |
| --- | --- | ---: | --- | --- |
| 🌐 [cjk-ui-lab](skills/cjk-ui-lab/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 8,402 | AI Wiki repo skill source | Focuses on Japanese/Korean UI, typography, and localization. |
| <img src="assets/icons/svelte.svg" alt="Svelte" width="16" height="16"> [image-to-ui-sveltekit](skills/image-to-ui-sveltekit/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 15,068 | AI Wiki repo skill source | Translates visual references into SvelteKit implementation guidance. |
| <img src="assets/icons/svelte.svg" alt="Svelte" width="16" height="16"> [Svelte 5 Virtual List](skills/svelte5-virtual-list/SKILL.md) | ❔ ? (low confidence); Not established | 17,324 | AI Wiki repo skill source | Addresses virtualization for large lists, tables, grids, and feeds. |
| <img src="assets/icons/svelte.svg" alt="Svelte" width="16" height="16"> [svelte-lab-demo-ingestion](skills/svelte-lab-demo-ingestion/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 1,112 | AI Wiki repo skill source | Moves Svelte lab demos into the AI Wiki ingestion workflow. |
| <img src="assets/icons/svelte.svg" alt="Svelte" width="16" height="16"> [sveltekit-lab-route-authoring](skills/sveltekit-lab-route-authoring/SKILL.md) | ❔ ? (low confidence); Not established | 28,821 | AI Wiki repo skill source | Creates SvelteKit lab routes and project debug/documentation pages. |
| <img src="assets/icons/svelte.svg" alt="Svelte" width="16" height="16"> [sveltekit2-bootstrap-discipline](skills/sveltekit2-bootstrap-discipline/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 3,790 | AI Wiki repo skill source | Targets new-project setup, official add-ons, and migrations. |
| <img src="assets/icons/svelte.svg" alt="Svelte" width="16" height="16"> [sveltekit2-svelte5-engineering](skills/sveltekit2-svelte5-engineering/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 11,053 | AI Wiki repo skill source | Covers SvelteKit routes, Svelte 5 runes, data loading, and hydration. |
| <img src="assets/icons/tauri.svg" alt="Tauri" width="16" height="16"> <img src="assets/icons/svelte.svg" alt="Svelte" width="16" height="16"> [tauri-sveltekit](skills/tauri-sveltekit-svelte/SKILL.md) | ❔ ? (low confidence); Not established | 5,453 | AI Wiki repo skill source | Adds desktop, Rust, tray, and window concerns to SvelteKit work. |

</details>

<details>
<summary>Publishing and career (4 skills)</summary>

| Skill | Estimated originality and recorded origin | SKILL.md bytes | Suggested fleet reference | What sets it apart |
| --- | --- | ---: | --- | --- |
| 🔧 [blog-publish](skills/blog-publish/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 8,376 | AI Wiki repo skill source | Targets the two existing blogs and their article-release workflows. |
| 📄 [resume-tailoring](skills/resume-tailoring/SKILL.md) | ❔ ? (low confidence); Recorded author: Ryan Spice-Finnie (ryanspice), Hermes Agent | 7,682 | AI Wiki repo skill source | Tailors a resume from canonical career data while preserving factual boundaries. |
| 🔎 [seo-live-audit](skills/seo-live-audit/SKILL.md) | ❔ ? (low confidence); Recorded author: Ryan Spice-Finnie (ryanspice), Hermes Agent | 12,978 | AI Wiki repo skill source | Audits live pages and turns SEO findings into regression checks. |
| 🔗 [social-preview-unfurl-verification](skills/social-preview-unfurl-verification/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 6,871 | AI Wiki repo skill source | Verifies crawler-visible Open Graph and social preview behavior. |

</details>

<details>
<summary>External review and debugging (2 skills)</summary>

| Skill | Estimated originality and recorded origin | SKILL.md bytes | Suggested fleet reference | What sets it apart |
| --- | --- | ---: | --- | --- |
| 🔍 [requesting-code-review](skills/requesting-code-review/SKILL.md) | ❔ ? (low confidence); Hermes adaptation; obra/superpowers, MorAlekss | 8,886 | AI Wiki repo skill source | Runs pre-commit security and quality checks. |
| 🐛 [systematic-debugging](skills/systematic-debugging/SKILL.md) | ❔ ? (low confidence); Hermes adaptation; obra/superpowers | 10,853 | AI Wiki repo skill source | Uses four root-cause phases before proposing fixes. |

</details>

<details>
<summary>Books and Prompt Operations (11 skills)</summary>

| Skill | Estimated originality and recorded origin | SKILL.md bytes | Suggested fleet reference | What sets it apart |
| --- | --- | ---: | --- | --- |
| 📚 [book-graphics-design](skills/prompt-ops-book-skills-v0.2.1/book-graphics-design/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 778 | AI Wiki repo skill source | Plans book covers, diagrams, and illustration systems. |
| 📚 [book-reading-review](skills/prompt-ops-book-skills-v0.2.1/book-reading-review/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 755 | AI Wiki repo skill source | Reviews and compares books while limiting quotation. |
| 📚 [book-repo-automation](skills/prompt-ops-book-skills-v0.2.1/book-repo-automation/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 971 | AI Wiki repo skill source | Organizes book repositories and documentation-as-code scripts. |
| 📚 [ebook-pdf-accessibility-qa](skills/prompt-ops-book-skills-v0.2.1/ebook-pdf-accessibility-qa/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 789 | AI Wiki repo skill source | Checks accessibility and navigation of ebook and PDF exports. |
| 📚 [manuscript-editing](skills/prompt-ops-book-skills-v0.2.1/manuscript-editing/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 764 | AI Wiki repo skill source | Separates structural, line, copy, and proofreading passes. |
| 📚 [programming-book-design](skills/prompt-ops-book-skills-v0.2.1/programming-book-design/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 823 | AI Wiki repo skill source | Designs programming books around runnable examples and exercises. |
| 📚 [prompt-operations-handbook](skills/prompt-ops-book-skills-v0.2.1/prompt-operations-handbook/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 1,377 | AI Wiki repo skill source | Project-specific handbook canon, editions, and releases. |
| 📚 [prompt-operations-release-kit](skills/prompt-ops-book-skills-v0.2.1/prompt-operations-release-kit/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 1,321 | AI Wiki repo skill source | Project-specific paid handbook packaging workflow. |
| 📚 [prompt-operations-storefront](skills/prompt-ops-book-skills-v0.2.1/prompt-operations-storefront/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 1,191 | AI Wiki repo skill source | Project-specific sales and download surface workflow. |
| 📚 [publishing-release-operations](skills/prompt-ops-book-skills-v0.2.1/publishing-release-operations/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 1,032 | AI Wiki repo skill source | Plans publication artifacts, changelogs, and edition boundaries. |
| 📚 [university-textbook-design](skills/prompt-ops-book-skills-v0.2.1/university-textbook-design/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 835 | AI Wiki repo skill source | Designs textbooks with learning objectives and assessments. |

</details>

<details>
<summary>Skill templates (5 skills)</summary>

| Skill | Estimated originality and recorded origin | SKILL.md bytes | Suggested fleet reference | What sets it apart |
| --- | --- | ---: | --- | --- |
| 🧩 [replace-with-code-tool-skill-name](skills/creating-skills/templates/code-tool-skill/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 1,391 | Repo template; scaffold only | Template for skills backed by a deterministic helper. |
| 🧩 [replace-with-context-skill-name](skills/creating-skills/templates/background-context-skill/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 1,185 | Repo template; scaffold only | Template for context skills; not an independently runnable skill. |
| 🧩 [replace-with-research-skill-name](skills/creating-skills/templates/research-backed-skill/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 1,526 | Repo template; scaffold only | Template for workflows derived from research and source material. |
| 🧩 [replace-with-side-effect-skill-name](skills/creating-skills/templates/safe-side-effect-skill/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 1,452 | Repo template; scaffold only | Template for explicit authorization around side effects. |
| 🧩 [replace-with-skill-name](skills/creating-skills/templates/basic-skill/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 1,272 | Repo template; scaffold only | Template for a general-purpose skill; replace its placeholder. |

</details>

<details>
<summary>Engineering, creative work, and utilities (10 skills)</summary>

| Skill | Estimated originality and recorded origin | SKILL.md bytes | Suggested fleet reference | What sets it apart |
| --- | --- | ---: | --- | --- |
| 💻 [decorated-wait-action-output](skills/decorated-wait-action-output-v0.0.1/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 4,500 | AI Wiki repo skill source | Earlier version focused on reassuring waiting-state console output. |
| 💻 [decorated-wait-action-output](skills/decorated-wait-action-output-v0.0.5/SKILL.md) | ● ~100% (low confidence); Ryan revision of decorated-wait v0.0.1 | 7,706 | AI Wiki repo skill source | Later revision adds live status to waiting-state console output. |
| 💾 [local-first-storage-architecture](skills/local-first-storage-architecture/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 4,030 | AI Wiki repo skill source | Designs browser and desktop-adjacent local-first storage boundaries. |
| 🎨 [sprite-pixel-art-sprite-sheets-gpt55](skills/sprite-pixel-art-sprite-sheets-gpt55/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 7,248 | AI Wiki repo skill source | Guides sprite sheets and pixel-art asset generation. |
| 📦 [universal-prompt-pack-builder](skills/universal-prompt-pack-builder/SKILL.md) | ❔ ? (low confidence); Ryan revision of local source reference | 30,427 | AI Wiki repo skill source | Packages reusable prompt packs and agent handoff materials. |
| 💻 [verbose-console-output](skills/verbose-console-output-v0.0.1/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 4,668 | AI Wiki repo skill source | Earlier optional verbose output pattern for CLI workflows. |
| 💻 [verbose-console-output](skills/verbose-console-output-v0.0.5/SKILL.md) | ● ~100% (low confidence); Ryan revision of verbose-console v0.0.1 | 9,645 | AI Wiki repo skill source | Later revision emphasizes phase status, counts, and elapsed time. |
| 🎨 [walking-cycle-generation](skills/walking-cycle-generation/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 10,590 | AI Wiki repo skill source | Focuses on frame-by-frame walking animations and sprite cycles. |
| 🎨 [windows-phone-metro-design](skills/windows-phone-metro-design/SKILL.md) | ❔ ? (low confidence); Ryan revision of local source reference | 5,946 | AI Wiki repo skill source | Specializes in Metro, Lumia, Pivot, and tile-based UI patterns. |
| 📦 [windows-tar-package-installer-workflow](skills/windows-tar-package-installer-workflow/SKILL.md) | ● ~100% (low confidence); Recorded original (Ryan/AI Wiki) | 4,187 | AI Wiki repo skill source | Packages Windows delivery as one TAR archive with an installer. |

</details>

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
validator, which checks that every skill document is registered and scans
Git-tracked and nonignored text files for common personal absolute paths.
It does not establish authorship, cross-harness compatibility, or runtime behavior.
Validate the relevant skill and harness separately before relying on it.

Svelte and Tauri icons are from [Simple Icons](assets/icons/README.md).

## Attribution and license

The collection includes Ryan-authored workflows, customized adaptations, and
skills retaining third-party authorship. See the skill files and
[provenance records](skills/provenance.json) for recorded credits. Some entries
still need provenance reconciliation; a repository location alone does not
establish authorship.

No repository-wide license has been established. Individual skills may state
their own terms; review those terms and upstream sources before reuse.
