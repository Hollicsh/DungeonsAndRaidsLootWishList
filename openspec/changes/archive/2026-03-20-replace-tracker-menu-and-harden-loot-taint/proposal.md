## Why

Recent taint errors show that `DungeonsAndRaidsLootWishList` is contaminating shared Blizzard UI paths strongly enough to break secret-value comparisons later inside `Blizzard_DamageMeter`. The highest-risk surfaces are the tracker row right-click menu's dependence on shared Blizzard menu systems and the loot-event pipeline's continued contact with taint-sensitive raw event payloads during combat-adjacent updates.

## What Changes

- Replace the tracker row right-click remove menu with a menu surface owned entirely by the addon while preserving the same visible `Remove` action for tracked item rows.
- Play the native menu checkbox sound when the surrogate tracker header, the `Loot Wishlist` header, or a tracker group header is expanded or collapsed.
- Tighten tracker interaction requirements so the remove menu does not depend on shared Blizzard context-menu or dropdown systems that can widen taint across unrelated Blizzard UI.
- Harden loot-event handling so tracked-loot detection and alert preparation normalize addon-owned values at a safe boundary instead of relying on later parsing of taint-sensitive raw loot payloads.
- Preserve existing tracker grouping, row rendering, Shift-click removal, loot-roll badge presentation, and alert behavior unless a narrower taint fix requires an explicit requirement change.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `wishlist-tracker-display`: tighten the tracker remove-menu requirements so right-click removal uses an addon-owned isolated menu surface and does not rely on shared Blizzard menu frameworks.
- `wishlist-loot-awareness`: tighten loot-event requirements so tracked-loot detection and alert preparation process loot events immediately, queue only normalized addon-owned alert records, and do not rely on `pcall`-based masking of unsafe parsing failures.

## Impact

- Affected code: `TrackerUI.lua`, `LootEvents.lua`, and `LootWishList.lua`.
- Affected systems: tracker row interactions, tracker header/group toggle feedback, tracker refresh stability, loot alert preparation, and combat/post-loot taint boundaries.
- Player-visible impact: tracked item rows still support right-click `Remove`, tracker expand/collapse interactions gain native checkbox-style sound feedback, and tracked-loot alerts and loot-roll markers remain available while using a safer event boundary.
