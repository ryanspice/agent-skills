---
title: AI Wiki Svelte Lab Workflow
type: generated-skill
status: active
version: 0.7.1
updated: 2026-05-25
provenance_origin: "original"
provenance_source_path: "04_skills/generated/aiwiki-svelte-lab-workflow/SKILL.md"
provenance_note: "Original AI Wiki generated skill."

---

# AI Wiki Svelte Lab Workflow

## Purpose

Guide Svelte Lab usage as the canonical local demo/tool staging lane inside the AI Wiki.

## Rules

- Keep Svelte Lab under `00_Kit/apps/svelte-lab`.
- Use `00_Kit/packages/svelte-fragments` only for reviewed reusable components.
- Use `00_INBOX/proposed` for rough fragments and WIP material.
- Do not ingest PixelBoats or other WIP demo TARs automatically.
- Use lazy demo loading; do not eagerly load every generated demo.
- Prefer pnpm workspace for the lab and shared packages.

## Verification

Start with `Start-SvelteLab.ps1 -Port 5174`, open `/lab`, and confirm demos lazy-load.
