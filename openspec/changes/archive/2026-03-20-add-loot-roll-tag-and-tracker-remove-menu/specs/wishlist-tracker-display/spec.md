## MODIFIED Requirements

### Requirement: Tracker rows support direct removal

The addon SHALL allow the user to remove a tracked item from the wishlist from the objective tracker by either Shift-clicking that item row or right-clicking that item row to open a context menu with only one action, `Remove`.

#### Scenario: Shift-click removes a tracked item
- **WHEN** the user Shift-clicks a tracked item in the `Loot Wishlist` section
- **THEN** the addon removes the item from the active character's wishlist and updates the tracker accordingly

#### Scenario: Right-click opens remove menu for a tracked item
- **WHEN** the user right-clicks a tracked item in the `Loot Wishlist` section
- **THEN** the addon opens a context menu for that row
- **AND** the menu contains only one action named `Remove`

#### Scenario: Remove menu action removes a tracked item
- **WHEN** the user activates `Remove` from a tracked item's right-click context menu in the `Loot Wishlist` section
- **THEN** the addon removes the item from the active character's wishlist and updates the tracker accordingly

#### Scenario: Group and boss headers do not show remove menu
- **WHEN** the user right-clicks a group header or boss subheader in the `Loot Wishlist` section
- **THEN** the addon does not open the tracked-item remove menu
