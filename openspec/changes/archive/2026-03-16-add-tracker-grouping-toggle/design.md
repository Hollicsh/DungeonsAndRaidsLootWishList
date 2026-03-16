## Context

The tracker currently rebuilds a single source-grouped view from persisted wishlist entries, possession state, and resolved boss metadata. Group identity is effectively the rendered label, collapse state is stored by label alone, and tracker-row tooltips intentionally remain Blizzard-native with no addon-specific footer content.

This change introduces a second grouping mode, `Equipment Slot`, while keeping `Loot Source` as the default. That makes tracker state no longer one-dimensional: the tracker must preserve which grouping mode is active, keep collapse state isolated per grouping mode, and expose the opposite axis of information in the tooltip footer. The change also touches several module boundaries at once: persistence in `WishlistStore.lua`, grouping resolution in `SourceResolver.lua`, model shaping in `TrackerModel.lua`, orchestration in `LootWishList.lua`, Adventure Guide checkbox normalization in `AdventureGuideUI.lua`, and header/tooltip rendering in `TrackerUI.lua`.

The addon also has a hard security constraint. The wishlist tracker is intentionally implemented as a side-car frame appended beneath the native Objective Tracker rather than as a Blizzard tracker module. The new header control and tooltip footer must preserve that isolation, avoid shared-tooltip contamination, and avoid combat-unsafe interaction with Blizzard-owned tracker state.

## Goals / Non-Goals

**Goals:**
- Allow the player to switch the wishlist tracker between `Loot Source` and `Equipment Slot` grouping from the tracker header.
- Persist the active grouping mode per character and restore it across reloads and sessions.
- Keep collapse state stable and isolated per grouping mode so source-group collapses do not affect slot-group collapses.
- Persist or backfill the item metadata needed to build both grouping modes and both tooltip footer variants without depending on live Encounter Journal state during ordinary tracker refreshes.
- Keep source mode behavior familiar: source groups remain top-level groups and raid sources continue to show boss subheaders.
- Keep slot mode simple: slot groups render a flat list with no nested source or boss subheaders.
- Show a tracker-only tooltip footer only in slot mode, separated from the base tooltip by a spacer line: `Drops from: <Instance Name>` or `Drops from: <Instance Name> - <Boss Name>`.
- Preserve the addon's side-car Objective Tracker architecture and taint-safe interaction patterns.
- Preserve Adventure Guide checkbox add/remove behavior while item normalization and raid-source detection evolve.

**Non-Goals:**
- Changing wishlist membership semantics or stable item identity.
- Replacing the side-car tracker with Blizzard tracker-module registration.
- Adding a generic settings panel for tracker grouping outside the tracker header itself.
- Introducing nested grouping in slot mode.
- Using live Encounter Journal selection state to rebuild tracker grouping or tooltip metadata during normal bag, bank, loot, or combat-exit refreshes.

## Decisions

### 1. Persist tracker presentation state separately from item state

The character record in `WishlistStore.lua` should gain a tracker-scoped state container rather than continuing to bolt presentation concerns onto the item map.

Proposed shape:
- `character.tracker.groupBy = "source" | "slot"`
- `character.tracker.collapsedGroupsByMode.source[groupKey] = true`
- `character.tracker.collapsedGroupsByMode.slot[groupKey] = true`

Rationale:
- `groupBy` is character-specific presentation preference, not item metadata.
- per-mode collapse maps prevent collisions between equally named groups in different modes.
- this keeps item state minimal while still preserving legitimate tracker state across sessions.

Alternatives considered:
- Reuse the current `collapsedGroups[label]` map. Rejected because labels are display values, not stable identities, and would leak collapse state across modes.
- Store grouping mode in transient addon state only. Rejected because the proposal explicitly requires session persistence.

### 2. Persist stable slot identity, not localized slot text

Wishlist entries should persist stable non-UI slot metadata such as `inventoryType = "INVTYPE_HEAD"` whenever it can be resolved from Adventure Guide data or item info backfill.

Rationale:
- stable inventory tokens survive locale changes and can drive both grouping keys and localized display labels.
- slot grouping should not rely on hover-time `GetItemInfo` calls or live Encounter Journal state to determine where an item belongs.
- the tooltip footer for source mode also depends on slot identity being available from persisted metadata.

Alternatives considered:
- Persist localized slot labels directly. Rejected because localized labels are presentation data and are unsuitable as durable state or collapse keys.
- Resolve slot only at tracker-build time from live item APIs. Rejected because item-cache misses would create inconsistent grouping and tooltip behavior.

### 3. Expand `SourceResolver.lua` into tracker-group resolution, but keep it data-only

Although the file is named `SourceResolver.lua`, it is the narrowest current home for deciding the grouping identity of a tracked item. It should evolve to resolve grouping metadata for both modes while remaining UI-agnostic.

Expected responsibilities:
- resolve source grouping metadata: stable group key, label, and grouping kind
- resolve slot grouping metadata: stable group key, label, and grouping kind
- provide fallback groups for missing source or missing slot metadata

Rationale:
- grouping logic belongs in a pure data module, not in `TrackerUI.lua`.
- keeping mode-specific grouping resolution together avoids duplicating fallback behavior in `LootWishList.lua` and `TrackerModel.lua`.
- this preserves the architectural rule that tracker rendering should consume prepared group/model data rather than invent grouping rules on the fly.

Alternatives considered:
- Put slot grouping logic into `TrackerModel.lua`. Rejected because that would couple grouping resolution with row-shaping and flattening.
- Rename the module immediately. Deferred to keep the change small and reversible.

### 4. Give tracker groups a stable `key` separate from `label`

