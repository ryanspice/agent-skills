---
name: sveltekit2-svelte5-engineering
description: Use this skill when creating, refactoring, auditing, debugging, or reviewing SvelteKit 2 + Svelte 5 applications, routes, components, load functions, actions, adapters, stores/state, accessibility, performance, hydration, prerendering, and TypeScript architecture.
provenance_origin: "original"
provenance_source_path: "04_skills/generated/sveltekit2-svelte5-skill.SKILL.md"
provenance_note: "Original AI Wiki generated standalone skill file."

---

# SvelteKit 2 + Svelte 5 Engineering Skill

## Purpose

Build, repair, and review production-ready SvelteKit 2 applications using Svelte 5 conventions.

Prefer practical implementation over ceremony. Produce small, targeted changes first. Avoid framework nostalgia, dependency bloat, and giant rewrites unless the existing code is truly rotten.

## Default Stack

Use these defaults unless the repo clearly says otherwise:

- SvelteKit 2
- Svelte 5 runes
- TypeScript
- ESM
- Vite
- Bun-first commands when `bun.lock`, `bunfig.toml`, or repo scripts imply Bun
- Node LTS/npm/pnpm/yarn only when the repo already uses them
- Static/prerender-first architecture
- SSR only when needed for auth, dynamic data, request headers, cookies, or private server logic
- Minimal dependencies
- Scoped component CSS, native nested CSS, or existing Tailwind setup
- Accessible HTML before div soup
- Small components, clear names, low magic

## First Response Behavior

When starting a task:

1. Identify whether this is:
   - new feature
   - bug fix
   - migration
   - audit
   - performance pass
   - styling/UI pass
   - build/config repair
   - agent handoff
2. Inspect existing project conventions before proposing changes.
3. Prefer code-first output for implementation tasks.
4. Prefer Windows PowerShell commands when giving terminal steps.
5. Do not invent files, aliases, scripts, adapters, or paths. Verify from project context when possible.
6. Do not ask blocking questions for low-risk work. Make a sensible assumption and state it briefly.
7. Ask clarification only when the wrong assumption would cause meaningful rework or damage.

## Svelte 5 Rules

Use rune-based reactivity for new Svelte 5 code.

Prefer:

```svelte
<script lang="ts">
	let count = $state(0);
	let doubled = $derived(count * 2);

	function increment() {
		count += 1;
	}
</script>

<button type="button" onclick={increment}>
	Count: {count}, doubled: {doubled}
</button>
```

Avoid in new code unless maintaining legacy files:

```svelte
<script lang="ts">
	export let value;
	$: doubled = value * 2;
</script>
```

Guidelines:

- Use `$state` for local mutable state.
- Use `$derived` for computed values.
- Use `$effect` only for side effects, not normal derivation.
- Keep effects small and cleanup-aware.
- Do not use stores for every state problem.
- Use stores or shared modules only when state must cross component boundaries.
- Avoid deep reactive cleverness. If state shape gets weird, simplify it.
- Prefer explicit event handlers and clear data flow.
- Do not mix Svelte 4 and Svelte 5 idioms in the same new component unless migration constraints require it.

## Component Rules

Good Svelte components should:

- Have one main reason to exist.
- Keep markup readable.
- Use semantic HTML.
- Keep props typed.
- Keep local state local.
- Emit or call explicit callbacks for important actions.
- Avoid hidden global coupling.
- Avoid large monolithic components.

Component structure preference:

```svelte
<script lang="ts">
	type Props = {
		title: string;
		active?: boolean;
		onSelect?: () => void;
	};

	let { title, active = false, onSelect }: Props = $props();
</script>

<button
	type="button"
	class:active
	aria-pressed={active}
	onclick={() => onSelect?.()}
>
	{title}
</button>

<style>
	button {
		display: inline-flex;
		align-items: center;
		gap: 0.5rem;
	}

	.active {
		font-weight: 700;
	}
</style>
```

## SvelteKit Routing Rules

Respect SvelteKit filesystem routing.

Common files:

- `+page.svelte` for route UI
- `+page.ts` for universal load
- `+page.server.ts` for server-only load
- `+layout.svelte` for shared UI
- `+layout.ts` / `+layout.server.ts` for layout data
- `+server.ts` for endpoints
- `+error.svelte` for route error UI

Use server-only files when code touches:

- secrets
- private APIs
- database credentials
- secure cookies
- filesystem/server resources
- request-specific auth

Use universal load when data is public, serializable, and safe for client hydration.

Never leak secrets through `load`, `page.data`, public env vars, or serialized props.

## Page Options

Default to static-friendly behavior.

Use:

```ts
export const prerender = true;
```

for static pages that can be generated at build time.

Use:

```ts
export const ssr = false;
```

only for browser-only routes where SSR is impossible or pointless.

Use:

```ts
export const csr = false;
```

only for intentionally non-interactive/server-rendered pages.

Rules:

- Do not disable SSR just to dodge a browser API bug. Fix the browser-only code boundary.
- Guard browser APIs with `browser` from `$app/environment` or move usage into client-only lifecycle/effects.
- Be careful with prerendering pages that depend on per-user/session data.
- Static/prerender-first does not mean “everything must be prerendered.” It means choose static by default, then justify dynamic behavior.

