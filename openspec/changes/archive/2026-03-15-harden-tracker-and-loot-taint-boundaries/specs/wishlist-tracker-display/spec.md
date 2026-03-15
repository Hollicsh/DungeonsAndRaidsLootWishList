## MODIFIED Requirements

### Requirement: Tracker items are grouped by loot source

The addon SHALL group tracked items in the objective tracker by persisted loot-source metadata already stored on the wishlist entry, such as the dungeon or raid where the item drops. Tracker grouping SHALL NOT depend on live Encounter Journal state during generic tracker rebuilds or post-loot refreshes. If no persisted loot source can be identified for a tracked item, the addon SHALL place that item under an `Other` group.

#### Scenario: Item with stored source is grouped under that source
- **WHEN** a tracked item has a stored dungeon or raid source on its wishlist entry
- **THEN** the objective tracker displays that item under a group named for that stored source

#### Scenario: Item with missing stored source falls back to Other
- **WHEN** a tracked item does not have persisted loot-source metadata on its wishlist entry
- **THEN** the objective tracker displays that item under the `Other` group

#### Scenario: Tracker rebuild does not consult live Encounter Journal state for grouping
- **WHEN** the addon rebuilds tracker groups after loot, bag, bank, equipment, or combat-state updates
- **THEN** tracker grouping is computed without depending on live Encounter Journal selection or title state

### Requirement: Source group headers open Adventure Guide loot view when clicked

The addon SHALL NOT open the Adventure Guide or Encounter Journal when the user clicks a source group header in the `Loot Wishlist` section. Source group headers remain informational labels for grouping only. Clicking the group's collapse or expand button SHALL continue to affect only collapse state.

#### Scenario: Click dungeon or raid group header does not open Encounter Journal
- **WHEN** the user clicks the left mouse button on a dungeon or raid source group header in the `Loot Wishlist` section
- **THEN** the Adventure Guide or Encounter Journal is not opened

#### Scenario: Click Other group header does nothing
- **WHEN** the user clicks the `Other` source group header in the `Loot Wishlist` section
- **THEN** the Adventure Guide or Encounter Journal is not opened

#### Scenario: Collapse button click still only changes collapse state
- **WHEN** the user clicks the collapse or expand button on a source group header
- **THEN** only the group's collapse state changes
- **AND** the Adventure Guide or Encounter Journal is not opened

### Requirement: Newly added tracker items mirror native tracker animation

When a tracked item is newly added to the `Loot Wishlist` section, the addon SHALL mirror the add-entry animation style used by the native objective tracker on the affected dungeon or raid source-group header. When a tracked item in a source group newly transitions into the completed or possessed state, the addon SHALL mirror the native tracker-style header glow animation on that same source-group header.

#### Scenario: Newly tracked item animates its source header
- **WHEN** the user adds an item to the wishlist and it appears in the objective tracker for the first time
- **THEN** the source-group header for that item plays a native objective-tracker style add animation

#### Scenario: Newly completed tracked item animates its source header
- **WHEN** a tracked item in a source group newly gains the completed or possessed tracker state
- **THEN** the source-group header for that item plays a native objective-tracker style completion glow animation
