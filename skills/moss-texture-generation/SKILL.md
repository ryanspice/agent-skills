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
| `<COMFYUI_ROOT>` | The ComfyUI install root (contains `main.py`, `.venv`, and the generation script) |
| `<MOSS_OUTPUT>` | A new output folder for this job |
| `<WORKSTATION_ENV>` | The workstation's environment id, from local config |

Observed shape of a real run (fill the placeholder, never the machine path):

| Fact | Value |
|---|---|
| Backend | ComfyUI, loopback `127.0.0.1:8188` only |
| Generation | serial, one image at a time, roughly 165 s per 1024×1024 image |
| Settings used successfully | MOSS-Image SFT int8, Euler, 50 steps, CFG 3.0, fixed seeds |
| Teardown | not documented by `<MOSS_SKILL>`; PID teardown below is the only supported path |

## Gates (all must pass before starting)

1. **Port.** The MOSS port (loopback 8188 unless `<MOSS_SKILL>` says otherwise) is free, or it belongs to a ComfyUI instance you can prove is idle. Never reuse an unknown listener.
2. **GPU.** No other generation or render job is using the GPU. Check GPU utilization **and** GPU memory against an idle baseline. On Windows, `nvidia-smi` often does not report which process holds the memory, so you may be unable to attribute it: if GPU memory is above idle and you cannot identify the owning process, the gate **fails**. Do not treat "probably idle" as a pass, and do not start the backend to find out.
3. **System memory.** Check free RAM as well as the GPU. A model load failed on a run with only about 1.7 GB of 32 GB free; the retry only succeeded after memory was freed. Require a comfortable headroom (several GB) before starting.
4. **Holds.** Respect any hold marker a project records in its state, for example a campaign held for a Blender or media gate. Do not clear it, and do not start MOSS while it holds a shared gate.
5. **Ownership.** Do not touch processes you did not start, other threads, or any project repo that is outside this job.

If any gate fails, stop, report the blocker with the evidence, and change nothing.

## Startup

- Start the backend exactly as `<MOSS_SKILL>` documents it. The documented form is a hidden background process, so both the launcher and the server are separate processes:

  ```
  Start-Process -FilePath '<COMFYUI_ROOT>\.venv\Scripts\python.exe' `
                -ArgumentList 'main.py','--listen','127.0.0.1','--port','8188' `
                -WorkingDirectory '<COMFYUI_ROOT>' -WindowStyle Hidden
  ```

- Bind to loopback only.
- Record **both** PIDs: the launcher you started and the server process that ends up listening on the port.
- Do not edit `extra_model_paths.yaml`, model paths, or any config.
- Do not install packages or download models in the same run.

## Generation

- Drive the generation entry point one image at a time; the workflow is serial, and parallel requests are not documented:

  ```
  moss_gen.py "<prompt>" --out <MOSS_OUTPUT>\<surface>_v1.png
  ```

- Record resolution, seed, sampler, steps, and model for every output.
- If the first render fails while loading the model, check free memory before retrying; one retry is reasonable, repeated failures are a stop condition.
- For surfaces, describe the plain material only. Leave out people, text, logos, and props unless the job asks for them.
- Ask for tileable output. Generated images are often not seamless; say so in the report rather than implying they tile.
- Make at least two variations per surface, and never overwrite an earlier output.
- Write `manifest.json` in `<MOSS_OUTPUT>` with the prompt, seed, model, sampler, steps, resolution, output path, and SHA-256 for each image, and re-check each hash against the file on disk.

## Using the output in a PBR pipeline

- Use the generated image as albedo only. Take roughness, metal, and AO from the asset pipeline or from constants. A generated image is not a reliable source for those channels.
- Check tiling at 2x2 before use. Look for visible seams and baked-in lighting.
- Keep generated images in `<MOSS_OUTPUT>`. Do not overwrite source assets. Copy into an asset folder only after review, and keep the original.

## Teardown (required)

Stop only the ComfyUI processes this run started, using the PIDs you recorded: the server listening on the port **and** the launcher that started it. Confirm the port is closed and the GPU is released. Leave every other process alone. Report both PIDs you stopped.

If a run ends before teardown (an interrupted session, a rate limit, a crash), the next run inherits the cleanup: before starting anything, check for a listener on the port and for processes whose command line matches the documented startup command, stop those only, and confirm the port is closed. Never kill a ComfyUI you cannot attribute to that command.

## Report format

- Live state at check time: port, GPU, free RAM, conflicting jobs, and what you did not touch
- Output files with sizes and SHA-256, and the manifest path
- Both PIDs you stopped, and confirmation that the port is closed
- Whether the images tile seamlessly (only if you checked; otherwise say you did not)
- If generation did not run: the exact blocker

## Notes

- Older MOSS config referenced a text encoder by a name that did not match the file on disk. Verify model loading with a small test before a long run.
- Do not include personal names, emails, or machine-specific absolute paths in anything published from this skill.
