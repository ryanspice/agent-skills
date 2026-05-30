# PixelBoats Stormy Seas UI Reference Audit

Reference images:

```text
references/images/stormy_seas_and_pirate_adventure_hud.png
references/images/stormy_seas_and_sailing_adventure_ui.png
references/images/pirate_adventure_menu_over_stormy_seas.png
```

All three references are 1672 × 941.

## Shared Art Direction

- Dark storm-ocean background with visible shallow/deep water shifts.
- Semi-transparent blue-black glass panels.
- Warm amber selection/accent color.
- Cyan weather/wind/action accent.
- Red danger/pirate status.
- Thin borders, inset lines, soft panel shadows.
- Icon-heavy game UI with small labels and keyboard hints.
- Desktop HUD density, not mobile-first.

## Image 1 — Exploration HUD

Approximate layout:

| Surface | Bounds px | Component | Notes |
|---|---:|---|---|
| Player identity + stats | x 20, y 22, w 190, h 245 | `PlayerStatusStack.svelte` | Name, role, health, cargo, gold, ammo/reload |
| Weather route pill | x 520, y 27, w 760, h 58 | `WeatherRoutePill.svelte` | Storm, wind, region, danger count |
| Mini map | x 1335, y 15, w 320, h 325 | `MiniMap.svelte` | Grid labels, markers, zoom controls |
| Compass/wind | x 20, y 330, w 125, h 240 | `WindCompass.svelte` | Compass rose, NE, speed, breeze |
| Quick menu | x 1458, y 560, w 190, h 265 | `QuickMenu.svelte` | Map/perks/inventory/quests/crew |
| Ammo cluster | x 335, y 835, w 150, h 55 | `AmmoIndicator.svelte` | Cannonball dots + count |
| Command bar | x 500, y 805, w 755, h 110 | `CommandBar.svelte` | 1–0 slots, selected cannon |
| Minimal HUD toggle | x 35, y 880, w 165, h 45 | `MinimalHudToggle.svelte` | H hotkey |
| Version/network | x 1485, y 905, w 165, h 28 | `VersionNetworkBadge.svelte` | Version + online status |

## Image 2 — Inventory/Cargo Panel

Approximate layout:

| Surface | Bounds px | Component | Notes |
|---|---:|---|---|
| Inventory panel | x 875, y 220, w 470, h 585 | `InventoryPanel.svelte` | Tabs, cargo hold, equipment, stash |
| Item detail card | x 1360, y 285, w 300, h 520 | `ItemDetailCard.svelte` | Cannonball detail, stats, actions |
| Cargo grid | x 895, y 310, w 430, h 210 | `CargoGrid.svelte` | Stack counts, weight |
| Ship equipment | x 895, y 555, w 430, h 140 | `ShipEquipmentGrid.svelte` | Hull/sails/lamp/cannon/charm |
| Stash strip | x 895, y 720, w 430, h 80 | `StashStrip.svelte` | Port stash items |
| Bottom command bar | x 500, y 805, w 755, h 110 | `CommandBar.svelte` | Remains visible under panel |

## Image 3 — Progression / Perks / Quests / Crew

Approximate layout:

| Surface | Bounds px | Component | Notes |
|---|---:|---|---|
| Main progression panel | x 292, y 190, w 1030, h 585 | `ProgressionPanel.svelte` | Tabs and multi-column content |
| Perk tree | x 310, y 270, w 530, h 490 | `PerkTree.svelte` | Connected cards, selected reinforced hull |
| Quest list | x 855, y 305, w 255, h 365 | `QuestList.svelte` | Active quest cards and rewards |
| Crew/events panel | x 1125, y 270, w 185, h 480 | `CrewEventsPanel.svelte` | Crew morale, event card |
| Top tabs | x 310, y 195, w 1000, h 65 | `PanelTabs.svelte` | Perks, quests, crew/events, captain log |

## Component Priority

P0 implementation order:

1. `GameHudShell`
2. `WeatherRoutePill`
3. `PlayerStatusStack`
4. `MiniMap`
5. `CommandBar`
6. `QuickMenu`
7. `InventoryPanel`
8. `ProgressionPanel`

## Notes

The exact bounds above are reference-quality, not crop-perfect. Re-measure from source images if using a computer-vision crop workflow.
