---
name: local-first-storage-architecture
description: Use this skill when designing local-first browser tools, desktop-adjacent web apps, AI Wiki tooling, generated project packages, or search/index workflows that touch local storage, IndexedDB, filesystem APIs, imports/exports, caches, or project manifests.
version: 0.1.0
status: generated
type: generated-agent-skill
risk: medium
tags: ["local-first", "storage", "indexeddb", "cache", "import-export", "ai-wiki"]
created_at: 2026-05-22
provenance_origin: "original"
provenance_source_path: "04_skills/generated/local-first-storage-architecture/SKILL.md"
provenance_note: "Original AI Wiki generated skill."

---

# Local-first storage architecture

## Purpose

Use this skill when designing local-first browser tools, desktop-adjacent web apps, AI Wiki tooling, generated project packages, or search/index workflows that touch local storage, IndexedDB, filesystem APIs, imports/exports, caches, or project manifests.

## Status

Generated operational skill.

Do not promote to universal until personal paths, Ryan-specific preferences, and AI Wiki-specific assumptions are removed or parameterized.

## Doctrine

The goal is not personal consensus. The goal is a storage model that survives reality.

Use file-owned durable state for important work. Use browser storage deliberately:

- `localStorage` for tiny harmless preferences;
- IndexedDB for meaningful browser-local workspaces;
- OPFS/File System APIs when file-like browser storage is justified;
- exported project files/TAR/JSON for ownership;
- search indexes for retrieval acceleration;
- AI Wiki notes as canonical only after review/promotion.

## Storage rules

- Use `localStorage` only for tiny preferences such as theme, panel size, toggles, recent view, and harmless UI state.
- Use IndexedDB behind an adapter for meaningful browser-local workspace state such as documents, imported assets, project drafts, parsed artifacts, and resumable tool state.
- Use filesystem/exported project folders or project JSON/TAR files for durable ownership.
- Treat search indexes and runtime caches as rebuildable or refreshable intelligence layers, not canonical truth by themselves.
- Treat AI Wiki Markdown as curated knowledge after review.
- Treat ChatGPT export data as raw corpus until summarized and promoted.

## Adapter shape

Prefer a loose reusable pattern over a heavy library:

```txt
src/lib/storage/
  storage.ts
  local.ts
  idb.ts
  fs.ts
  migrations.ts
  manifest.ts
  reset.ts
```

## Project manifest pattern

```txt
/project.json
/assets/originals/*
/assets/generated/*
/manifests/*
/docs/context.md
```

## UX rules

- Fresh load should not silently import old assets.
- Detect saved workspace and offer restore.
- Show autosave status when autosave exists.
- Provide import, export, reset, and clear actions.
- Never claim a backend exists before it is implemented.
- Never hide important project state only inside browser storage.

## Evidence weighting

Do not infer the user's preferences from every search hit.

Use this weighting:

1. Explicit user direction, first-party code, project `.thoughts`, and final project docs are strong evidence.
2. Promoted project/universal AI Wiki skills are useful evidence.
3. Generated draft skills and Inbox/proposed notes are working material only.
4. Candidate/imported/third-party skills are reference material only.
5. Runtime/cache/index/download hits are not preference evidence.

A search hit proves that text exists in the corpus. It does not prove the user created it, endorsed it, or wants it treated as consensus.

## AI Wiki/search rule

Use Inbox/proposed for capture, project final notes for synthesis, generated skills for drafts, and promoted project/universal skills only after review.

Collapse useful checkpoints into final notes, then delete or archive staging based on whether unique value remains.
