## 1. Saved state and metadata

- [x] 1.1 Extend `WishlistStore.lua` character state to persist tracker grouping mode with `Loot Source` as the default.
- [x] 1.2 Migrate legacy collapsed source groups into a new per-mode tracker collapse structure without losing existing collapse state.
- [x] 1.3 Persist stable equipment-slot metadata on wishlist entries and expose helpers to read and write it without storing localized slot labels.
- [x] 1.4 Update wishlist metadata backfill paths so tracked items recover missing source and slot metadata needed for grouping and slot-mode tooltip footers.

## 2. Group resolution and tracker model

- [x] 2.1 Extend `SourceResolver.lua` to resolve stable group keys and labels for both source mode and slot mode, including `Other` fallbacks.
- [x] 2.2 Update tracker rebuild orchestration in `LootWishList.lua` to pass the active grouping mode into grouping resolution and tracker-model creation.
- [x] 2.3 Update `TrackerModel.lua` to build groups with stable keys, preserve source-mode raid boss subheaders, and keep slot mode flat.
- [x] 2.4 Update collapse and animation bookkeeping to use stable group keys instead of rendered labels.

## 3. Tracker UI and tooltip behavior

- [x] 3.1 Add an addon-owned grouping toggle control to the `Loot Wishlist` header that switches between `Loot Source` and `Equipment Slot` without using Blizzard dropdown patterns.
- [x] 3.2 Wire the header toggle to saved tracker state and trigger tracker refreshes without changing wishlist membership.
- [x] 3.3 Update tracker group header rendering so collapse and expand behavior works correctly for both grouping modes.
- [x] 3.4 Update the dedicated tracker tooltip so only slot mode appends `Drops from: <Instance Name>` or `Drops from: <Instance Name> - <Boss Name>` when persisted metadata is available.
- [x] 3.6 Preserve Adventure Guide checkbox add/remove behavior while tracker item normalization and raid-source detection change.
- [x] 3.5 Add any required localized strings in `Locales.lua` for grouping labels, slot fallback labels, and slot-mode tooltip footer text.

## 4. Validation

- [x] 4.1 Add or update pure-logic tests for grouping-mode resolution, stable group keys, per-mode collapse behavior, and slot/source fallback handling.
- [x] 4.2 Verify tracker behavior in-game for source mode, slot mode, per-character persistence, and preserved source-mode raid boss grouping.
- [x] 4.3 Verify slot-mode tooltip footers remain tracker-only and do not interfere with Blizzard-owned item tooltips.
- [x] 4.4 Run taint-focused checks around tracker toggling, hover tooltips, and combat-state updates using `taint.log` if needed.
- [x] 4.5 Verify Adventure Guide loot-row checkbox clicks still add and remove items after the grouping-mode changes.
