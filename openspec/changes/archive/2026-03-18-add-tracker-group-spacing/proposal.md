## Why

Wishlist tracker groups currently render as one continuous block of rows, which makes adjacent groups harder to scan at a glance. Adding a small fixed gap between top-level groups improves readability without making the items inside each group feel loose or noisy.

## What Changes

- Add a fixed 5px vertical gap between top-level groups in the `Loot Wishlist` objective tracker section.
- Preserve the existing tight row spacing within each group, including raid boss subheaders and item rows.
- Apply the same top-level group spacing in both `Loot Source` and `Equipment Slot` grouping modes, including when groups are collapsed.

## Capabilities

### New Capabilities

### Modified Capabilities

- `wishlist-tracker-display`: refine tracker group layout so top-level groups have a visible gap between them while rows within the same group remain tightly stacked.

## Impact

- Affects tracker layout behavior in `TrackerUI.lua`.
- Refines the rendering contract for `openspec/specs/wishlist-tracker-display/spec.md`.
- No saved-variable, Adventure Guide, or loot-event behavior changes are expected.