## Data Loading

Prefer clean, typed load functions.

Example:

```ts
import type { PageLoad } from './$types';

export const load: PageLoad = async ({ fetch }) => {
	const response = await fetch('/api/items');

	if (!response.ok) {
		return {
			items: []
		};
	}

	return {
		items: await response.json()
	};
};
```

Server load example:

```ts
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
	return {
		user: locals.user
	};
};
```

Rules:

- Return serializable data.
- Keep load functions small.
- Do not do client-only work in load.
- Avoid duplicated fetching across nested layouts and pages.
- Use `depends`, invalidation, and parent data intentionally.
- Do not hide slow waterfall fetches inside “clean” abstractions.

## Forms and Actions

Prefer SvelteKit form actions for normal forms.

Use actions for:

- contact forms
- login/logout
- CRUD mutations
- progressive enhancement
- server validation

Keep validation server-side. Add client validation only as a usability improvement, not as the source of truth.

Avoid replacing simple forms with giant client state machines. That is usually how apps become haunted.

## Accessibility Rules

Before visual polish, check:

- Real buttons for actions
- Real links for navigation
- Labels on form controls
- Focus states
- Keyboard access
- Escape/close behavior for dialogs/menus
- `aria-expanded`, `aria-controls`, `aria-current`, `aria-invalid` where appropriate
- No click-only divs
- No focus traps unless actually needed
- Reduced motion support for heavy animation

If making a custom component, preserve native behavior where possible.

## Styling Rules

Prefer:

- scoped component styles
- existing design tokens
- CSS variables for themeable values
- container/layout primitives
- simple class names
- Tailwind only if already used or explicitly requested

Avoid:

- massive global CSS
- one-off magic pixel soup
- fragile `:global()` hacks
- heavy UI libraries for small needs
- CSS-in-JS in Svelte unless the repo already depends on it

## Performance Rules

For performance work:

1. Measure or identify the obvious hot path.
2. Fix layout thrash, excessive effects, redundant stores, and oversized components first.
3. Avoid unnecessary client JavaScript.
4. Prefer server/static rendering where useful.
5. Lazy-load heavy browser-only features.
6. Avoid large dependency additions.
7. Keep animations transform/opacity-based where possible.
8. Use derived state instead of recalculating repeatedly in markup.
9. Do not prematurely memoize everything. That is React trauma leaking into Svelte.

## TypeScript Rules

Prefer useful types, not decorative types.

Use:

- generated `$types`
- typed props
- typed load functions
- typed actions
- typed API responses when stable

Avoid:

- `any` unless temporarily necessary
- huge generic abstractions
- type gymnastics for simple UI
- pretending unknown external data is safe

Temporary `// @ts-ignore` or `// @ts-expect-error` is allowed only with a TODO and a reason.

## Migration Rules

When migrating Svelte 4/SvelteKit older code:

1. Do not rewrite the whole app by default.
2. Migrate one route/component cluster at a time.
3. Preserve behavior first.
4. Convert reactivity to runes carefully.
5. Replace old `$app/stores` patterns where applicable.
6. Keep compatibility boundaries obvious.
7. Run typecheck/build after targeted changes.
8. Note remaining legacy areas.

## Debugging Flow

For bugs/build failures:

1. Read the actual error.
2. Identify the file and line.
3. Check whether it is:
   - syntax
   - Svelte compile error
   - TypeScript error
   - Vite/module resolution
   - SSR/browser boundary
   - adapter/build output
   - dependency mismatch
4. Give the smallest safe fix.
5. Include a verification command.

Preferred verification commands:

```powershell
bun install
bun run check
bun run build
```

Fallback:

```powershell
npm install
npm run check
npm run build
```

Use the repo’s actual scripts when known.

## Output Format

For small fixes:

1. Give the file path.
2. Give the replacement code or targeted edit.
3. Give the verification command.
4. Give one short note about risk.

For larger work:

1. State the implementation plan.
2. List files to touch.
3. Provide code in chunks.
4. Include verification steps.
5. Include a short PR checklist.

For audits:

Group findings by severity:

- P0: broken build, security leak, data loss, unusable route
- P1: major bug, accessibility blocker, bad SSR/hydration bug
- P2: performance, maintainability, UX bug
- P3: polish, cleanup, naming, minor refactor

Each finding should include:

- symptom
- likely cause
- affected file
- recommended fix
- verification step

## Do Not Do

Do not:

- Add dependencies without justification.
- Disable SSR globally because one component used `window`.
- Put secrets in public env vars.
- Turn every interaction into a store.
- Replace native forms with overbuilt client state.
- Use Svelte 4 examples for new Svelte 5 code.
- Generate a full app rewrite for a small bug.
- Ignore accessibility.
- Claim the build passes unless it was actually run or the evidence is available.
- Hide uncertainty.
- Ship “looks right” code that is obviously not wired to data.

## Good Final Checklist

Before finishing, verify or state clearly:

- Typecheck/build status
- SSR/client boundary safety
- Accessibility concerns
- Performance risks
- Files changed
- Follow-up work, if any

End with the next concrete move, not vague encouragement.
