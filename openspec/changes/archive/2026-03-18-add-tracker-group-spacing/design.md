## Context

The wishlist tracker currently renders top-level groups as a continuous stack of rows in `TrackerUI.lua`. The grouping model already produces clear top-level group boundaries, but the layout layer does not add any visual separation between one group's final row and the next group's header. This makes the tracker harder to scan when several source or slot groups are visible.

The change is intentionally presentational. It must preserve the current compact row rhythm within each group, including raid boss subheaders and item rows, while adding a fixed gap only between top-level groups. The existing tracker architecture already keeps this concern in the UI layout loop, so no data-model or persistence changes are needed.

## Goals / Non-Goals

**Goals:**
- Add a fixed 5px vertical gap between adjacent top-level groups in the wishlist tracker.
- Preserve existing spacing within each group, including boss headers, item rows, and collapsed-group rendering.
- Keep the change isolated to tracker layout code so grouping, persistence, and tooltip behavior remain unchanged.

**Non-Goals:**
- Do not change row height, typography, atlas usage, or header controls.
- Do not add configurable spacing or per-mode spacing values.
- Do not change how tracker groups are computed or persisted.

## Decisions

### Add spacing in the top-level group layout loop

The extra spacing will be applied in the `TrackerUI` render loop after a full top-level group block has been laid out. This keeps the behavior aligned with the existing responsibility split: `TrackerModel` defines group membership, while `TrackerUI` controls visual stacking.

Alternative considered: emitting spacer rows from `TrackerModel`.

This was rejected because spacing is presentation-only and would blur the boundary between model data and UI layout.

### Use a fixed tracker-local spacing constant

The gap will be represented as a tracker-specific constant near the existing row and header spacing constants. A fixed 5px value matches the requested behavior and avoids introducing configuration, saved state, or localization concerns.

Alternative considered: deriving the gap from row height or header height.

This was rejected because the requested behavior is an explicit visual separation, not a proportional spacing rule.

### Apply spacing only between top-level groups, never inside groups

The layout logic will add the 5px gap only when another top-level group follows. Items within a group, including raid boss headers and their child item rows, will continue to use the current tight row spacing. Collapsed groups will still receive the inter-group gap because they remain top-level group blocks.

Alternative considered: adding spacing before every group header.

This was rejected because it would also introduce unwanted leading space before the first group unless extra compensating logic were added.

## Risks / Trade-offs

- [Off-by-one layout math] -> Update content-height calculations through the same `yOffset` path already used for rows so the frame height naturally includes the new gap.
- [Accidental spacing inside raid subsections] -> Apply the gap only after the outer group loop completes, not while iterating `group.items`.
- [Visual mismatch with native tracker density] -> Keep the gap modest and limit it to top-level groups so the section remains compact overall.
