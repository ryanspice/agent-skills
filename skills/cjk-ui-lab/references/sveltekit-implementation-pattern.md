# SvelteKit Implementation Pattern

Use this when creating or restructuring `<DEV_ROOT>/cjk-ui-lab`.

## Default Stack

- SvelteKit 2
- Svelte 5 runes
- TypeScript
- Bun package manager unless the repo already has another lockfile
- CSS custom properties as the token substrate
- Static/prerender-first unless a route needs server behavior
- Minimal dependencies

Use official Svelte CLI commands for a new empty app:

```powershell
npx sv create --template minimal --types ts --no-add-ons --install bun <path>
```

Add integrations only after the app exists and the need is concrete. Storybook, Playwright, axe, visual regression, and Tailwind can be later phases; do not block the first lab slice on them.

## Route Plan

Start with route examples rather than a component package:

```txt
src/routes/+page.svelte
src/routes/ja/product/+page.svelte
src/routes/ja/article/+page.svelte
src/routes/ko/dashboard/+page.svelte
src/routes/ko/search/+page.svelte
src/routes/lab/tokens/+page.svelte
```

If the first implementation is faster as one home route with four sections, that is acceptable for the first slice. Extract routes once navigation and content volume justify it.

## Library Plan

```txt
src/lib/components/
  Badge.svelte
  Button.svelte
  Field.svelte
  ProductCard.svelte
  StateBlock.svelte
src/lib/data/
  ja.ts
  ko.ts
src/lib/tokens/
  themes.ts
src/lib/typography/
  samples.ts
src/lib/themes/
  theme.css
```

Keep data fixtures explicit. They should be plausible JP/KR content but not pretend to be production translations.

## CSS Token Shape

Use `app.css` or a global theme CSS imported from the root layout.

```css
:root {
  --font-latin: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  --font-ja: "Hiragino Sans", "Yu Gothic", "Noto Sans JP", system-ui, sans-serif;
  --font-ko: "Apple SD Gothic Neo", "Malgun Gothic", "Noto Sans KR", system-ui, sans-serif;
  --space-1: 0.25rem;
  --space-2: 0.5rem;
  --space-3: 0.75rem;
  --space-4: 1rem;
  --radius-2: 0.375rem;
  --radius-3: 0.5rem;
}

:lang(ja) {
  font-family: var(--font-ja);
  line-break: strict;
  word-break: normal;
}

:lang(ko) {
  font-family: var(--font-ko);
  word-break: keep-all;
  overflow-wrap: anywhere;
}
```

Do not scale font size with viewport width. Use stable layout constraints, `clamp()` for widths, and component-level wrapping rules.

## Required Screen States

Each major screen should include:

- Normal state
- Loading state
- Empty state
- Error state
- Disabled state where controls exist
- Long labels
- Short labels
- Mixed script/numerals/currency
- Mobile and desktop layouts
- Dark/high-contrast variant or a documented deferral

## Accessibility Checklist

- Page title is unique.
- The root document has a default `lang`; localized sections have specific `lang`.
- Buttons are real `button` elements.
- Links are real anchors with crawlable `href` values when navigating.
- Inputs have labels, help text, and error text.
- Error states use `aria-invalid` and connect messages with `aria-describedby`.
- Focus states are visible on all themes.
- Status changes use text, not color alone.
- Motion respects `prefers-reduced-motion`.
- Text does not clip or overlap at mobile widths.

## Verification

Run:

```powershell
bun run check
bun run build
```

Then run a browser smoke when feasible:

```powershell
bun run dev -- --host 127.0.0.1
```

Inspect at least desktop and mobile widths. Check that JP/KR text wraps naturally, product cards do not resize unpredictably, and controls remain keyboard reachable.
