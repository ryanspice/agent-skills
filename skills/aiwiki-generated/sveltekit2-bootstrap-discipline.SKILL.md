---
name: sveltekit2-bootstrap-discipline
description: Use this skill only when creating a brand-new SvelteKit project, adding official Svelte CLI add-ons with sv add, migrating a Svelte/SvelteKit project with sv migrate, or repairing the initial project setup. Do not use for normal feature work, UI work, refactors, route edits, component edits, bug fixes, or existing app architecture unless setup tooling is the actual task.
provenance_origin: "original"
provenance_source_path: "04_skills/generated/sveltekit2-bootstrap-discipline.SKILL.md"
provenance_note: "Original AI Wiki generated standalone skill file."

---

# SvelteKit Bootstrap Discipline Skill

## Purpose

Use Svelte CLI tooling correctly without letting scaffolding distract from real implementation work.

This skill is intentionally narrow.

## Core Rule

Do not run or recommend `sv create` inside an existing app unless the user explicitly wants a new project.

If any of these exist, assume the project already exists:

- `package.json`
- `svelte.config.js`
- `svelte.config.ts`
- `vite.config.js`
- `vite.config.ts`
- `src/routes`
- `src/lib`
- `.svelte-kit`

Existing repo means: inspect, fix, refactor, or add targeted code.

New empty folder means: scaffold.

## Tool Selection

Use:

```powershell
npx sv create my-app
```

only for a brand-new SvelteKit app.

Use:

```powershell
npx sv add
```

when adding official integrations or add-ons to an existing Svelte app.

Use:

```powershell
npx sv migrate svelte-5
npx sv migrate sveltekit-2
```

only when migration is explicitly requested or clearly required.

After migration, search for:

```txt
@migration
```

and treat those as manual cleanup tasks.

## Package Manager Discipline

Before giving commands, inspect the repo signals:

- `bun.lock` or `bunfig.toml` means prefer Bun
- `pnpm-lock.yaml` means prefer pnpm
- `yarn.lock` means prefer yarn
- `package-lock.json` means prefer npm
- no lockfile means default to Bun only if the user/project preference says Bun-first

Do not mix package managers casually.

## Existing Project Flow

For an existing SvelteKit app:

1. Read `package.json`.
2. Read `svelte.config.*`.
3. Read `vite.config.*` if present.
4. Identify adapter and package manager.
5. Inspect the affected route/component/module.
6. Make the smallest useful change.
7. Run or recommend the project’s existing scripts.

Preferred verification order:

```powershell
bun run check
bun run build
```

Fallback:

```powershell
npm run check
npm run build
```

Use the actual scripts from `package.json` when known.

## New Project Flow

For a brand-new app:

1. Scaffold.
2. Install dependencies.
3. Run check/build once.
4. Add only requested integrations.
5. Create a minimal route/component structure.
6. Stop scaffolding and move to implementation.

Do not endlessly discuss templates, adapters, styling libraries, auth, database tools, testing stacks, or deployment unless the user asked.

## Anti-Rabbit-Hole Rules

Do not:

- recreate an app to fix a component bug
- suggest `sv create` for a route issue
- add Tailwind unless requested or already used
- add auth/database/testing adapters “just in case”
- migrate the whole project to fix one file
- rewrite config files without reading them
- run migrations without warning about manual cleanup
- claim migration/build success unless actually verified

## Output Format

For setup tasks, respond with:

1. what command to run
2. where to run it
3. what it changes
4. how to verify
5. what not to touch yet

For existing repo tasks, say:

```txt
This is not a scaffold task. Do not use sv create.
```

Then proceed with the targeted implementation or repair.
