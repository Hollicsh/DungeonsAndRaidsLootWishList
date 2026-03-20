## 1. Tracker Menu Isolation

- [x] 1.1 Remove the shared Blizzard menu and dropdown code paths from `TrackerUI.lua` and introduce one reusable addon-owned remove-menu popup.
- [x] 1.2 Style and position the addon-owned popup to mirror Blizzard menu feel with native font, highlight, and menu checkbox-style sound behavior while keeping ownership entirely inside addon frames.
- [x] 1.3 Route tracked item-row right-click to the addon-owned popup, keep Shift-click removal unchanged, and ensure group and boss headers never open the remove menu.

## 2. Tracker Collapse Sound Feedback

- [x] 2.1 Add a narrow `TrackerUI.lua` helper for native checkbox-style sound playback that can be reused by tracker collapse controls.
- [x] 2.2 Play the checkbox-style sound when the surrogate header or the `Loot Wishlist` header changes collapsed state, without firing during plain refresh or rerender.
- [x] 2.3 Play the same checkbox-style sound when a tracker group header changes collapsed state, only when the click actually toggles that group.

## 3. Loot Event Boundary Hardening

- [x] 3.1 Remove `pcall`-based unsafe loot-payload parsing from the tracked-loot success path so raw taint-sensitive payloads are not treated as normal strings.
- [x] 3.2 Refactor `LootEvents.lua` and any `LootWishList.lua` orchestration so only addon-owned normalized loot records flow into alert and refresh logic.
- [x] 3.3 Ensure un-normalizable loot payloads are dropped safely without queuing alerts, mutating wishlist state, or masking unsafe parsing as success.

## 4. Validation

- [x] 4.1 Verify tracker right-click removal still works for tracked item rows, uses the addon-owned popup, dismisses cleanly, and never appears on group or boss headers.
- [x] 4.2 Verify surrogate-header, `Loot Wishlist` header, and group-header collapse toggles each play the checkbox-style sound exactly once per real state change.
- [x] 4.3 Reproduce loot, combat, tracker, and Damage Meter scenarios with `taint.log` enabled to confirm the menu and loot-event changes do not reintroduce secret-value or shared-UI taint failures.
