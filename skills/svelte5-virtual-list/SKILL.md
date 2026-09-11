---
id: svelte5-virtual-list
name: Svelte 5 Virtual List
description: Use when building, auditing, or repairing virtualized lists, tables, grids, source inventories, logs, feeds, or other scroll-heavy Svelte 5/SvelteKit UI.
version: 0.1.0
scope: universal
status: draft
updated: 2026-05-18
preferred_stack:
  - SvelteKit 2
  - Svelte 5 runes
  - TypeScript
  - ESM
  - minimal dependencies
risk_tier: medium
---

# Svelte 5 Virtual List Skill

## Purpose

Build, audit, or repair virtualized lists, feeds, grids, menus, logs, tables, and scroll-heavy UI in **Svelte 5** without overengineering the page.

This skill exists because virtual scrolling is easy to make *almost* work and then secretly ruin accessibility, focus, scroll anchoring, dynamic row heights, keyboard navigation, mobile performance, or SSR hydration. Do not be cute. Make the list boringly correct first.

---

## Use this skill when

Use this skill when the task includes any of:

- Large lists, feeds, logs, inboxes, chats, timelines, search results, tables, grids, trees, menus, pickers, or media galleries.
- Scroll jank, slow rendering, huge DOM counts, expensive repeated cards, or mobile lag.
- Infinite loading, prepend loading, scroll restoration, sticky headers, grouped rows, or anchored “follow latest” behavior.
- Dynamic row heights from images, wrapped text, markdown, cards, embeds, notifications, or expandable rows.
- Svelte 5 / SvelteKit 2 components using runes and modern component syntax.

Do **not** virtualize by default when:

- The list is usually under ~200 lightweight rows.
- The page needs full native browser find-in-page across all hidden rows.
- SEO/indexing requires all content in the HTML.
- The list is print-first.
- A plain paginated list solves the real problem faster.

---

## Hard rules

1. **Pick the simplest viable strategy.**
   - Fixed height rows: custom virtualizer is usually fine.
   - Variable height rows: use measurement cache, ResizeObserver, and scroll anchoring.
   - Complex table/grid/sticky/infinite behavior: consider a dedicated virtualizer, but justify it.
2. **Do not render the full list and hide rows with CSS.**
   - Virtualization must reduce DOM nodes.
3. **Always keep spacer height correct.**
   - The scroll container needs one inner rail/spacer with total virtual height.
4. **Position visible items with transforms.**
   - Prefer `transform: translateY(...)` or `translate3d(...)` over per-frame layout-heavy top changes.
5. **Use stable keys.**
   - Key by stable item id when possible, not index, unless the data is truly static.
6. **Make scroll listeners passive and clean them up.**
7. **Handle empty, loading, error, and end-of-list states.**
8. **Respect accessibility.**
   - Preserve focus, announce loading politely, keep keyboard movement predictable, and do not trap users in invisible rows.
9. **Do not mutate props.**
   - Keep local `$state` for measurements and UI state.
10. **Do not use `$effect` as a lazy `$derived`.**
    - Use `$derived` for visible ranges, total size, and computed layout.
    - Use `$effect` for DOM subscriptions, ResizeObserver, requestAnimationFrame loops, and imperative cleanup.

---

## Svelte 5 defaults

Prefer:

