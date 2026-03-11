## Why

Currently, items tracked from raid bosses only display the instance name as the group header. In large raids, players often need to know exactly which boss drops the item without reopening the Adventure Guide to check. Adding the boss name to the objective tracker row for raid items solves this by providing immediate, at-a-glance context for where the loot comes from.

## What Changes

- When an item is tracked from a raid boss in the Adventure Guide, the addon will capture and store the encounter ID or boss identifier along with the instance ID.
- During tracker refresh, the addon will dynamically scan the Adventure Guide API (`EJ_GetInstanceByIndex`, `EJ_GetEncounterInfo`, etc.) to determine if the instance is a raid and to resolve the boss name.
- If the source is determined to be a raid boss, the objective tracker will organize items hierarchically: raid instances display a boss header (gray section label) followed by items belonging to that boss. Items show the item name and best looted item level (if any), without the boss name inline. Bosses are sorted by their encounter order within the raid.
- This behavior will only apply to raid instances; dungeon items will continue to display normally to avoid unnecessary clutter.
- A one-time data migration function will execute when saved variables are loaded to ensure existing wishlist data isn't corrupted and is correctly structured with the new expected fields.

## Capabilities

### New Capabilities

*(None)*

### Modified Capabilities

- `wishlist-tracker-display`: Tracker rows for items from raid bosses will be organized hierarchically with boss names as gray section headers, sorted by encounter order within the raid.

## Impact

- **AdventureGuideUI.lua**: Will need to extract the `encounterID` or `bossID` and `instanceID` when a wishlist checkbox is clicked.
- **WishlistStore.lua**: Will need to persist the `encounterID`/`bossID` and `instanceID` fields in the tracked item's metadata.
- **LootWishList.lua** / **TrackerModel.lua** / **SourceResolver.lua**: Will need to perform the API scan at render time to determine `isRaid` and resolve the `bossName` for formatting.