## Context

The addon has three confirmed taint-boundary failures.

- `LootWishList.lua` rebuilds tracker groups after loot and combat-state refreshes. During that rebuild, `BuildTrackerGroups()` currently asks `GetCurrentSourceLabel(nil)` for a live source label, and that helper falls back to live Encounter Journal globals such as `EncounterJournal.instanceID`, `EncounterJournal.selectedInstanceID`, `EJ_GetCurrentInstance()`, and journal title text. A temporary local experiment disabled only that live source-label fallback, then restored the code after testing. Repeated dungeon-run testing showed that removing only this fallback made post-loot tooltips and Adventure Journal item hovers stable again while keeping encounter-rank priming and boss metadata enabled.
- `LootEvents.lua` directly pattern-matches the `CHAT_MSG_LOOT` message string. In combat and loot-heavy scenarios, that payload can arrive as a secret string, causing immediate Lua errors when the addon indexes it with `message:match(...)`.
- `TrackerUI.lua` opens the Encounter Journal directly from tracker source-header clicks through `EncounterJournal_OpenJournal(nil, instanceID)`. Isolation runs showed that manual Encounter Journal opening stays stable while tracker-triggered journal opening is sufficient to reintroduce the `MoneyFrame_Update` tooltip taint even when loot popups and Adventure Guide checkbox integration are disabled.

These failures share the same architectural problem: runtime refresh paths are consulting Blizzard-owned live state instead of relying on addon-owned normalized data.

```text
Current taint-prone shape

Loot / tracker refresh
        |
        +--> live Encounter Journal state lookup for grouping
        |
        +--> direct loot-message string parsing on secret payloads
        v
   Blizzard tooltip / money rendering breaks

Target shape

Loot / tracker refresh
        |
        +--> persisted wishlist source metadata
        |
        +--> normalized loot-event records only
        v
   Blizzard tooltip flows stay isolated
```

## Goals / Non-Goals

**Goals:**

- Preserve tracker grouping by dungeon or raid when stored source metadata is already known.
- Remove live Encounter Journal state reads from generic tracker rebuild and grouping paths.
- Keep tracker fallback behavior by grouping unknown-source items under `Other`.
- Harden loot-event handling so secret `CHAT_MSG_LOOT` payloads do not trigger Lua errors or contaminate later UI work.
- Remove direct tracker-driven Encounter Journal opening as a taint source.
- Keep fixes aligned with current module boundaries: tracker model/build logic in `LootWishList.lua` and `TrackerModel.lua`, loot-event parsing in `LootEvents.lua`, metadata capture in `AdventureGuideUI.lua`.

**Non-Goals:**

- Redesigning tracker UI, loot alerts, or Adventure Guide controls.
- Removing dungeon/raid source grouping from the addon.
- Replacing encounter-rank priming or boss metadata logic unless a narrower fix proves insufficient.
- Reworking Blizzard's own Encounter Journal tooltip behavior.
- Preserving tracker source-header deep-link navigation into the Encounter Journal if that navigation cannot be implemented safely.

## Decisions

### Decision 1: Tracker grouping uses persisted source metadata only

**Choice:** `BuildTrackerGroups()` will group items from stored metadata already persisted on the wishlist entry, not from live Encounter Journal state. If the stored source label is missing or empty, the tracker will place the item under `Other`.

**Rationale:**

- The temporary reverted experiment showed the addon becomes stable when the live source-label fallback is removed but other tracker-side Encounter Journal interactions remain enabled.
- Tracker rebuild is a high-frequency path after loot, bag, and combat updates; it should not depend on a live Blizzard journal context.
- Persisted `sourceLabel` already exists on tracked entries and is the correct stable source for grouping.

**Alternatives considered:**

- Keep calling `GetCurrentSourceLabel(nil)` during tracker rebuild and try to guard it with combat checks. Rejected because the taint issue is about shared-state coupling, not only combat timing.
- Remove source grouping entirely. Rejected because grouping by dungeon/raid remains a desirable and achievable feature when metadata is stored.

**Design details:**

