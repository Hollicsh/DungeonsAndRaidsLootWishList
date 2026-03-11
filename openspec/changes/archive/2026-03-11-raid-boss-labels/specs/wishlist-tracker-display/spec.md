## MODIFIED Requirements

### Requirement: Tracker rows show current possession and best looted item level separately

The addon SHALL show a green tick for a tracked item only when the active character currently possesses any version of that item in equipped slots, bags, or bank when bank data is known. The addon SHALL append the highest remembered looted item level in parentheses when that value is known, even if the item is not currently possessed. If the item's source is identified as a raid, the addon SHALL organize items hierarchically by boss: each boss appears as a gray section header followed by items belonging to that boss, sorted by encounter order within the raid. Items display the item name and item level (if known) without the boss name inline. Hovering a tracked item row SHALL show the standard Blizzard item tooltip for that row using the game's default tooltip anchor behavior, with no addon-specific tooltip lines. When a best owned item link is available, the tracker row SHALL use that link for display styling instead of an older tracked journal link.

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

#### Scenario: Hover tracked item row shows default item tooltip

- **WHEN** the user hovers a tracked item row in the `Loot Wishlist` section and the addon can resolve that item
- **THEN** the standard Blizzard item tooltip is shown using the game's default tooltip anchor behavior without addon-specific tooltip text

#### Scenario: Tracked items from a raid are grouped by boss

- **WHEN** the addon resolves tracked items' source as a raid and successfully determines encounter boss names
- **THEN** the objective tracker displays a gray section header for each boss followed by items belonging to that boss, sorted by encounter order (e.g., Boss A header → items from Boss A, Boss B header → items from Boss B)

#### Scenario: Tracked item from a dungeon does not show boss header

- **WHEN** the addon resolves a tracked item's source as a dungeon (not a raid)
- **THEN** the objective tracker displays items in a flat list without boss headers, showing only the item name and item level.
