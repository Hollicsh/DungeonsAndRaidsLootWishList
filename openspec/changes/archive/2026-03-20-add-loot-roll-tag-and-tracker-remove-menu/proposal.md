## Why

Tracked-item loot roll frames and tracker rows already surface wishlist state, but both surfaces are missing small usability cues that would make tracked items easier to recognize and remove in moment-to-moment play. Adding a clearer loot-roll badge and a discoverable tracker-row remove action improves usability without changing the wishlist data model.

## What Changes

- Add the Blizzard atlas `Banker` to the left of the loot roll frame `Wishlist` tag for tracked items and render it as a compact badge.
- Add a right-click action on tracker item rows that opens a single-action Blizzard-native context menu with only `Remove`.
- Preserve the existing fast removal path such as Shift-click while introducing the new contextual remove entry.
- Keep both UI changes on addon-owned surfaces and validate the tracker menu interaction against combat-time taint risk.

## Capabilities

### New Capabilities

### Modified Capabilities

- `wishlist-loot-awareness`: extend tracked loot roll frame tagging requirements so the wishlist tag includes an icon, not just text.
- `wishlist-tracker-display`: add a right-click tracker-row removal interaction that exposes a single `Remove` menu action for tracked item rows.

## Impact

- Affected code: `LootEvents.lua`, `TrackerUI.lua`, and possibly `Locales.lua` if the remove label needs localization.
- Affected systems: tracked loot roll frame presentation and Objective Tracker row interactions.
- Risk areas: Blizzard context-menu behavior during combat, tracker refresh timing while a context menu is open, and preserving existing taint-safe tracker boundaries.
