## Context

The current tracked-loot alert path still depends on `CHAT_MSG_LOOT` payload values that may arrive tainted, and comparing the reported looter name against the active player name has already produced secret-string taint errors. At the same time, the feature must stay enabled: the addon still needs to surface other-player tracked-loot alerts, and the user explicitly accepts suppressing an alert when both the local player and another player loot the same tracked item close together.

The addon already has one reliable source of addon-owned self state: possession refresh. `LootWishList.lua` rebuilds current possession from equipment, bags, and bank contents, and that refresh can tell when a tracked item has just become newly owned by the local player. That gives us a local signal we can correlate against later loot-chat handling without comparing taint-sensitive player-name payloads.

## Goals / Non-Goals

**Goals:**

- Remove self-name comparison from the tracked-loot alert path.
- Suppress self-loot popups using addon-owned recent-self-loot correlation keyed by stable tracked item identity.
- Preserve other-player tracked-loot alerts and deferred popup display behavior.
- Replace Blizzard shared popup usage with an addon-owned alert frame that preserves the current StaticPopup-style UX, including player name, item icon, item name, and item tooltip-on-hover behavior.
- Keep the change narrow and testable within `LootWishList.lua`, `LootEvents.lua`, and the existing Wasmoon test suite.

**Non-Goals:**

- Eliminate every possible taint source from `CHAT_MSG_LOOT` parsing.
- Redesign loot alert presentation or popup timing behavior.
- Add persistent saved-variable data for loot correlation.
- Guarantee that simultaneous same-item local and remote loot always produces a remote alert.
- Reuse Blizzard `StaticPopup_Show()` or shared popup frame infrastructure for the new alert surface.

## Decisions

### Decision 1: Use short-lived recent-self-loot correlation instead of looter-name comparison

**Choice:** The addon will stop comparing the loot-event looter name against `UnitName("player")` and will instead suppress a popup when the tracked item's stable identity was recently recorded as self-looted.

**Rationale:**

- The taint error is triggered by comparing a secret string looter name.
- Self-popup suppression is a convenience rule, not core item-matching logic.
- The user explicitly accepts suppressing an alert when both players loot the same item within the correlation window.

**Alternatives considered:**

- Keep comparing looter names with more guards. Rejected because the looter-name payload itself is the taint problem.
- Disable tracked-loot alerts entirely. Rejected because the feature must remain available.
- Move the comparison later into popup display. Rejected because forwarding the same tainted value does not make it safe.

### Decision 2: Mark recent self loot from possession refresh deltas

**Choice:** `LootWishList.lua` will detect newly possessed tracked items during possession refresh and record a short-lived recent-self-loot marker in addon runtime state.

**Rationale:**

- Possession refresh already computes local ownership from equipment, bags, and bank contents.
- That signal is inherently about the current character, so it avoids relying on loot-chat player names.
- This keeps the new state local to the orchestration module that already owns possession state.

**Alternatives considered:**

- Mark self loot directly from chat events. Rejected because that still depends on taint-sensitive chat payload inspection.
- Store self-loot markers in saved variables. Rejected because the data is transient and purely runtime-driven.

**Design details:**

- Use stable tracked item identity as the key, matching the existing wishlist identity model.
- Record only a timestamp and lazily expire old entries.
- Mark only newly gained tracked ownership, not every refresh pass.

### Decision 3: Keep suppression heuristic intentionally biased toward local loot

**Choice:** A recent self-loot marker suppresses any popup for that same tracked item within a short correlation window, even if another player also loots the same item during that window.

**Rationale:**

- This matches the explicitly accepted user behavior.
- It keeps the heuristic simple and predictable.
- A short window reduces false suppression without requiring taint-sensitive identity checks.

**Alternatives considered:**

- Try to distinguish simultaneous local and remote loots more precisely. Rejected because that would likely reintroduce risky event-payload comparisons.
- Never suppress when timing is ambiguous. Rejected because it would reintroduce self-popups the user does not want.

