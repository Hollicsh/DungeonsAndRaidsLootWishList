## MODIFIED Requirements

### Requirement: Tracker items are grouped by loot source
The addon SHALL group tracked items in the objective tracker according to the active persisted tracker grouping mode. In `Loot Source` mode, the addon SHALL group tracked items by persisted loot-source metadata already stored on the wishlist entry, such as the dungeon or raid where the item drops. In `Equipment Slot` mode, the addon SHALL group tracked items by persisted stable equipment-slot metadata stored on the wishlist entry. Tracker grouping SHALL NOT depend on live Encounter Journal state during generic tracker rebuilds or post-loot refreshes. If the metadata required for the active grouping mode cannot be identified for a tracked item, the addon SHALL place that item under an `Other` group for that mode.

#### Scenario: Source mode groups item under stored source
- **WHEN** the active tracker grouping mode is `Loot Source`
- **AND** a tracked item has a stored dungeon or raid source on its wishlist entry
- **THEN** the objective tracker displays that item under a group named for that stored source

#### Scenario: Source mode falls back to Other when source is missing
- **WHEN** the active tracker grouping mode is `Loot Source`
- **AND** a tracked item does not have persisted loot-source metadata on its wishlist entry
- **THEN** the objective tracker displays that item under the `Other` group

#### Scenario: Slot mode groups item under stored equipment slot
- **WHEN** the active tracker grouping mode is `Equipment Slot`
- **AND** a tracked item has persisted equipment-slot metadata on its wishlist entry
- **THEN** the objective tracker displays that item under a group named for that equipment slot

#### Scenario: Slot mode falls back to Other when slot metadata is missing
- **WHEN** the active tracker grouping mode is `Equipment Slot`
- **AND** a tracked item does not have persisted equipment-slot metadata on its wishlist entry
- **THEN** the objective tracker displays that item under the `Other` group for slot grouping

#### Scenario: Tracker rebuild does not consult live Encounter Journal state for grouping
- **WHEN** the addon rebuilds tracker groups after loot, bag, bank, equipment, or combat-state updates
- **THEN** tracker grouping is computed without depending on live Encounter Journal selection or title state

### Requirement: Source group headers open Adventure Guide loot view when clicked
The addon SHALL NOT open the Adventure Guide or Encounter Journal when the user clicks a group header in the `Loot Wishlist` section. Group headers in both `Loot Source` mode and `Equipment Slot` mode remain informational labels for grouping only. Clicking the group's collapse or expand button SHALL continue to affect only collapse state.

#### Scenario: Click source group header does not open Encounter Journal
- **WHEN** the user clicks the left mouse button on a source group header in `Loot Source` mode
- **THEN** the Adventure Guide or Encounter Journal is not opened

#### Scenario: Click slot group header does not open Encounter Journal
- **WHEN** the user clicks the left mouse button on an equipment-slot group header in `Equipment Slot` mode
- **THEN** the Adventure Guide or Encounter Journal is not opened

#### Scenario: Collapse button click still only changes collapse state
- **WHEN** the user clicks the collapse or expand button on a group header in either grouping mode
- **THEN** only the group's collapse state changes
- **AND** the Adventure Guide or Encounter Journal is not opened

### Requirement: Tracker rows show current possession and best looted item level separately
The addon SHALL show a green tick for a tracked item only when the active character currently possesses any version of that item in equipped slots, bags, or bank when bank data is known. The addon SHALL append the highest remembered looted item level in parentheses when that value is known, even if the item is not currently possessed. In `Loot Source` mode, if the item's source is identified as a raid, the addon SHALL organize items hierarchically by boss: each boss appears as a gray section header followed by items belonging to that boss, sorted by encounter order within the raid. In `Equipment Slot` mode, the addon SHALL display items in a flat list within each slot group with no nested boss or source subheaders. Wishlist tracker row hover SHALL use a tooltip surface isolated from shared Blizzard tooltip state so hovering wishlist rows does not interfere with Blizzard tooltip flows elsewhere. When a best owned item link is available, the tracker row SHALL use that link for display styling instead of an older tracked journal link.

#### Scenario: Tracked item is currently possessed
- **WHEN** the active character currently has any version of a tracked item equipped, in bags, or in known bank contents
- **THEN** the objective tracker row shows a green tick for that item

#### Scenario: Tracked item is no longer possessed
- **WHEN** the active character no longer has any version of a tracked item equipped, in bags, or in known bank contents
- **THEN** the objective tracker row does not show the green tick for that item

