## Why

`CHAT_MSG_LOOT` can deliver secret chat payloads during encounter, Mythic+, and other chat-lockdown contexts. The current loot listener reads that payload as a normal string, which can trigger Lua errors and taint propagation even when the addon is only trying to observe loot events.

## What Changes

- Add an explicit secret-value/accessibility guard at the `CHAT_MSG_LOOT` event boundary before any string comparison or pattern matching occurs.
- Skip unsafe loot-chat payloads instead of attempting to parse them, queue alerts from them, or rely on generic error suppression.
- Preserve existing loot-awareness behavior for safely readable payloads while making unsafe payload handling a defined no-alert outcome instead of a crash path.
- Document the safety contract for loot awareness so future changes treat chat payloads as a taint boundary.

## Capabilities

### New Capabilities

### Modified Capabilities
- wishlist-loot-awareness: define that loot-chat handling must detect secret or inaccessible payloads at the event boundary and must not parse or queue alerts from those unsafe values.

## Impact

- Affected code: `LootEvents.lua` and any helpers used by tracked-loot alert normalization.
- Affected behavior: other-player loot alerts from `CHAT_MSG_LOOT` become best-effort during chat-lockdown contexts rather than guaranteed.
- Affected systems: loot awareness, taint safety, and runtime alert normalization.