- Tracker grouping input will use `item.sourceLabel` only.
- No tracker grouping path will call `GetCurrentSourceLabel(nil)`.
- `Other` remains the only fallback when stored source metadata is unavailable.

### Decision 2: Encounter Journal remains the metadata capture surface, not the tracker rebuild source

**Choice:** Source metadata continues to be captured when the user tracks an item from the Adventure Guide, but tracker rebuilds will treat that metadata as authoritative instead of consulting the live Encounter Journal again later.

**Rationale:**

- The Adventure Guide is the natural place to discover a loot item's dungeon or raid source.
- Capturing the source at track time keeps the expensive and taint-sensitive Blizzard interaction on an explicit user-driven surface rather than every later tracker refresh.
- This preserves dungeon/raid grouping without reintroducing the unstable runtime dependency.

**Alternatives considered:**

- Recompute source labels on every refresh from Encounter Journal globals. Rejected by experiment.
- Add a new enrichment pass that re-queries Encounter Journal after every loot event. Rejected as another form of live coupling.

**Design details:**

- `AdventureGuideUI.lua` and `SetTrackedFromItemData()` remain responsible for capturing `sourceLabel`, `instanceID`, and `encounterID` when available.
- Existing tracked items with missing source metadata continue to fall back to `Other` until refreshed by explicit tracking or future safe enrichment work.

### Decision 3: Loot-event handling must not index secret loot-message strings directly

**Choice:** Treat `CHAT_MSG_LOOT` payloads as taint-sensitive boundaries. The addon must avoid direct unsafe string indexing on event payloads that can arrive as secret values.

**Rationale:**

- The observed `LootEvents.lua:80` failure proves that `message:match(...)` can be blocked on secret strings.
- Even when this error does not poison later tooltips, it still breaks the addon and confirms the loot-event path is unsafe.
- The loot-awareness feature only needs normalized item identity and looter information, not a permanent dependence on raw event strings.

**Alternatives considered:**

- Keep pattern-matching the chat payload and hope the earlier tracker fix removes the symptom. Rejected because the Lua error is already independently reproducible.
- Disable tracked-loot alerts entirely. Rejected because the spec still requires other-player tracked-item loot awareness.

**Design details:**

- Loot-event processing will be refactored so secret payloads are normalized at a safe boundary before later alert logic runs.
- The queue and alert renderer will consume addon-owned normalized records only.
- The implementation may use a different loot-event source or a safer extraction path if `CHAT_MSG_LOOT` cannot be reliably normalized without touching secret strings directly.

### Decision 4: Encounter-rank priming and boss metadata are allowed only if they do not require live source-label fallback

**Choice:** Keep encounter-rank priming and boss metadata behavior for now, because experiments with those paths restored remained stable once the live source-label lookup stayed disabled.

**Rationale:**

- This preserves current raid tracker presentation without over-scoping the fix.
- The reverted experiment restored encounter-rank priming and boss metadata while keeping only live source-label lookup disabled, and the addon remained stable.
- The evidence points to source-label fallback as the dominant persistent tooltip-corruption trigger.
- Keeping the narrower change lowers regression risk.

**Alternatives considered:**

- Remove all Encounter Journal reads from the addon. Rejected as broader than needed for the root cause that was isolated.
- Leave boss metadata disabled permanently. Rejected because current experiments do not justify that user-facing regression.

**Design details:**

- Boss-name and encounter-rank logic stay in place unless implementation testing proves they still contribute after the source-label fix lands.
- If later validation shows they still taint the addon, they can be moved into a follow-up safe-cache design rather than remaining in tracker rebuild.

### Decision 5: Remove direct Encounter Journal opening from tracker source headers

**Choice:** Tracker source-group headers will no longer open the Encounter Journal directly.

**Rationale:**

- Isolation testing showed the remaining persistent `MoneyFrame_Update` tooltip taint can be reproduced by tracker-driven `EncounterJournal_OpenJournal(nil, instanceID)` even when loot popups and Adventure Guide checkbox integration are disabled.
- Manual Encounter Journal opening remained stable in the same sessions, which strongly implicates the tracker-triggered journal-open path rather than the Journal itself.
- Removing the unsafe deep link is safer than trying to preserve a convenience interaction that appears to taint Blizzard-owned tooltip state.

