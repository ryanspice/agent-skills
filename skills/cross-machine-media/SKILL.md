---
name: cross-machine-media
description: Coordinate Blender renders on Spice-Book, local image or video generation on Spice-PC, and user-authorized ChatGPT web image generation, including workload checks and verified handoffs. Use for cross-machine creative production, not ordinary single-machine edits.
metadata:
  provenance_origin: "original"
  provenance_source_path: "04_skills/agent-skills/skills/cross-machine-media/SKILL.md"
  provenance_credit: "Ryan Spice-Finnie"
  provenance_ingested_as: "ryanspice/agent-skills owned skill"
  provenance_note: "Original owner-directed cross-machine media workflow curated from the AI Wiki skill."
---

# Cross-machine media work

Use Ryan's preferred split as a starting point: Spice-Book-2023 for Blender authoring and renders; <LOCAL_HOST> for MOSS and other local image or video generation. ChatGPT web image generation is another option when the task authorizes it. This is a preference, not proof that either machine is available, software is installed, a format is compatible, or a specific GPU can run the requested task. The user's current instructions override the default, including local-only instructions. Do not deploy, publish, contact third parties, install software, or change provider settings unless the task authorizes that action.

## Locate and coordinate

1. Identify the current host, read its applicable machine-specific instructions and project rules, and verify exact paths before use. On Spice-PC, Ryan reported that T: was physically removed after crashes: do not access it or run scans that touch it unless Ryan explicitly changes that constraint.
2. Discover current T3 Connect environments with available tools and target the named machine by its returned environment ID. Reachability establishes connectivity only. Use supported cross-environment file or execution tools when available; T3 conversation inspection alone does not provide file access or permission to start, message, or interrupt another thread. Follow current harness rules for delegation and new threads. If a needed cross-machine action cannot be performed through an authorized capability, report the precise gap and continue independent work.
3. On the target host, check its current instructions, the specific software, version, device, project and file paths relevant to the task. For PC generation, discover existing installed workflows and their model names without exposing credentials; do not assume a video generator exists. On the Book, verify Blender and render device; do not infer CUDA capability or render speed from its name. A path on one machine or a synced folder is not proof it exists or is hydrated on the other.

## Workload safety

Before an expensive render or generation, assess the target machine's actual workload: query the existing application's live queue when available; check GPU utilization and memory, relevant Blender, image/video generation and local model processes; and inspect relevant process relationships and sampled CPU or resource use. Names such as node, cmd, or codex alone are not evidence of a heavy job. Distinguish an idle server from an active job, avoid printing command lines or secrets, and do not stop or change unrelated work.

Use an existing scheduler or queue and preserve its order. Do not start a duplicate server or compete with an incompatible active job. If queue, ownership, or resource state is unavailable or uncertain, leave the expensive work pending and report the blocker. A status snapshot is advisory, not an exclusive lock: only a scheduler or lock actually used by all competing launchers prevents races. Recheck immediately before dispatch, but do not claim that doing so guarantees exclusivity. Run one task at a time unless known workloads are compatible and the user has authorized that scope.

## ChatGPT web images

When ChatGPT web image creation is within the user's requested scope, use ChatGPT **Chat** in the T3 browser, not ChatGPT Work. Default to the latest model available in the Chat interface and its Extra High reasoning setting. Inspect the current visible controls and verify the selected model and effort before submission; do not assume that a label or setting exists, or that a Chat setting identifies the image-generation backend. If the requested setting or T3 browser access cannot be verified, report the exact limitation and do not silently substitute another model, effort, surface, service, or paid route. An explicit per-task choice overrides this default.

Follow the active T3 browser instructions and, when applicable and compatible with that browser, the installed `codex-chatgpt-control:chatgpt-delegate` skill for visible Chat operation. Do not bypass login, inspect credentials or browser storage, or submit sensitive reference files without authorization. Submit only the authorized prompt and references to ChatGPT; no third-party sharing or publishing is implied. Wait for the existing generation rather than resubmitting blindly. Save the resulting image to the authorized destination, inspect it against the reference and record the visible configuration, prompt, output path, and any failures. A web result must not replace an explicitly local-only request.

## Handoff and verification

Use the user's chosen shared destination if available; otherwise discover an appropriate shared folder without changing sync configuration. Keep source originals, existing project work and credentials intact. Use unique output names, stage transfers, and verify both endpoints' exact paths, file size and SHA-256 after hydration before using artifacts; local presence does not prove cloud sync or remote availability. Avoid transferring raw sessions, credentials, live runtime state, or whole scratch trees.

Record source and output paths, hashes, machine, software/model and version, relevant render parameters, queue and run results, and failures. For Blender distinguish source/build, actual render, visual inspection, target runtime and human acceptance. For image/video generation distinguish a completed file from visual acceptance; describe differences from references and any resizing or compositing. Verify artifacts on the receiving machine before downstream use, without modifying the website or publishing unless explicitly requested.
