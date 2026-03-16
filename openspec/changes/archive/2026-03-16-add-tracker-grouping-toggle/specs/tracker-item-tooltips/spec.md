## MODIFIED Requirements

### Requirement: Tooltip content remains purely Blizzard-native
In `Loot Source` mode, the addon SHALL NOT inject wishlist-specific lines, labels, markers, or footer text into the tooltip shown from tracker rows. In `Equipment Slot` mode, the addon SHALL append a spacer line followed by exactly one wishlist-specific footer line to the tracker-row tooltip when persisted drop-source metadata is available. That footer line SHALL read `Drops from: <Instance Name>` for dungeon items or non-raid items, and `Drops from: <Instance Name> - <Boss Name>` for raid items with a known boss name.

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