`TrackerModel.buildGroups` should stop treating the rendered label as the durable identity of a group. Each group should carry at least:
- `key` - stable collapse/identity key, e.g. `source:theater-of-pain` or `slot:INVTYPE_HEAD`
- `label` - localized display label
- `mode` - `source` or `slot`

Rationale:
- stable keys are required for per-mode collapse persistence.
- animation bookkeeping and row identity become less fragile when tied to durable keys instead of display strings.
- display labels can change across locale or formatting without invalidating saved collapse state.

Alternatives considered:
- Use label plus mode as an ad hoc compound key only inside `TrackerUI.lua`. Rejected because identity would remain implicit and spread across layers.

### 5. Keep source mode hierarchical and slot mode flat

The current source mode already supports raid-specific boss subheaders. That behavior should remain in place only for source-grouped rendering. Slot mode should render a flat list of items within each slot group.

Rationale:
- source mode answers "where does it drop?" and benefits from raid boss structure.
- slot mode answers "which slot am I chasing?" and becomes noisy if it adds a second nesting axis.
- this keeps the mental model crisp and matches the user's decision.

Alternatives considered:
- Add boss or source subheaders under slot groups. Rejected as unnecessary complexity for the first version.

### 6. Make tooltip footer slot-mode-only and tracker-owned

Tracker-row hover should continue to use the dedicated tracker tooltip frame rather than a shared Blizzard tooltip. After the normal item content is populated, the tracker tooltip may append a spacer line and then exactly one addon-specific footer line derived from persisted metadata.

Footer rules:
- source mode -> no addon-specific footer line
- slot mode, dungeon or unknown non-raid source -> `Drops from: <Instance Name>`
- slot mode, raid source with known boss -> `Drops from: <Instance Name> - <Boss Name>`

Rationale:
- the dedicated tooltip surface is already the safest place to customize tracker-only tooltip output.
- appending a single line after item population is substantially safer than hooking shared tooltip pipelines globally.
- using persisted metadata avoids hover-time dependence on live Encounter Journal APIs, which are both fragile and a taint risk if tied to Blizzard-owned flows.

Alternatives considered:
- Keep tooltips purely Blizzard-native. Rejected because the proposal now explicitly adds cross-axis context as part of the user experience.
- Hook shared `GameTooltip` globally based on item identity. Rejected because it broadens taint and behavioral risk far beyond tracker rows.

### 7. Use a simple addon-owned header toggle instead of Blizzard dropdown patterns

The tracker header control should be implemented as a lightweight addon-owned control embedded in the side-car header, such as a compact text button or two-state toggle, rather than a Blizzard dropdown, settings flyout, or injected control on Blizzard-owned tracker frames.

Rationale:
- the side-car frame is addon-owned and already outside Blizzard's module manager.
- simple buttons have a small event surface and are easier to reason about during combat and tracker refreshes.
- dropdowns and shared menu systems create more interaction with Blizzard-owned UI state than this change requires.

Alternatives considered:
- A Blizzard-style dropdown menu. Rejected due to higher complexity and greater taint sensitivity.
- A hidden slash command or config-only toggle. Rejected because the requirement is explicitly for a header UI element.

### 8. Keep Adventure Guide checkbox tracking resilient to new normalization paths

The Adventure Guide checkbox click path should continue to hand normalized item data into `LootWishList.lua` without depending on helper declaration order or tracker-specific metadata already being present.

Rationale:
- the checkbox path is the primary way players add wishlist items from Encounter Journal loot rows.
- grouping-mode and tooltip metadata changes should not break add/remove interactions in `AdventureGuideUI.lua`.
- keeping the normalization path resilient avoids regressions caused by local helper ordering or newly added metadata fields.

## Risks / Trade-offs

- [Incomplete slot metadata on old wishlist entries] -> Add a targeted backfill path that resolves stable slot identity out of combat and tolerates missing values by placing items in an `Other` slot group until metadata is known.
- [Collapse-state migration breaks existing collapsed source groups] -> Migrate the legacy `collapsedGroups` map into `tracker.collapsedGroupsByMode.source` on first load and preserve current source-group collapse behavior.
- [Tooltip customization contaminates shared tooltip behavior] -> Restrict footer additions to the dedicated tracker tooltip instance only; do not hook global tooltip events or shared Blizzard tooltip surfaces.
- [Header toggle causes tracker taint or combat issues] -> Keep the control fully addon-owned, avoid Blizzard dropdown APIs, and only mutate the addon's side-car frame during toggle handling.
- [Mode switching creates unstable row animations or stale keys] -> Move animation and known-row bookkeeping from display labels to stable group keys.
- [Localized slot display differs from persisted token] -> Treat persisted inventory type as the source of truth and derive labels from localized item class/equip-location APIs only at render time.

## Migration Plan

1. Extend character saved variables to include tracker-scoped grouping state and per-mode collapse maps while retaining compatibility with existing item entries.
2. During migration, move any legacy source-group collapse state into the new source-mode collapse map.
3. Backfill persisted item metadata needed for slot grouping and slot tooltip text, preferring out-of-combat or login-time work rather than hover-time resolution.
4. Update tracker rebuild orchestration to pass grouping mode into grouping resolution and tracker-model shaping.
5. Update tracker UI to render the header toggle, use stable group keys for collapse and animations, and append the mode-aware tooltip footer on the dedicated tracker tooltip.
6. If rollback is needed, ignore the new tracker-scoped fields and fall back to source grouping as the implicit default; the additional metadata is additive and should not invalidate old entries.

## Open Questions

- None at this time. The intended tooltip symmetry and slot-mode flat-list behavior have been decided for this change.