```svelte
<script lang="ts">
  let {
    items,
    rowHeight = 44,
    overscan = 8
  }: {
    items: Array<{ id: string; label: string }>;
    rowHeight?: number;
    overscan?: number;
  } = $props();

  let scrollTop = $state(0);
  let viewportHeight = $state(0);
  let scroller: HTMLDivElement | undefined = $state();

  let totalHeight = $derived(items.length * rowHeight);

  let startIndex = $derived(
    Math.max(0, Math.floor(scrollTop / rowHeight) - overscan)
  );

  let endIndex = $derived(
    Math.min(
      items.length,
      Math.ceil((scrollTop + viewportHeight) / rowHeight) + overscan
    )
  );

  let visibleItems = $derived(
    items.slice(startIndex, endIndex).map((item, localIndex) => {
      const index = startIndex + localIndex;
      return {
        item,
        index,
        y: index * rowHeight
      };
    })
  );

  $effect(() => {
    const node = scroller;
    if (!node) return;

    let raf = 0;

    const read = () => {
      cancelAnimationFrame(raf);
      raf = requestAnimationFrame(() => {
        scrollTop = node.scrollTop;
        viewportHeight = node.clientHeight;
      });
    };

    read();
    node.addEventListener('scroll', read, { passive: true });

    const ro = new ResizeObserver(read);
    ro.observe(node);

    return () => {
      cancelAnimationFrame(raf);
      node.removeEventListener('scroll', read);
      ro.disconnect();
    };
  });
</script>

<div bind:this={scroller} class="virtual-scroller" role="list">
  <div class="virtual-rail" style:height={`${totalHeight}px`}>
    {#each visibleItems as row (row.item.id)}
      <div
        class="virtual-row"
        role="listitem"
        style:height={`${rowHeight}px`}
        style:transform={`translateY(${row.y}px)`}
      >
        {row.item.label}
      </div>
    {/each}
  </div>
</div>

<style>
  .virtual-scroller {
    overflow: auto;
    contain: strict;
    height: 100%;
    min-height: 0;
  }

  .virtual-rail {
    position: relative;
    width: 100%;
  }

  .virtual-row {
    position: absolute;
    inset-inline: 0;
    top: 0;
    box-sizing: border-box;
    will-change: transform;
  }
</style>
```

Notes:

- This is the baseline pattern for fixed-height lists.
- Use `style:height` and `style:transform` for clarity in Svelte.
- `contain: strict` is useful for isolated scroll regions, but audit layout/sticky behavior before keeping it.
- If the parent uses flex/grid, ensure the scroller has `min-height: 0`; missing this is a classic “why does my list not scroll?” footgun.

---

## Decision tree

### 1. Fixed-size rows

Use this when every row is the same height or can be forced to the same height.

Recommended:

- Compute `startIndex`, `endIndex`, `totalHeight`, and visible rows with `$derived`.
- Update `scrollTop` and `viewportHeight` from a passive scroll listener.
- Render a rail/spacer with `height = items.length * rowHeight`.
- Absolutely position each row at `index * rowHeight`.

Avoid:

- Measuring every row.
- Recalculating inside the template repeatedly.
- Recreating item arrays in an `$effect`.
- Using `top` for frequent movement if transform works.

### 2. Variable-size rows

Use this when row height changes due to content, images, wrapping, expansion, localization, or responsive width.

Recommended:

- Keep `estimatedRowHeight`.
- Keep a `Map<itemId, number>` measurement cache.
- Use prefix sums or indexed offsets to compute starts.
- Measure visible rows with `ResizeObserver`.
- Adjust scroll anchoring when rows above the viewport change size.
- Recompute visible range after measurements settle.
- Use a binary search over offsets for `scrollTop -> startIndex`.

Avoid:

- Assuming measured row heights never change.
- Measuring hidden rows by rendering all rows off-screen.
- Updating measurement state every frame without diffing old/new height.
- Breaking scroll position when prepending older chat/feed items.

### 3. Infinite loading

Recommended:

- Trigger `loadMore` when the last virtual index is within a threshold.
- Debounce/constrain concurrent requests.
- Track `isLoading`, `hasMore`, and `error`.
- Render a virtual footer/loading row when needed.
- Use cursor-based pagination when available.

Avoid:

- Triggering `loadMore` in the template.
- Fetching on every scroll tick.
- Loading more after unmount.
- Assuming array length equals server total.

### 4. Prepend loading / chat history

Recommended:

- Capture `beforeHeight` and `beforeScrollTop`.
- Insert older items.
- Wait for DOM update/measurement.
- Set `scrollTop = newHeight - beforeHeight + beforeScrollTop`.
- Anchor by stable message id when possible.

Avoid:

- `scrollTop = 0` after prepending.
- Keying messages by index.
- Auto-following latest while the user is reading older messages.

### 5. Sticky group headers

Recommended:

- Treat group headers as virtual rows with their own type and height.
- Compute the current sticky header from the first visible item/group.
- Render one sticky overlay outside the absolute row layer.
- Ensure `aria` labels still make sense.

Avoid:

- Native `position: sticky` inside heavily transformed rows without testing.
- Duplicating headers in a way screen readers announce nonsense.

### 6. Grids

