Use skill: pixelboats-image-to-ui-sveltekit.

We are converting the attached/reference UI images into maintainable SvelteKit 2 + Svelte 5 components for PixelBoats.

Reference views:
- exploration HUD over stormy ocean
- inventory/cargo panel over stormy ocean
- perks/quests/crew panel over stormy ocean

Target:
- Build semantic Svelte components, not a screenshot background.
- Preserve existing gameplay state and route structure.
- Keep changes scoped and practical.

Hard rules:
- Do not create a giant one-file +page.svelte.
- Do not add duplicate top-level <style> blocks.
- Use Svelte 5 runes and Svelte 5 event attributes.
- Use Bun commands.
- No jQuery, no heavy UI kit, no broad refactor.
- Keep gameplay/simulation state separate from UI state.

First response before edits:
1. List target files inspected.
2. Give a short image audit with approximate component bounds.
3. Propose the smallest component map for this route.
4. State the first vertical slice.

Suggested components if no existing convention is better:
- src/lib/pixelboats/ui/state/game-ui-state.svelte.ts
- src/lib/pixelboats/ui/shell/GameHudShell.svelte
- src/lib/pixelboats/ui/hud/PlayerStatusStack.svelte
- src/lib/pixelboats/ui/hud/WeatherRoutePill.svelte
- src/lib/pixelboats/ui/hud/WindCompass.svelte
- src/lib/pixelboats/ui/hud/MiniMap.svelte
- src/lib/pixelboats/ui/hud/QuickMenu.svelte
- src/lib/pixelboats/ui/command/CommandBar.svelte
- src/lib/pixelboats/ui/panels/InventoryPanel.svelte
- src/lib/pixelboats/ui/panels/ProgressionPanel.svelte
- src/lib/pixelboats/ui/primitives/GlassPanel.svelte

Implementation order:
1. HUD shell + visual tokens.
2. Top weather pill + left stats + minimap + hotbar.
3. Quick menu + keyboard shortcuts.
4. Inventory panel.
5. Progression panel.
6. Responsive and accessibility pass.

Verify:
bun run check
bun run build

Final report:
- Summary
- Files changed
- Verification result
- Screenshots/visual notes if available
- Remaining gaps
- Next best pass
