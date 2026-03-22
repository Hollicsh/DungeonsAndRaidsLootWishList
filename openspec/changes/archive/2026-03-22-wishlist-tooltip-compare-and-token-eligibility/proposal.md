## Why

Wishlist item tooltips currently stop at the base item view, so players do not get the equipped-item comparison they expect from Blizzard item surfaces such as quest rewards.

## What Changes

- Add addon-owned equipped-item comparison tooltips to wishlist alert item tooltips, styled to match Blizzard compare tooltips while avoiding taint-prone shared tooltip paths.
- Add addon-owned equipped-item comparison tooltips to wishlist tracker row tooltips while preserving the existing tracker-specific anchor and footer rules.
- Preserve the current taint-safety posture by keeping comparison logic out of protected Blizzard compare/update paths.

## Capabilities

### New Capabilities
- None.

### Modified Capabilities
- `loot-alert-dialog`: change alert-item hover behavior so the dialog tooltip can show addon-owned equipped comparison tooltips that visually align with Blizzard compare panes.
- `tracker-item-tooltips`: change tracker-row hover behavior so tracker tooltips can show addon-owned equipped comparison tooltips while keeping the current anchor and footer behavior.

## Impact

- Affected code is expected to center on `WishListAlert.lua` and `TrackerUI.lua`.
- No saved-variable migration or tracker grouping changes are intended.
- The change depends on addon-owned comparison tooltip rendering backed by non-UI comparison/item data APIs.
- Taint risk must remain flat or lower by avoiding secure hooks and Objective Tracker integration changes.
