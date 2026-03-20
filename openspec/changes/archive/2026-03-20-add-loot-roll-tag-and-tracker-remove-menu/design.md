## Context

The addon already annotates tracked loot roll frames in `LootEvents.lua` and already owns tracker item-row interactions in `TrackerUI.lua`. The requested change stays within those existing module boundaries, but it crosses two UI surfaces with different constraints: loot roll frames are transient Blizzard templates that the addon decorates, while tracker rows are addon-owned controls rendered beside the Objective Tracker.

The loot roll change is purely presentational: the existing `Wishlist` label needs a banker-style icon to improve recognition speed. The tracker change is interactive: tracked item rows currently support Shift-click removal, and the new right-click menu adds a more discoverable removal path. Because this addon has a history of tooltip and tracker taint issues, the design must preserve side-car tracker isolation and prefer Blizzard's newer native context-menu system, while keeping a compatibility fallback if that API is unavailable on the running client.

## Goals / Non-Goals

**Goals:**
- Add a small icon to the tracked-item loot roll badge without changing wishlist persistence or loot matching behavior.
- Add a right-click remove interaction for tracker item rows while preserving existing Shift-click removal.
- Prefer Blizzard-native assets and helper APIs where the risk is acceptable.
- Keep interaction logic scoped to addon-owned row and badge surfaces.

**Non-Goals:**
- Redesign the tracker layout, row spacing, or loot roll frame composition beyond the requested badge change.
- Remove or replace the existing Shift-click tracker removal shortcut.
- Introduce multi-action context menus, confirmation dialogs, or bulk wishlist actions.
- Rework tracker grouping, tooltips, or saved-variable shape.

## Decisions

### 1. Extend the loot roll tag into a compact badge widget

The current loot roll annotation is a standalone font string. The change should convert that presentation into a small addon-owned badge made of an icon texture plus the localized `Wishlist` text anchored to the existing loot roll frame. The badge icon should use the Blizzard atlas `Banker`. The implemented badge may tune spacing, offset, and glow presentation around that atlas as long as the result remains a compact tracked-item marker on the native roll frame.

Rationale:
- The icon needs a stable anchor relative to the text, which is easier with a dedicated badge container than with a lone font string.
- The change remains local to `LootEvents.lua`, which already owns tracked loot roll frame decoration.
- A compact badge keeps the existing visual footprint and avoids changing roll button behavior.

Alternatives considered:
- Add a second free-floating texture beside the existing font string. Rejected because it creates looser layout coupling on transient roll frames.
- Ship a custom icon asset. Rejected in favor of the Blizzard-native `Banker` atlas.

### 2. Keep tracker right-click handling on item rows only

The new menu interaction should attach only to actual tracked item rows, not group headers or boss subheaders.

Rationale:
- `TrackerUI.lua` already distinguishes item rows from headers inside `renderItemRow`.
- Restricting the handler to item rows avoids conflicting with group-collapse interactions and keeps the interaction model predictable.
- This preserves informational header behavior established by the existing tracker spec.

Alternatives considered:
- Add right-click on all tracker rows. Rejected because group and boss rows are not removable items.
- Replace left-click behavior with the context menu. Rejected because Shift-click removal should remain available as the fast path.

### 3. Prefer Blizzard's newer context menu API, with a legacy dropdown fallback

The primary implementation path should use Blizzard's newer `MenuUtil.CreateContextMenu` API to show a single-entry `Remove` menu on tracker item-row right-click. If that API is unavailable on the running client, the addon may fall back to a legacy dropdown-helper path that preserves the same visible behavior. If either native path produces taint or action-forbidden behavior, the implementation should be free to switch to a tiny addon-owned menu without changing the user-facing spec.

Rationale:
- The user wants a Blizzard-native menu appearance, and the newer context-menu system better matches current Blizzard UI than the older dropdown template.
- A single-action menu maps naturally onto `MenuUtil.CreateContextMenu`.
- The spec requirement is the visible behavior, not the menu implementation detail, so fallback remains possible if API availability or runtime behavior varies.

Alternatives considered:
- Use the older `UIDropDownMenu` or `EasyMenu` path as the primary implementation. Rejected because its visuals do not match the thinner modern Blizzard context menu and its helper availability can vary by client environment.
- Build an addon-owned one-button menu immediately. Rejected for now because it adds more code before evidence that the native menu paths are unsafe.
- Skip the menu and rely only on Shift-click. Rejected because the request is explicitly for a discoverable right-click menu.

### 4. Route all remove actions through the existing tracker removal path

The new menu action should invoke the same tracked-item removal path already used by Shift-click in `TrackerUI.lua` rather than introducing a second removal flow.

Rationale:
- One removal path reduces state drift and refresh inconsistencies.
- Existing behavior already knows how to remove an item and refresh tracker state.
- This keeps the change UI-focused instead of altering store semantics.

Alternatives considered:
- Add a new `RemoveTrackedItemFromMenu` helper. Rejected unless implementation details later show a strong need for a wrapper.

## Risks / Trade-offs

- [Blizzard native context menus or fallback dropdowns taint during combat or tracker refreshes] -> Validate with combat-time testing and `taint.log`; if issues appear, replace only the menu surface with a tiny addon-owned menu while keeping the same right-click `Remove` behavior.
- [Menu anchor target disappears during immediate tracker refresh after removal] -> Close the menu before or as part of the remove action and anchor it to the row or cursor in a way that tolerates the row being removed immediately after selection.
- [The `Banker` atlas is visually unclear at small size on the roll frame] -> Tune badge sizing and spacing around the fixed `Banker` atlas before considering any different presentation.
- [Right-click interaction is accidentally exposed on headers] -> Keep the menu wiring inside item-row rendering only and explicitly clear handlers on non-item rows.