**Alternatives considered:**

- Keep tracker header navigation and only remove the forced loot-tab click. Rejected because the bug still reproduced once only `EncounterJournal_OpenJournal(nil, instanceID)` remained.
- Preserve the feature behind combat-only or loot-only guards. Rejected because the reproduced bug is tied to the direct journal-open call, not just combat timing.

**Design details:**

- Tracker source-group headers remain visible group labels, but they no longer invoke Adventure Guide or Encounter Journal navigation on click.
- Collapse-button behavior remains unchanged.
- Hover styling that implies the group label is clickable is removed.

### Decision 6: Header add and completion feedback mirrors native Objective Tracker motion without inheriting Blizzard block templates

**Choice:** Source-group headers will use a local glow animation that matches Blizzard's Objective Tracker visual language instead of directly inheriting Blizzard animation template objects.

**Rationale:**

- The addon's tracker rows are custom frames rather than Blizzard objective tracker block template instances.
- Reusing Blizzard atlases, timing, and glow behavior preserves the native look without forcing the addon into Blizzard's block-template hierarchy.
- A local animation is simpler to attach to source-group rows and avoids unnecessary coupling to Blizzard block internals.

**Alternatives considered:**

- Inherit Blizzard Objective Tracker animation block templates directly. Rejected because the wishlist tracker is not built as a native block-template instance and would require a broader UI refactor.
- Use a fully custom non-Blizzard animation style. Rejected because the goal is to match native tracker feedback.

**Design details:**

- The header glow uses Blizzard's objective-tracker glow atlas and timing-inspired alpha behavior.
- Source-group headers play a local add-style glow when an item first appears in that group.
- Source-group headers play a local completion-style glow when an item in that group newly gains the completed or possessed state.

## Risks / Trade-offs

- **Risk: Older tracked items may lose dungeon/raid grouping if they were saved without source metadata.** → Mitigation: fall back cleanly to `Other` and preserve grouping for all newly tracked items with stored metadata.
- **Risk: Loot-event hardening may require changing how other-player loot is detected.** → Mitigation: keep the user-facing alert behavior fixed in the specs while allowing implementation freedom in the event source.
- **Risk: Boss metadata could still hide a smaller taint issue that the current experiments did not hit.** → Mitigation: validate the final implementation with the same dungeon-run reproductions used in the investigation.
- **Risk: Persisted source labels can become stale if Blizzard renames content.** → Mitigation: accept stored labels as the stable grouping contract for now; stale labels are less harmful than runtime taint.
- **Risk: Removing tracker-header Journal navigation is a user-facing regression.** → Mitigation: preserve grouping, collapse behavior, and manual Journal workflows; document the safety rationale in specs so the trade-off is explicit.

## Migration Plan

1. Revert the temporary experiment code and start from the original implementation.
2. Update tracker grouping so it uses persisted `sourceLabel` only, with `Other` fallback and no live `GetCurrentSourceLabel(nil)` lookup during rebuild.
3. Keep encounter-rank priming and boss metadata behavior unchanged initially.
4. Refactor loot-event handling so raw secret `CHAT_MSG_LOOT` payloads are not indexed unsafely and only normalized addon-owned records flow into later alert logic.
5. Remove direct tracker-driven Encounter Journal opening and any clickable styling tied to that behavior.
6. Re-run the same dungeon/loot/Adventure Journal reproduction scenarios used during investigation, including manual Journal opening versus tracker interaction.
7. If tooltip corruption or secret-string errors persist, narrow further with taint logging before broadening scope.

Rollback strategy:

- The change is local to tracker grouping and loot-event handling, so rollback is simply restoring the prior code paths if validation unexpectedly regresses grouping or alert behavior.

## Open Questions

- What is the safest authoritative signal for other-player tracked-item loot if `CHAT_MSG_LOOT` strings cannot be relied on directly in all contexts?
- Do we need a future metadata backfill path for older tracked items that predate stored `sourceLabel`, or is `Other` fallback sufficient?
