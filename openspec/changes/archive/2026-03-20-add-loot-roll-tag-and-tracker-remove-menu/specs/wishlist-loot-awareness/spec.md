## MODIFIED Requirements

### Requirement: Loot roll frames are tagged for tracked items

When a loot roll frame appears for a tracked item, the addon SHALL annotate that frame with a `Wishlist` badge so the player can recognize it immediately. The badge SHALL display the Blizzard atlas `Banker` to the left of the `Wishlist` label and SHALL keep both elements visible together as a single tracked-item marker on that loot roll frame.

#### Scenario: Loot roll for a tracked item appears
- **WHEN** a loot roll frame is shown for an item that matches the active character's wishlist
- **THEN** the frame displays a `Wishlist` badge

#### Scenario: Loot roll badge shows Banker atlas icon
- **WHEN** a loot roll frame is shown for an item that matches the active character's wishlist
- **THEN** the `Wishlist` badge includes the Blizzard atlas `Banker` positioned to the left of the `Wishlist` label
