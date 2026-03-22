## MODIFIED Requirements

### Requirement: Tracker rows show the standard Blizzard item tooltip on hover

When the user hovers a tracked item row in the `Loot Wishlist` section, the addon SHALL show that item's standard Blizzard item tooltip. When the hovered item supports equipped-item comparison, the addon SHALL also show addon-owned equipped comparison tooltips from the tracker-dedicated tooltip surface, styled to match Blizzard compare panes.

#### Scenario: Hover tracked row with a resolved item reference

- **WHEN** the user hovers a tracked item row and the addon can resolve an item reference for that row
- **THEN** the standard Blizzard item tooltip is shown for that item

#### Scenario: Hover tracked row with no resolved item reference

- **WHEN** the user hovers a tracked item row and the addon cannot resolve a usable item reference
- **THEN** the addon does not show custom fallback tooltip text

#### Scenario: Hover equippable tracked row shows equipped comparison

- **WHEN** the user hovers a tracked item row with a resolved item reference and the item supports equipped-item comparison
- **THEN** the tracker tooltip shows the item together with addon-owned equipped comparison tooltips styled to match Blizzard compare panes

#### Scenario: Leaving tracked row hides comparison panes

- **WHEN** the user stops hovering a tracked item row whose tooltip is showing equipped comparison
- **THEN** the addon hides the tracker tooltip and any comparison panes associated with that row

### Requirement: Tooltip content remains purely Blizzard-native

In `Loot Source` mode, the addon SHALL NOT inject wishlist-specific lines, labels, markers, or footer text into the tooltip shown from tracker rows. In `Equipment Slot` mode, the addon SHALL append a spacer line followed by exactly one wishlist-specific footer line to the tracker-row tooltip when persisted drop-source metadata is available. That footer line SHALL read `Drops from: <Instance Name>` for dungeon items or non-raid items, and `Drops from: <Instance Name> - <Boss Name>` for raid items with a known boss name. When equipped comparison tooltips are shown, addon-specific footer text MUST remain on the primary tracker tooltip only.

#### Scenario: Source mode tooltip has no addon-specific footer

- **WHEN** the addon shows an item tooltip from a tracked row while the active tracker grouping mode is `Loot Source`
- **THEN** the tooltip contents remain the standard Blizzard item tooltip without addon-specific text additions

#### Scenario: Slot mode tooltip shows dungeon drop source

- **WHEN** the addon shows an item tooltip from a tracked row while the active tracker grouping mode is `Equipment Slot`
- **AND** the tracked item has persisted dungeon or non-raid source metadata with a known instance name
- **THEN** the tooltip appends a spacer line and then the line `Drops from: <Instance Name>`

#### Scenario: Slot mode tooltip shows raid drop source and boss

- **WHEN** the addon shows an item tooltip from a tracked row while the active tracker grouping mode is `Equipment Slot`
- **AND** the tracked item has persisted raid source metadata with a known instance name and boss name
- **THEN** the tooltip appends a spacer line and then the line `Drops from: <Instance Name> - <Boss Name>`

#### Scenario: Slot mode tooltip skips footer when drop source is unknown

- **WHEN** the addon shows an item tooltip from a tracked row while the active tracker grouping mode is `Equipment Slot`
- **AND** the tracked item does not have persisted drop-source metadata needed to produce the footer text
- **THEN** the addon does not append misleading fallback footer text

#### Scenario: Comparison tooltips stay visually Blizzard-like in slot mode

- **WHEN** the addon shows equipped comparison for a tracked row while the active tracker grouping mode is `Equipment Slot`
- **THEN** the wishlist footer appears only on the primary tracker tooltip and the comparison tooltips do not add wishlist-specific footer text
