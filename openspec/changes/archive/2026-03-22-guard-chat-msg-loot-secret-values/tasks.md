## 1. Loot Boundary Guard

- [x] 1.1 Update `LootEvents.lua` so `CHAT_MSG_LOOT` checks payload safety before any string comparison, emptiness check, or pattern matching runs.
- [x] 1.2 Make unsafe secret or inaccessible payloads exit the listener without creating a normalized alert record.

## 2. Alert Flow Preservation

- [x] 2.1 Keep the existing normalization and tracked-loot alert path unchanged for payloads that pass the boundary safety check.
- [x] 2.2 Ensure skipped unsafe payloads do not fall through generic error suppression paths or partial alert queueing.

## 3. Verification

- [x] 3.1 Add or update automated coverage for readable versus unreadable loot-chat payload handling if the current test harness can express the boundary safely.
- [x] 3.2 Validate that readable loot alerts still work and that protected encounter or Mythic+ scenarios no longer throw the secret-value Lua error.
