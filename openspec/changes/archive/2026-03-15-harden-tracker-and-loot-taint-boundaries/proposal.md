## Why

Post-loot tracker refreshes and loot-event handling are crossing Blizzard UI security boundaries in ways that cause secret-value Lua errors, broken tooltip money rendering, and combat-sensitive instability. Investigation isolated the main persistent tooltip corruption to live Encounter Journal source-label lookup during tracker rebuilds, and also found a separate loot-event parsing path that can index secret `CHAT_MSG_LOOT` payloads directly.

## What Changes

- Remove live Encounter Journal source-label fallback from tracker rebuilds and group tracker rows from persisted source metadata only, falling back to `Other` when stored source data is unavailable.
- Preserve dungeon and raid grouping without consulting live Encounter Journal globals during generic tracker refreshes.
- Remove tracker source-header driven Encounter Journal opening because direct tracker-triggered journal navigation was isolated as a remaining tooltip taint surface.
- Harden loot-event processing so the addon does not directly pattern-match unsafe secret loot-message payloads in ways that can throw Lua errors during combat or loot interactions.
- Keep boss metadata and other tracker presentation behavior only when it can be derived without reintroducing the taint boundary that broke shared Blizzard tooltips.

## Capabilities

### New Capabilities
- None.

### Modified Capabilities
- `wishlist-tracker-display`: Change tracker source-grouping requirements so tracker rebuilds do not depend on live Encounter Journal state, use stored metadata with `Other` fallback, and no longer deep-link into the Encounter Journal from tracker source headers.
- `wishlist-loot-awareness`: Change loot-event requirements so tracked-loot detection and alert preparation avoid unsafe direct processing of secret loot-event payloads.

## Impact

- Affected code: `LootWishList.lua`, `LootEvents.lua`, `AdventureGuideUI.lua`, and any helper modules involved in source metadata capture or loot-event normalization.
- Affected systems: tracker grouping, Encounter Journal integration boundaries, loot alert preparation, and post-loot refresh stability.
- Player-visible impact: dungeon/raid grouping remains available when metadata is known, while tooltip corruption and loot-event secret-value errors are removed.
