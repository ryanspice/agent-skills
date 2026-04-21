---
name: tauri-sveltekit
description: Use this skill when building, auditing, or refactoring Tauri apps using SvelteKit 2, Svelte 5 runes, TypeScript, Rust commands, app shell UI, tray/window behavior, or desktop integration.
---

# Tauri + SvelteKit Skill

## Purpose

Use this skill to produce reliable Tauri + SvelteKit 2 + Svelte 5 application work with clear boundaries between frontend UI, Tauri commands, Rust plugins, app shell behavior, filesystem access, permissions, and desktop integration.


## Skill composition

This is a project-specific orchestration skill.

Use alongside:
- `sveltekit-best-practices` for SvelteKit/Svelte 5 patterns.
- `typescript-best-practices` for TypeScript correctness.
- `vite-guard` for build, dependency, and security guardrails.
- `tailwind-best-practices` for styling.

When rules overlap:
1. Tauri/runtime/build constraints win for desktop behavior.
2. SvelteKit/Svelte rules win for component and route structure.
3. TypeScript rules win for typing and contracts.
4. Vite/security rules win for build safety.
5. Tailwind rules win for styling unless local native CSS is clearer.

## Operating mode

Act as a senior desktop-app engineer with strong Rust, SvelteKit, Svelte 5, Windows UX, accessibility, and performance instincts.

Before changing code:
1. Inspect:
   - Tauri: `src-tauri/`, `crates/`, plugins, commands, permissions, capabilities.
   - SvelteKit: `src/routes`, `src/lib`, `app.html`, layouts, shared state.
   - Config: `tauri.conf.json`, `Cargo.toml`, `svelte.config.*`, `vite.config.*`, `package.json`.
2. Summarize the architecture in 5-10 bullets.
3. Flag risks: SSR/static mismatch, command drift, blocking Rust, state races, permission gaps, webview APIs used during build, Windows-only behavior, and stale Svelte 4 patterns.
4. Make the smallest coherent patch. Do not redesign unrelated areas because the dopamine goblin asked nicely.

## Hard stack rules

- Tauri v2 first. Do not use v1 APIs unless the repo is actually v1.
- SvelteKit 2 + Svelte 5 runes + TypeScript + ESM.
- Prefer static/SPA frontend output for Tauri. Do not add a server runtime unless explicitly required.
- Use `@sveltejs/adapter-static` unless the repo already has a justified alternative.
- Assume Tauri APIs exist only in the webview at runtime, not during prerender/build.
- Keep dependencies minimal. Justify every new dependency in one sentence.
- No jQuery, Moment.js, giant UI kits, or CSS-in-JS bloat.
- Prefer native nested CSS or existing Tailwind patterns.

## Svelte 5 rules

Use runes correctly:
- Props: `let { value, label, onchange }: Props = $props();`
- Bindable props: `let { value = $bindable(0) }: Props = $props();`
- Local state: `let open = $state(false);`
- Derived values: `let filtered = $derived(items.filter(...));`
- Effects only for side effects: `$effect(() => { ... });`

Avoid old `$:` labels in new/refactored code. Avoid `createEventDispatcher` for new components; prefer callback props. Prefer typed props and small focused components. Avoid stores for local state. Use stores/rune modules only for shared app state.

Do not access `window`, `document`, `localStorage`, or Tauri APIs during SSR/build. Gate with `browser` from `$app/environment` or run inside client-only effects.

## SvelteKit rules

- Keep route data ownership narrow. Do not dump app data through root layouts.
- Use `+page.ts`, `+layout.ts`, and `+server.ts` only where they help.
- In Tauri, prefer client/runtime initialization when Tauri APIs are needed.
- Make components prop-driven instead of reaching into `$page.data`.
- Keep `csr`, `ssr`, and `prerender` explicit when behavior depends on them.
- Use semantic HTML first, then progressive enhancement.
- Do not break no-JS rendering unless the route is intentionally app-only.

## Tauri/Rust rules

- Keep Rust commands small, typed, and contract-driven.
- Args and return values must be `serde` serializable.
- Return `Result<T, AppError>` or the repo-standard error type.
- Use async for IO. Do not block the main thread with long work.
- Use managed state for shared backend state; wrap mutable state safely with `Mutex`, `RwLock`, channels, or existing repo patterns.
- Check capabilities/permissions when frontend invocations fail.
- Prefer events/channels for progress, streaming updates, device polling, and driver notifications.
- Keep platform-specific code isolated behind modules/features.
- For Windows behavior, use the most native API path already accepted by the repo.

## Frontend/backend contract

For every Tauri command touched:
1. Find the Rust command signature.
2. Find all frontend `invoke(...)` callers.
3. Verify argument names match exactly.
4. Verify return type expectations match exactly.
5. Add/update shared TS types when practical.
6. Preserve compatibility or migrate all callers.

Preferred wrapper:

```ts
import { invoke } from '@tauri-apps/api/core';

export async function getDisplayState(): Promise<DisplayState> {
  return invoke<DisplayState>('get_display_state');
}
