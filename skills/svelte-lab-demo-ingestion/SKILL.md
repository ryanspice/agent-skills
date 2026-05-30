---
title: Svelte Lab Demo Ingestion
type: generated-skill
status: active
version: 0.7.1
updated: 2026-05-25
provenance_origin: "original"
provenance_source_path: "04_skills/generated/svelte-lab-demo-ingestion/SKILL.md"
provenance_credit: "Ryan Spice-Finnie"
provenance_ingested_as: "ryanspice/agent-skills owned skill"
provenance_note: "Original AI Wiki generated skill credited to Ryan Spice-Finnie."

---

# Svelte Lab Demo Ingestion

## Purpose

Import cleaned Svelte or legacy HTML demos into Svelte Lab with receipts and predictable paths.

## Rules

- Native demos should provide `Demo.svelte`.
- Legacy HTML demos should provide `index.html` and are wrapped in an iframe demo.
- Optional `demo.manifest.json` should describe title, summary, tags, source type, and status.
- Use `Import-SvelteLabDemo.ps1` directly for debugging.
- Use `Execute -In <demo.tar.gz> -As Demo` only after the demo is cleaned or explicitly chosen for staging.
- Do not promote demos to reusable packages until reviewed.

## Verification

Import a known sample, restart Svelte Lab, and confirm the demo appears in `/lab`.
