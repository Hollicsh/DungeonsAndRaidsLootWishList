## Context

The addon has a performance issue where multiple events fire in rapid succession during gameplay, each triggering a full `RefreshAll()` independently instead of being coalesced into one refresh. This causes unnecessary work during moments when performance matters most.

## Goals / Non-Goals

**Goals:**
- Add debouncing to coalesce rapid-fire events into single refresh
- Reduce AJ polling interval from 250ms to 100ms
- Ensure critical events (login, user actions) get immediate refresh
- Preserve all existing user-facing behavior exactly

**Non-Goals:**
- No new user-facing features
- No changes to saved variable schema
- No modifications to tracker rendering
- No item name lookup optimization (not worth the complexity)
- Incremental bag tracking (not implemented - added complexity without sufficient gain)

## Decisions

### Decision 1: Timer-based debounce for RefreshAll

**Choice**: Use a timer-based debounce with 250ms window.

**Implementation**:
```lua
local function createDebouncedRefresh(delay)
  local timer = nil
  local fn = nil
  local function execute()
    timer = nil
    if fn then fn() end
  end
  return function(callback)
    fn = callback
    if timer then timer:Cancel() end
    timer = C_Timer.After(delay, execute)
  end
end

local debouncedRefresh = createDebouncedRefresh(0.25)
```

### Decision 2: Immediate vs Debounced refresh

**Choice**: Certain events require immediate refresh, others use debounce.

**Rationale**: 
- `PLAYER_LOGIN`: Needs immediate full refresh (initial state load)
- `BANKFRAME_OPENED`: New container opened, need immediate update
- `PLAYER_REGEN_ENABLED`: Player left combat, wants to see updates immediately
- User actions (checkbox click, Shift+Click): Immediate feedback required
- `CHAT_MSG_LOOT`, `BAG_UPDATE_DELAYED`: Can be debounced (non-critical)

### Decision 3: Keep AJ polling at 100ms

**Choice**: Keep polling but reduce from 250ms to 100ms.

**Rationale**:
- Originally attempted to remove polling entirely and rely on hooks
- Testing revealed checkboxes showed incorrect state without polling
- 100ms is a good balance: 60% less frequent than 250ms, but still responsive
- Polling only runs while AJ is open (not during normal gameplay)

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Debounce delays non-critical updates | 250ms is imperceptible to users |
| 100ms polling still has performance cost | Only runs when AJ is open |

## Migration Plan

1. Deploy change as single atomic update
2. No migration needed (no saved variable changes)
3. Users may notice slightly smoother performance during rapid events
4. Rollback: revert to previous Lua files (no data migration)
