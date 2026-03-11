## 1. Data Capture & Storage

- [ ] 1.1 Update `AdventureGuideUI.lua` to extract the `encounterID` or `bossID` and `instanceID` when a wishlist checkbox is clicked.
- [ ] 1.2 Update `ItemResolver.lua` to accept and normalize the new `encounterID` and `instanceID` fields.
- [ ] 1.3 Update `LootWishList.lua:SetTrackedFromItemData` to pass the new fields into the `WishlistStore` metadata.
- [ ] 1.4 Update `WishlistStore.lua` to explicitly save the `encounterID` and `instanceID` fields in the character's SavedVariables.
- [ ] 1.5 Update tests for `ItemResolver` and `WishlistStore` to cover the new metadata fields.

## 2. Model & Formatting

- [ ] 2.1 Update `TrackerModel.lua:buildGroups` to accept `bossName` in its data structure.
- [ ] 2.2 Update `TrackerModel.lua:buildDisplayText` to append `|cffffffff(Boss Name)|r` to the display text when `bossName` is present.
- [ ] 2.3 Ensure the format strictly follows `Item Name (ItemLevel) |cffffffff(Boss Name)|r` or `Item Name |cffffffff(Boss Name)|r`.
- [ ] 2.4 Update tests in `tests/core.test.js` to verify the new formatting behaviors.

## 3. Dynamic Resolution at Render

- [ ] 3.1 Update `LootWishList.lua:RefreshAll` or the namespace to resolve `bossName` for items that have an `encounterID` and an `instanceID`.
- [ ] 3.2 Implement logic to iterate `EJ_GetInstanceByIndex(i, true)` to verify if the `instanceID` is a raid.
- [ ] 3.3 Query `EJ_GetEncounterInfo(encounterID)` to get the `bossName` if the instance is verified as a raid.
- [ ] 3.4 Ensure dungeon instances bypass the boss name resolution or return `nil`.
- [ ] 3.5 Pass the dynamically resolved `bossName` into `TrackerModel.buildGroups` alongside the tracked items.

## 4. Data Migration

- [ ] 4.1 Create a one-time migration function in `WishlistStore.lua` (or a dedicated migration module).
- [ ] 4.2 Hook the migration function to execute when the addon's saved variables are loaded (`ADDON_LOADED` event).
- [ ] 4.3 Ensure the migration function safely handles existing items that lack `encounterID` and `instanceID`, initializing default values or safely ignoring them without corruption.
