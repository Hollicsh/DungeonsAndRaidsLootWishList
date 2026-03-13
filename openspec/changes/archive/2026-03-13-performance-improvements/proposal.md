## Why

The addon has a performance issue where multiple related events fire in rapid succession (login, looting, banking), each triggering a full `RefreshAll()` independently instead of being coalesced into one refresh. This causes unnecessary work during gameplay moments when performance matters most.

## What Changes

### Event Debouncing
- **ADD** a debounce utility with 250ms window
- Most events use debounced refresh to coalesce rapid-fire events
- Critical events (login, bank open, user actions, combat end) use immediate refresh to ensure responsive UI

### Adventure Guide Polling
- **REDUCE** polling interval from 250ms to 100ms
- Kept polling (instead of removing) because hooks proved unreliable for keeping checkbox state in sync
- 100ms provides good balance between responsiveness and performance

### What Was Considered But Not Implemented
- **Incremental bag tracking**: Attempted but removed - added complexity without sufficient performance gain
- **Removing AJ polling entirely**: Tried but checkboxes showed incorrect state without polling

## Capabilities

### Modified Capabilities

None. The changes are implementation-only optimizations that preserve existing behavior.

## Impact

| File | Change Type | Description |
|------|-------------|-------------|
| `AdventureGuideUI.lua` | Modify | Polling interval 250ms → 100ms |
| `LootWishList.lua` | Modify | Add debounce utility, implement RefreshAllImmediate |
