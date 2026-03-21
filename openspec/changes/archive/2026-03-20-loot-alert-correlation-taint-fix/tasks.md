## 1. Recent Self-Loot Correlation

- [x] 1.1 Add runtime helpers in `LootWishList.lua` to record, query, and lazily expire recent self-loot markers keyed by stable tracked item identity.
- [x] 1.2 Update possession refresh in `LootWishList.lua` to detect newly owned tracked items and mark recent self loot only for newly gained ownership.
- [x] 1.3 Update `LootEvents.lua` to suppress self-popups through the recent-self-loot helper instead of comparing the reported looter name against the active player name.

## 2. Addon-Owned Loot Alert Popup

- [x] 2.1 Replace `StaticPopup_Show()`-based tracked-loot alert rendering with an addon-owned popup frame that is owned and managed entirely by the addon.
- [x] 2.2 Build the popup so it preserves StaticPopup-like UX with player-name text, item icon, item name, dismiss interaction, and hover tooltip behavior for the item presentation.
- [x] 2.3 Keep deferred safe-state alert display working by feeding the addon-owned popup from the existing normalized alert-record queue.

## 3. Validation

- [x] 3.1 Add or update tests covering recent-self-loot suppression, expiration behavior, and the accepted simultaneous same-item suppression behavior.
- [x] 3.2 Verify in-game that self-looted tracked items do not show the popup, while other-player tracked loot still shows the addon-owned popup with player name, item icon, item name, and item tooltip on hover.
- [x] 3.3 Reproduce the previously reported taint scenario and confirm the looter-name comparison error no longer occurs.
