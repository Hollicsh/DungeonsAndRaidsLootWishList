## ADDED Requirements

### Requirement: Tracker collapse controls play native checkbox-style sound feedback

The addon SHALL play the Blizzard menu checkbox-style sound when a user action changes the collapsed state of the surrogate tracker header, the `Loot Wishlist` header, or a tracker group header in the objective tracker.

#### Scenario: Surrogate header collapse plays sound
- **WHEN** the user clicks the surrogate tracker header to expand or collapse it
- **AND** that click changes the surrogate header's collapsed state
- **THEN** the addon plays the Blizzard menu checkbox-style sound once

#### Scenario: Loot Wishlist header collapse plays sound
- **WHEN** the user clicks the `Loot Wishlist` header to expand or collapse it
- **AND** that click changes the header's collapsed state
- **THEN** the addon plays the Blizzard menu checkbox-style sound once

#### Scenario: Group header collapse plays sound
- **WHEN** the user clicks a tracker group header collapse or expand control
- **AND** that click changes the group's collapsed state
- **THEN** the addon plays the Blizzard menu checkbox-style sound once

## MODIFIED Requirements

### Requirement: Tracker rows support direct removal

The addon SHALL allow the user to remove a tracked item from the wishlist from the objective tracker by either Shift-clicking that item row or right-clicking that item row to open a context menu with only one action, `Remove`. The right-click remove menu SHALL be rendered on an isolated addon-owned menu surface and SHALL NOT depend on shared Blizzard context-menu or dropdown menu systems.

#### Scenario: Shift-click removes a tracked item
- **WHEN** the user Shift-clicks a tracked item in the `Loot Wishlist` section
- **THEN** the addon removes the item from the active character's wishlist and updates the tracker accordingly

#### Scenario: Right-click opens remove menu for a tracked item
- **WHEN** the user right-clicks a tracked item in the `Loot Wishlist` section
- **THEN** the addon opens a context menu for that row
- **AND** the menu contains only one action named `Remove`

#### Scenario: Remove menu uses isolated addon-owned surface
- **WHEN** the user right-clicks a tracked item in the `Loot Wishlist` section
- **THEN** the remove menu is shown from an addon-owned isolated popup surface
- **AND** the interaction does not require shared Blizzard context-menu or dropdown menu systems

#### Scenario: Remove menu action removes a tracked item
- **WHEN** the user activates `Remove` from a tracked item's right-click context menu in the `Loot Wishlist` section
- **THEN** the addon removes the item from the active character's wishlist and updates the tracker accordingly

#### Scenario: Group and boss headers do not show remove menu
- **WHEN** the user right-clicks a group header or boss subheader in the `Loot Wishlist` section
- **THEN** the addon does not open the tracked-item remove menu
