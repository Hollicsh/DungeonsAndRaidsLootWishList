## Why

The current loot alert path still relies on `CHAT_MSG_LOOT` payload fields that can arrive tainted, and direct comparisons against the reported looter name can trigger secret-value taint errors. We need a safer way to suppress self-loot popups without disabling other-player tracked-loot alerts.

## What Changes

- Replace self-name comparison in the tracked-loot alert path with a recent-self-loot correlation heuristic keyed by stable tracked item identity.
- Record short-lived addon-owned self-loot markers when local possession refresh detects newly acquired tracked items.
- Use those markers to suppress likely self-loot popups for the same tracked item within a short time window, even if another player loots that item simultaneously.
- Replace the Blizzard `StaticPopup_Show()` loot alert with a fully addon-owned alert popup that preserves the same user experience while displaying chat-derived player and item information inside addon-owned UI only.
- Preserve other-player tracked-loot alerts and deferred safe-state popup display while removing the need to compare taint-sensitive player-name payloads or route chat-derived values through Blizzard popup UI.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `wishlist-loot-awareness`: change self-alert suppression requirements so tracked-loot alerts use recent self-loot correlation instead of comparing the loot-event looter name against the active player name, and require an addon-owned alert popup with StaticPopup-like UX for player name and item presentation.

## Impact

- Affected code: `LootEvents.lua`, `LootWishList.lua`, and `tests/core.test.js`.
- Affected code: `LootEvents.lua`, `LootWishList.lua`, alert UI code, and `tests/core.test.js`.
- Affected systems: tracked-loot alert suppression, possession-refresh driven loot correlation, custom alert presentation, and taint-sensitive loot event handling.
- Player-visible impact: self-looted tracked items no longer depend on looter-name comparison to suppress popups, simultaneous same-item loot can be intentionally suppressed if the local player just looted that item, and tracked-loot alerts keep a StaticPopup-like UX while using addon-owned UI.
