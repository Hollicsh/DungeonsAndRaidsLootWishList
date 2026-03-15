## 1. Tracker source-group hardening

- [x] 1.1 Update `LootWishList.lua` so `BuildTrackerGroups()` groups items from persisted wishlist metadata only and no longer calls live source-label fallback during tracker rebuilds
- [x] 1.2 Preserve `Other` fallback behavior for tracked items that do not have stored source metadata
- [x] 1.3 Verify dungeon and raid grouping still works for items tracked from the Adventure Guide with stored `sourceLabel` metadata
- [x] 1.4 Remove direct Encounter Journal opening from tracker source-group header clicks while preserving collapse behavior
- [x] 1.5 Mirror native Objective Tracker-style header animation when items are newly added to or completed within a source group

## 2. Loot-event boundary hardening

- [x] 2.1 Refactor `LootEvents.lua` so tracked-loot detection does not directly index taint-sensitive raw `CHAT_MSG_LOOT` payloads unsafely
- [x] 2.2 Normalize the minimum addon-owned loot alert record as early as possible and ensure deferred alert logic consumes only normalized values
- [x] 2.3 Preserve the current user-facing behavior where other-player tracked-item loot still produces the expected alert without changing local ownership state

## 3. Regression validation

- [x] 3.1 Re-run the dungeon and loot-hover reproduction flow that previously triggered `MoneyFrame_Update` secret-value errors and verify tooltips remain stable
- [x] 3.2 Re-run Adventure Guide hover and checkbox interactions after loot events and verify no tooltip corruption or taint errors occur
- [x] 3.3 Reproduce the prior combat-time loot-event scenario and verify `LootEvents.lua` no longer errors on secret loot payloads
- [x] 3.4 Verify manual Encounter Journal opening remains stable and tracker source headers no longer trigger unsafe Journal opening
