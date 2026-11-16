---
name: moss-texture-generation
description: Generate seamless surface texture candidates with the local MOSS image workflow (ComfyUI backend) on a Windows GPU workstation, then stop it. Use when a 3D asset or game needs plaster, stone, roof tile, paving, cloth, wood or metal albedo that is missing or still procedural, or when the user asks to use MOSS, generate textures, or spin up MOSS. Covers pre-checks, startup, generation, output conventions, PBR use, verification and teardown.
provenance_origin: "original"
provenance_source_path: "04_skills/agent-skills/skills/moss-texture-generation/SKILL.md"
provenance_credit: "Ryan Spice-Finnie"
provenance_ingested_as: "ryanspice/agent-skills owned skill"
provenance_note: "Written from workstation thread records and a live read-only check. Machine paths and environment ids are placeholders; resolve them from local configuration."
---

# MOSS texture generation

MOSS is a local image generator that runs on a GPU workstation through a ComfyUI backend. Treat the workstation as a shared resource. Other jobs may be running on it.

## Source of truth

The MOSS skill installed on the workstation is authoritative for startup, runner scripts, and model paths. This file is the cross-machine procedure. If the two disagree, follow the workstation's MOSS skill and then update this file.

Placeholders (resolve locally, never hard-code them in this file):

| Placeholder | Meaning |
|---|---|
| `<MOSS_SKILL>` | The MOSS skill file on the workstation |
| `<COMFYUI_ROOT>` | The ComfyUI install root |
| `<MOSS_OUTPUT>` | A new output folder for this job |
| `<WORKSTATION_ENV>` | The workstation's environment id, from local config |

## Gates (all must pass before starting)

1. **Port.** The MOSS port (loopback 8188 unless `<MOSS_SKILL>` says otherwise) is free, or it belongs to a ComfyUI instance you can prove is idle. Never reuse an unknown listener.
2. **GPU.** No other generation or render job is using the GPU. Check the GPU usage and the process list.
3. **Holds.** Respect any hold marker a project records in its state, for example a campaign held for a Blender or media gate. Do not clear it, and do not start MOSS while it holds a shared gate.
4. **Ownership.** Do not touch processes you did not start, other threads, or any project repo that is outside this job.

If any gate fails, stop, report the blocker with the evidence, and change nothing.

## Startup

- Use only the startup procedure documented in `<MOSS_SKILL>`.
- Bind to loopback only.
- Do not edit `extra_model_paths.yaml`, model paths, or any config.
- Do not install packages or download models in the same run.
- Record the PID of the process you start.

## Generation

- Record resolution, seed, sampler, steps, and model for every output.
- For surfaces, describe the plain material only. Leave out people, text, logos, and props unless the job asks for them.
- Ask for tileable output. Generated images are often not seamless.
- Make at least two variations per surface.
- Write `manifest.json` in `<MOSS_OUTPUT>` with the prompt, seed, model, sampler, steps, resolution, output path, and SHA-256 for each image.

## Using the output in a PBR pipeline

- Use the generated image as albedo only. Take roughness, metal, and AO from the asset pipeline or from constants. A generated image is not a reliable source for those channels.
- Check tiling at 2x2 before use. Look for visible seams and baked-in lighting.
- Keep generated images in `<MOSS_OUTPUT>`. Do not overwrite source assets. Copy into an asset folder only after review, and keep the original.

## Teardown (required)

Stop only the ComfyUI process this run started, using the PID you recorded. Confirm the port is closed and the GPU is released. Leave every other process alone. Report the PID you stopped.

## Report format

- Live state at check time: port, GPU, conflicting jobs, and what you did not touch
- Output files with sizes and SHA-256, and the manifest path
- The PID you stopped, and confirmation that the port is closed
- If generation did not run: the exact blocker

## Notes

- Older MOSS config referenced a text encoder by a name that did not match the file on disk. Verify model loading with a small test before a long run.
- Do not include personal names, emails, or machine-specific absolute paths in anything published from this skill.
