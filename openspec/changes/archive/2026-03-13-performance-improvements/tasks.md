## 1. Adventure Guide Polling Reduction

- [x] 1.1 Reduce polling interval from 250ms to 100ms in AdventureGuideUI.lua

## 2. Event Debouncing

- [x] 2.1 Create debounce utility function in LootWishList.lua
- [x] 2.2 Apply 250ms debounce to RefreshAll() calls from events
- [x] 2.3 Exclude PLAYER_LOGIN from debounce (immediate refresh needed)
- [x] 2.4 Exclude PLAYER_REGEN_ENABLED from debounce (left combat)
- [x] 2.5 Exclude BANKFRAME_OPENED from debounce (new container opened)
- [x] 2.6 Use RefreshAllImmediate() for user actions (SetTrackedFromItemData, RemoveTrackedItem)

## 3. Verification (In-Game Testing)

- [x] 3.1 Test: Login → verify immediate refresh works
- [x] 3.2 Test: Open bank → verify immediate refresh works
- [x] 3.3 Test: Loot item → verify debounced refresh works
- [x] 3.4 Test: Open AJ → verify 100ms polling works, checkboxes update correctly
- [x] 3.5 Test: Shift+Click remove in tracker → verify checkbox clears immediately in AJ
- [x] 3.6 Test: Verify no taint issues
