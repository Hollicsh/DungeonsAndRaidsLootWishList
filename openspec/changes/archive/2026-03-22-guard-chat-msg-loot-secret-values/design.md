## Context

`CHAT_MSG_LOOT` is a chat-derived boundary that can arrive under chat messaging lockdown during active encounters, active Mythic Keystone runs, and similar protected contexts. `LootEvents.lua` currently assumes the event payload is an ordinary Lua string and performs comparisons or pattern matching directly on it, which can trigger immediate Lua errors before the addon has a chance to reject the event.

This change is intentionally narrow. The addon already has broader loot-awareness requirements and previous OpenSpec work established that unsafe loot payloads should not be treated as a successful alert path. What remains missing is a first-line guard that decides whether the payload is safe to inspect before any string operation occurs.

## Goals / Non-Goals

**Goals:**
- Prevent `CHAT_MSG_LOOT` handling from reading secret or inaccessible payloads.
- Preserve existing loot-alert behavior for payloads that are safe to inspect.
- Make skipped unsafe payloads an explicit, deterministic outcome instead of a Lua error or hidden taint path.
- Keep the change localized to the loot-event boundary in `LootEvents.lua` and compatible with existing normalized alert flow.

**Non-Goals:**
- Guarantee other-player loot alerts during chat-lockdown contexts.
- Redesign alert UX, queueing, or self-loot correlation.
- Replace `CHAT_MSG_LOOT` with a new universal loot source.
- Broaden this change into a full loot-event architecture rewrite.

## Decisions

### Decision 1: Gate all loot-chat parsing behind a payload safety check

**Choice:** The `CHAT_MSG_LOOT` listener will perform a payload safety check before any comparison, concatenation, indexing, pattern matching, or other string operation runs.

**Rationale:**
- The current failure happens before item extraction logic, so the first safe decision point is the event boundary itself.
- A single boundary guard is easier to reason about than sprinkling defensive checks across multiple parsing steps.
- This preserves existing behavior for readable payloads while eliminating the known crash path.

**Alternatives considered:**
- Wrap later parsing in generic `pcall`-style suppression. Rejected because it still attempts unsafe access and hides failure rather than defining behavior.
- Keep comparing against empty strings or testing patterns first and only bail later. Rejected because those reads are already unsafe.

### Decision 2: Treat secret or inaccessible payloads as a no-alert outcome

**Choice:** If the incoming payload is secret or cannot be accessed by the current caller, the listener will stop processing that event and produce no normalized alert record.

**Rationale:**
- The addon cannot safely recover item and looter data without first reading the payload.
- Skipping the event is preferable to crashing or contaminating later UI paths.
- This aligns with the existing loot-awareness requirement that unsafe payloads must not become a hidden successful alert path.

**Alternatives considered:**
- Cache the raw payload and retry after combat. Rejected because deferring does not reliably make a secret value safe later.
- Fabricate a partial alert without reading the payload. Rejected because it would produce low-confidence or misleading alerts.

### Decision 3: Keep the guard implementation payload-focused, not context-only

**Choice:** The implementation may consult chat-lockdown state for diagnostics or early bailouts, but payload-specific secret/access checks remain the authoritative gate.

**Rationale:**
- Chat-lockdown context explains when risk is higher, but the observed behavior is value-specific and intermittent.
- Payload checks are more direct than assuming every event in a restricted context is unreadable or every event outside it is safe.
- This keeps the safety contract tied to the value that would be parsed.

**Alternatives considered:**
- Gate solely on `C_ChatInfo.InChatMessagingLockdown()`. Rejected because it is a contextual heuristic rather than a direct statement about the current payload.
- Ignore lockdown context entirely. Rejected because the context remains useful for reasoning, testing, and future diagnostics.

## Risks / Trade-offs

- Best-effort remote loot alerts may be missed during protected encounter contexts -> Mitigation: document that skipped unsafe payloads are expected and preferable to taint or Lua errors.
- Guard placement could drift over time if new parsing is added before the check -> Mitigation: define the event boundary as the required first decision point in the spec delta.
- Payload safety APIs may still leave some edge ambiguity -> Mitigation: treat any uncertainty as unreadable and skip parsing rather than trying to salvage the event.

## Migration Plan

1. Add the proposal-scoped safety rule to the loot-awareness spec delta.
2. Update `LootEvents.lua` so the first `CHAT_MSG_LOOT` decision is whether the payload is safe to inspect.
3. Keep existing normalization and alert queueing logic for readable payloads.
4. Verify that unsafe payloads are dropped cleanly and that readable payloads still produce alerts.

Rollback strategy:

- Revert the boundary guard if it causes unacceptable false negatives, then revisit the design with a broader replacement event-source strategy.

## Open Questions

- Should the implementation record lightweight debug telemetry for skipped payloads, or stay silent to avoid extra risk at the chat boundary?
- Do we want a future follow-up change that broadens structured event coverage for encounter rewards so fewer alerts depend on loot chat?
