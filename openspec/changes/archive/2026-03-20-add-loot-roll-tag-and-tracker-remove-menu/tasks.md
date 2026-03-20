## 1. Loot Roll Badge

- [x] 1.1 Refactor the tracked loot roll `Wishlist` tag in `LootEvents.lua` into a compact badge that can render both an icon and text together.
- [x] 1.2 Add the Blizzard atlas `Banker` to the left of the localized `Wishlist` label and keep the badge aligned on tracked loot roll frames.

## 2. Tracker Remove Menu

- [x] 2.1 Update `TrackerUI.lua` so only tracked item rows register a right-click interaction while group headers and boss headers explicitly do not.
- [x] 2.2 Open a Blizzard-native context menu on tracked item-row right-click with exactly one action, `Remove`, using a compatibility fallback when the newer menu API is unavailable.
- [x] 2.3 Route the `Remove` menu action through the existing tracked-item removal path so the tracker refreshes consistently with Shift-click removal.

## 3. Validation

- [x] 3.1 Verify the loot roll badge still appears only for tracked items and that the icon-text layout remains readable on the native roll frame template.
- [x] 3.2 Verify tracker right-click removal works for tracked item rows, does not appear on group or boss headers, and preserves Shift-click removal.
- [x] 3.3 Run combat-time and post-refresh validation for the Blizzard-native context menu path, using `taint.log` if needed, and fall back to an addon-owned menu only if the native menu paths prove unsafe.