#### Scenario: Best looted item level remains after the item is gone
- **WHEN** the addon knows the highest looted item level for a tracked item but the character does not currently possess the item
- **THEN** the objective tracker still shows the item level in parentheses without the green tick

#### Scenario: Best owned version controls row styling
- **WHEN** the character owns a higher-quality or otherwise better version of a tracked item than the originally tracked journal link
- **THEN** the tracker row uses the best owned item link for display styling so row quality color matches the best known owned version

#### Scenario: Hover tracked item row shows isolated Blizzard-native tooltip
- **WHEN** the user hovers a tracked item row in the `Loot Wishlist` section and the addon can resolve that item
- **THEN** the row shows the standard Blizzard item tooltip anchored near that row

#### Scenario: Wishlist tracker hover does not break later Blizzard tooltips
- **WHEN** the user hovers a tracked item row and then hovers a Blizzard-owned item surface such as an Encounter Journal loot row
- **THEN** the Blizzard-owned surface still shows its normal tooltip behavior

#### Scenario: Source mode raid items are grouped by boss
- **WHEN** the active tracker grouping mode is `Loot Source`
- **AND** the addon resolves tracked items' source as a raid and successfully determines encounter boss names
- **THEN** the objective tracker displays a gray section header for each boss followed by items belonging to that boss, sorted by encounter order

#### Scenario: Source mode dungeon items stay flat within the source group
- **WHEN** the active tracker grouping mode is `Loot Source`
- **AND** the addon resolves a tracked item's source as a dungeon rather than a raid
- **THEN** the objective tracker displays items in a flat list within that source group without boss headers

#### Scenario: Slot mode items stay flat within the slot group
- **WHEN** the active tracker grouping mode is `Equipment Slot`
- **THEN** the objective tracker displays items in a flat list within each slot group without boss or source subheaders

### Requirement: Newly added tracker items mirror native tracker animation
When a tracked item is newly added to the `Loot Wishlist` section, the addon SHALL mirror the add-entry animation style used by the native objective tracker on the affected active group header. When a tracked item in a group newly transitions into the completed or possessed state, the addon SHALL mirror the native tracker-style header glow animation on that same active group header.

#### Scenario: Newly tracked item animates the active group header
- **WHEN** the user adds an item to the wishlist and it appears in the objective tracker for the first time
- **THEN** the active group header for that item plays a native objective-tracker style add animation

#### Scenario: Newly completed tracked item animates the active group header
- **WHEN** a tracked item in the active grouping mode newly gains the completed or possessed tracker state
- **THEN** the active group header for that item plays a native objective-tracker style completion glow animation

### Requirement: Source groups are collapsible
The wishlist tracker SHALL allow each visible group in the active grouping mode to be collapsed or expanded independently.

#### Scenario: Collapse a group in the active mode
- **WHEN** the user clicks the collapse button on a group header in the active grouping mode
- **THEN** that group's items are hidden from view
- **AND** the collapse button changes to expand button (showing +)
- **AND** the group header displays the item count in parentheses

#### Scenario: Expand a collapsed group in the active mode
- **WHEN** the user clicks the expand button on a collapsed group header in the active grouping mode
- **THEN** that group's items are displayed
- **AND** the expand button changes to collapse button (showing -)
- **AND** the group header displays just the group name without item count

#### Scenario: Collapse state persists across sessions for the active mode
- **WHEN** the user collapses a group and relogs or reloads the UI
- **THEN** the same group remains collapsed the next time that character views the tracker in that grouping mode

### Requirement: Adventure Guide wishlist checkboxes continue to track items
The addon SHALL continue to let the player add and remove wishlist items by clicking loot-row checkboxes in the Adventure Guide after grouping-mode, slot-metadata, and raid-detection changes are introduced.

#### Scenario: Clicking an unchecked loot-row checkbox adds the item
- **WHEN** the player clicks an unchecked wishlist checkbox on an Adventure Guide loot row
- **THEN** the item is added to the wishlist
- **AND** the tracker refreshes using the current grouping mode

#### Scenario: Clicking a checked loot-row checkbox removes the item
- **WHEN** the player clicks a checked wishlist checkbox on an Adventure Guide loot row
- **THEN** the item is removed from the wishlist
- **AND** the tracker refreshes using the current grouping mode

### Requirement: Item count displays for collapsed groups
When a group is collapsed in the active grouping mode, the group header SHALL display the number of tracked items in that group.

#### Scenario: Collapsed group shows count
- **WHEN** a group with 3 tracked items is collapsed and rendered
- **THEN** the header displays as "Group Name (3)"