Recommended:

- For uniform cards, virtualize rows of columns.
- Derive column count from container width.
- Compute item index as `rowIndex * columnCount + columnIndex`.
- Recompute row count when width changes.
- Keep card aspect ratio stable to avoid layout jumps.

Avoid:

- Virtualizing every cell independently unless the grid is truly huge.
- Using CSS masonry for virtualized dynamic-height content unless the tradeoffs are explicit.

---

## Library policy

Default to **custom fixed-size virtualization** when the UI is simple.

Consider `@tanstack/svelte-virtual` when the feature needs:

- Dynamic measurement.
- Complex grids.
- Window virtualization.
- Table virtualization.
- Smooth scroll helpers.
- Sticky/infinite examples close to the target behavior.

If adding a dependency:

1. Check package freshness, advisories, and lockfile state.
2. Pin or constrain versions according to the repo’s dependency policy.
3. Explain why custom virtualization is not enough.
4. Keep the wrapper component small so it can be replaced later.
5. Do not mix two virtualizer libraries in the same feature without a migration reason.

---

## Accessibility checklist

Virtualized UI hides DOM nodes. That is the point, but it creates obligations.

Must handle:

- Keyboard focus must not disappear when the focused row scrolls out of range.
- Roving `tabindex` or `aria-activedescendant` is preferred for selectable lists.
- Use `aria-rowcount`, `aria-posinset`, `aria-setsize`, or grid/table roles where appropriate.
- Loading more results should use `aria-live="polite"` or a nearby status message.
- Screen-reader labels must reflect actual item position when position matters.
- Keep interactive controls reachable by keyboard.
- Provide non-virtualized fallback or pagination for print/export when required.

Do not use fake roles casually. A simple feed may be better as semantic article/list markup than a fake grid.

---

## Performance checklist

- DOM count should stay roughly `visible rows + overscan`, not `items.length`.
- Scroll handler should only read `scrollTop`/`clientHeight` and schedule state updates.
- Avoid expensive derived work across the full item list.
- Avoid allocating thousands of row view models per tick.
- Use stable `item.id` keys.
- Use image dimensions/aspect ratio placeholders.
- Lazy-load images inside rows.
- Avoid transitions on every row during scroll.
- Avoid box-shadow/backdrop-filter per row in giant lists unless profiled.
- Test low-end mobile and high-DPI desktop.
- Audit memory leaks from ResizeObserver, IntersectionObserver, timers, and requestAnimationFrame.

---

## SvelteKit / SSR checklist

- DOM APIs belong in `$effect`, actions, or attachments.
- Guard browser-only imports if a library touches `window`.
- Keep initial server markup deterministic.
- Avoid reading layout during SSR.
- For SEO-critical lists, virtualize only after the primary content strategy is settled.
- For route restoration, persist scroll state by route/query key and restore after data is ready.

---

## Testing checklist

Minimum manual QA:

- 0 items.
- 1 item.
- Fewer items than viewport.
- Exactly one viewport of items.
- Thousands of items.
- Rapid wheel/touchpad scroll.
- Drag scrollbar thumb.
- Keyboard navigation.
- Resize container.
- Change font size / zoom.
- Dynamic row expansion/collapse.
- Data prepend.
- Data append.
- Item removal above viewport.
- Mobile touch scroll.
- Reduced motion.
- Screen reader smoke test if interactive.

Useful automated checks:

- Unit test range math.
- Unit test binary search for variable offsets.
- Component test for DOM count.
- Component test for first/last visible item after scroll.
- Playwright test for scroll restoration and keyboard selection.

---

## Common bugs and fixes

### Blank gap at bottom

Likely causes:

- `totalHeight` too small.
- `endIndex` exclusive/inclusive mismatch.
- Dynamic row measurements lower than actual height.
- Parent scroller height collapsed.

Fix:

- Verify rail height.
- Render a debug overlay showing `startIndex`, `endIndex`, `totalHeight`, `scrollTop`, `viewportHeight`.
- Check parent `min-height: 0`.

### Rows overlap

Likely causes:

- Wrong `rowHeight`.
- Dynamic row offset cache not updated.
- Reusing stale measurement after width/font/content change.

Fix:

- Invalidate heights when container width changes.
- Diff ResizeObserver measurements before setting state.
- Use item id keys.

