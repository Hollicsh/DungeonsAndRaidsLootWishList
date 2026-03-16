## Why

The wishlist tracker currently groups items only by loot source, which makes it harder to answer a different but equally important question: which equipment slots still have wishlist upgrades available. Adding a tracker-level grouping toggle lets players switch between source-first planning and slot-first planning without changing wishlist membership, while also enriching tracker-row tooltips with drop-location context that remains grounded in persisted metadata rather than live Encounter Journal state.

## What Changes

- Add a tracker header toggle that switches wishlist grouping between `Loot Source` and `Equipment Slot`, with `Loot Source` selected by default.
- Persist the active tracker grouping preference per character so the tracker rebuild state machine can restore the same grouping mode across reloads and sessions.
- Expand tracker grouping data so group identity is stable per grouping mode and collapse state does not collide between source-mode and slot-mode groups.
- Persist and backfill non-UI item metadata needed for slot grouping and tooltip context, including stable equipment-slot identity and drop-source context already associated with wishlist entries.
- Update tracker model behavior so source mode keeps current source-first grouping, while slot mode renders a flat list under each equipment slot group with no nested boss or source subheaders.
- Add a tracker-row tooltip footer line only in `Equipment Slot` mode, separated from the base tooltip by a spacer line and showing `Drops from: <Instance Name>` for dungeon items or `Drops from: <Instance Name> - <Boss Name>` for raid items.
- Preserve Adventure Guide wishlist checkbox behavior while expanding item normalization so toggling a loot-row checkbox still adds and removes items correctly under the new grouping and metadata rules.
- Preserve the addon's side-car tracker architecture and avoid Blizzard tracker-module registration or other taint-prone integration patterns while introducing the new header control and tooltip footer.

## Capabilities

### New Capabilities
- `tracker-grouping-preferences`: Define tracker grouping-mode selection, persistence, and per-mode group-collapse behavior for the wishlist tracker.

### Modified Capabilities
- `wishlist-tracker-display`: Change tracker grouping requirements so the tracker can render either source-grouped or slot-grouped views from persisted wishlist metadata.
- `tracker-item-tooltips`: Change tracker tooltip requirements so tracker-row tooltips include a wishlist-specific drop-source footer line while remaining isolated from Blizzard-owned tooltip flows.

## Impact

- Affected code: `TrackerUI.lua`, `TrackerModel.lua`, `WishlistStore.lua`, `SourceResolver.lua`, `LootWishList.lua`, `AdventureGuideUI.lua`, `Locales.lua`.
- Affected state: character-scoped saved variables for tracker grouping preference, per-mode collapsed groups, and item metadata needed for slot grouping and tooltip context.
- Affected systems: Objective Tracker side-car rendering, tracker rebuild orchestration, tooltip presentation, and metadata capture/backfill from Adventure Guide and persisted wishlist entries.
- Taint considerations: the change must keep interactive controls and tooltip customization on addon-owned surfaces, avoid registration into Blizzard's Objective Tracker module manager, avoid shared-tooltip contamination, and avoid combat-unsafe frame mutations on protected Blizzard UI.