**Design details:**

- Start with a short fixed TTL window.
- Suppression checks happen only after tracked item identity is resolved.

### Decision 4: Keep normalized alert records as the only queued alert data

**Choice:** `LootEvents.lua` may interpret the incoming loot payload immediately, but any queued alert state remains the existing normalized addon-owned alert record.

**Rationale:**

- The prior change already established that queued popup work should consume normalized records rather than raw event payloads.
- This change is about self-alert suppression, not about broadening queued state.
- Keeping the queue contract stable limits scope and test impact.

**Alternatives considered:**

- Queue raw event payloads and decide later. Rejected because it broadens the lifetime of taint-sensitive data.

### Decision 5: Replace StaticPopup-based loot alerts with an addon-owned popup that mirrors the same UX

**Choice:** The tracked-loot alert will no longer use `StaticPopup_Show()`. Instead, the addon will render a dedicated addon-owned popup frame that preserves the same user experience: player-name message text, item icon, item name, dismiss control, and item tooltip on hover.

**Rationale:**

- The user still needs exact chat-derived player and item presentation.
- `StaticPopup_Show()` is Blizzard-owned shared UI and increases taint-spread risk when fed chat-derived values.
- An addon-owned popup keeps those values confined to addon-owned UI while preserving the familiar alert flow.

**Alternatives considered:**

- Keep `StaticPopup_Show()` and only change the self-suppression logic. Rejected because the popup system itself remains a risky boundary for chat-derived values.
- Drop player name or rich item presentation from the alert. Rejected because the feature explicitly needs those fields.

**Design details:**

- The popup remains single-purpose and local to loot alerts rather than becoming a general modal framework.
- The layout mirrors the current alert UX as closely as practical without depending on Blizzard popup templates.
- The item row shows icon and name, and hovering that row opens the tooltip for the shown item.
- Deferred display still uses normalized queued alert records, but final rendering happens only in addon-owned frames.

## Risks / Trade-offs

- **Risk: Another player's same-item loot may be suppressed if it happens soon after local loot.** -> Mitigation: this is an accepted product trade-off and the TTL stays short.
- **Risk: Possession refresh may not mark recent self loot quickly enough in some edge timing cases.** -> Mitigation: keep the TTL long enough to tolerate refresh ordering jitter and validate with loot timing tests.
- **Risk: `CHAT_MSG_LOOT` parsing may still have other taint-sensitive edges unrelated to self-name comparison.** -> Mitigation: keep this change scoped, remove the known comparison trigger, and validate the specific reported taint regression.
- **Risk: Matching StaticPopup UX too loosely could feel like a regression even if taint risk improves.** -> Mitigation: explicitly mirror the existing alert's layout, copy, dismissal flow, and hover behavior in addon-owned UI.

## Migration Plan

1. Add runtime helpers in `LootWishList.lua` to mark and query recent self loot by stable tracked item identity.
2. Update possession refresh to detect newly owned tracked items and mark recent self-loot timestamps.
3. Update `LootEvents.lua` to stop comparing looter names and instead suppress popups through the recent-self-loot helper.
4. Replace `StaticPopup_Show()`-based loot alert rendering with an addon-owned popup frame that displays player name, item icon, item name, and hover tooltip behavior.
5. Add or update tests covering self-loot suppression, expiration behavior, and simultaneous same-item suppression expectations.

Rollback strategy:

- Revert the recent-self-loot helper and restore the prior alert suppression path if the heuristic causes unacceptable missed alerts.

## Open Questions

- What TTL gives the best balance between suppressing self-popups and avoiding unrelated remote suppression?
- Do we need separate tests for bank-known versus bag/equipment-only possession refresh as self-loot markers?
- Which parts of the current StaticPopup UX should be mirrored exactly versus approximated in addon-owned UI if Blizzard frame metrics differ slightly?