### Scroll jumps while loading

Likely causes:

- Index keys.
- Prepend without anchoring.
- Late image height changes above viewport.
- Measured size changed and no compensation was applied.

Fix:

- Key by stable id.
- Reserve image dimensions.
- Anchor visible item or compensate scrollTop based on height delta above viewport.

### Focus disappears

Likely causes:

- Focused row was unmounted.
- Native tab order is fighting virtualization.

Fix:

- Use roving focus.
- Track active item id in state.
- Scroll active item into view before moving focus.
- Keep focus on container and use `aria-activedescendant` for very large selectable lists.

### Infinite loader fires forever

Likely causes:

- `loadMore` has no in-flight guard.
- `hasMore` ignored.
- Threshold checks run during every measurement update.
- Server returns same cursor repeatedly.

Fix:

- Add `isLoading` and cursor dedupe.
- Trigger from a controlled `$effect`.
- Stop on empty page or repeated cursor.

---

## Debug mode

When asked to audit or fix a virtual list, add a temporary debug panel or console logs showing:

```ts
{
  itemCount,
  domRowCount,
  startIndex,
  endIndex,
  overscan,
  scrollTop,
  viewportHeight,
  totalHeight,
  averageMeasuredHeight,
  focusedItemId,
  isLoading,
  hasMore
}
```

Remove or gate debug UI before shipping.

---

## Agent workflow

When using this skill, follow this order:

1. Identify list type:
   - fixed, variable, grid, table, infinite feed, chat/prepend, grouped/sticky, window virtualized.
2. Check whether virtualization is actually justified.
3. Inspect current DOM count and row rendering cost.
4. Choose custom vs library.
5. Implement or repair range math first.
6. Add measurement only if needed.
7. Add keyboard/focus behavior.
8. Add infinite/prepend behavior.
9. Add debug instrumentation.
10. Verify with the checklist.
11. Remove debug noise or hide it behind a dev flag.
12. Summarize:
    - what changed,
    - what was verified,
    - remaining risks,
    - exact commands used.

---

## Paste-ready implementation prompt

Use this prompt when handing a Svelte 5 virtual list task to an agent:

```text
Use the Svelte 5 Virtual List skill.

Repo assumptions:
- SvelteKit 2 / Svelte 5 runes / TypeScript / ESM.
- Prefer minimal dependencies.
- Do not add a virtualizer library unless custom fixed/variable virtualization is clearly insufficient.
- Keep changes targeted.

Task:
Build or repair the virtualized list for: [describe route/component].

Requirements:
1. Decide whether the list is fixed-height, variable-height, grid, table, infinite feed, chat/prepend, grouped/sticky, or window virtualized.
2. Use Svelte 5 runes:
   - $state for mutable UI/layout state.
   - $derived for visible range, total size, visible item view models.
   - $effect only for DOM listeners, ResizeObserver, requestAnimationFrame, load triggers, and cleanup.
3. Keep DOM count bounded to visible rows + overscan.
4. Use stable item ids for keys.
5. Use passive scroll listeners and cleanup.
6. Preserve keyboard focus and basic accessibility.
7. Handle empty/loading/error/end states.
8. Add dev-only debug state while building:
   itemCount, domRowCount, startIndex, endIndex, scrollTop, viewportHeight, totalHeight.
9. Verify:
   - 0 items
   - fewer than viewport
   - thousands of items
   - rapid scrolling
   - resize
   - keyboard navigation
   - append/prepend if applicable
   - dynamic row height if applicable
10. Provide a short summary and remaining risks.

Avoid:
- Full-list render hidden by CSS.
- Index keys for mutable data.
- Fetching directly inside templates.
- Measuring every item off-screen.
- Breaking SSR with unguarded DOM APIs.
```

---

## Output format for agent responses

For implementation work, respond with:

```md
## Svelte 5 virtual list pass

### What changed
- ...

### Verification
- Command: `bun run check`
- Command: `bun run test`
- Manual QA: ...

### Risks / follow-up
- ...
```

For audits, respond with:

```md
## Virtual list audit

| Severity | Issue | Evidence | Fix |
|---|---|---|---|
| P0 | ... | ... | ... |

### Recommended next edit
...
```
