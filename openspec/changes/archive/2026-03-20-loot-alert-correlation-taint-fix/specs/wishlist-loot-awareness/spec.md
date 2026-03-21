## MODIFIED Requirements

### Requirement: Player loot updates remembered item level without a popup

When the active character loots a tracked item, the addon SHALL update the remembered best looted item level for that wishlist entry if the newly looted item level is higher than the stored value. The addon SHALL NOT show a tracked-loot popup for the active character's own tracked-item loot, and MAY suppress a simultaneous same-item other-player alert when the addon has just recorded recent self loot for that tracked item.

#### Scenario: Player loots a tracked item for the first time
- **WHEN** the active character loots a tracked item and no best looted item level has been stored yet
- **THEN** the addon stores that looted item level for the tracked item and does not show a tracked-loot popup

#### Scenario: Player loots a higher item-level version
- **WHEN** the active character loots a tracked item at a higher item level than the remembered value
- **THEN** the addon replaces the remembered best looted item level with the higher value and does not show a tracked-loot popup

#### Scenario: Simultaneous same-item local and remote loot suppresses popup
- **WHEN** the addon has just recorded recent self loot for a tracked item
- **AND** a tracked-loot alert candidate for that same tracked item arrives within the suppression window
- **THEN** the addon suppresses the popup for that alert candidate

### Requirement: Other-player tracked-item loot shows an addon-owned alert without changing local ownership state

When another player loots an item that matches the active character's tracked wishlist, the addon SHALL normalize the relevant alert data immediately into addon-owned values and SHALL show an addon-owned tracked-loot alert popup identifying the looting player and the item when the UI is in a safe state for dialog display. If the UI is already in a safe state, the alert MAY appear immediately. The popup SHALL preserve the current StaticPopup-style user experience while staying fully addon-owned, including player-name text, item icon, item name, dismiss interaction, and item tooltip on hover. The addon SHALL NOT change the active character's possession indicator or remembered best looted item level based on another player's loot. Loot-event handling SHALL process incoming loot payloads immediately at the event boundary rather than storing or replaying raw payloads later, SHALL use recent-self-loot correlation instead of comparing the reported looter name against the active player name, and SHALL NOT treat generic error suppression around unsafe payload parsing as an acceptable success path.

#### Scenario: Another player loots a tracked item while UI state is safe
- **WHEN** another player loots an item that matches one of the active character's tracked wishlist items and the UI is already in a safe state for alert display
- **THEN** the addon shows the addon-owned tracked-loot alert popup naming the player and presenting the item

#### Scenario: Another player loots a tracked item during unsafe UI state
- **WHEN** another player loots an item that matches one of the active character's tracked wishlist items while the UI is not in a safe state for alert display
- **THEN** the addon shows the addon-owned tracked-loot alert popup after the UI returns to a safe state

#### Scenario: Alert popup shows item icon and name
- **WHEN** the addon shows a tracked-loot alert popup
- **THEN** the popup displays the looted item's icon and item name

#### Scenario: Hovering alert item shows tooltip
- **WHEN** the addon shows a tracked-loot alert popup and the user hovers the popup's item presentation
- **THEN** the addon shows the item tooltip for the alerted item

#### Scenario: Another player's loot does not modify local state
- **WHEN** another player loots an item that matches one of the active character's tracked wishlist items
- **THEN** the addon does not change the active character's stored best looted item level or possession-derived green tick

#### Scenario: Self-loot suppression does not compare looter name
- **WHEN** the addon decides whether to suppress a tracked-loot popup for a tracked item
- **THEN** it uses recent-self-loot correlation instead of comparing the reported loot-event looter name against the active player name

#### Scenario: Loot-event processing normalizes data immediately
- **WHEN** the relevant loot event arrives for another player's tracked item loot
- **THEN** the addon derives the minimum item and player data immediately at the event boundary
- **AND** later alert queuing and display consume only the normalized addon-owned alert record

#### Scenario: Unsafe payload does not become a hidden successful alert path
- **WHEN** the relevant loot event cannot be safely normalized into addon-owned values
- **THEN** the addon does not queue or show a tracked-loot alert from that unsafe payload
- **AND** the addon does not treat generic error suppression around unsafe parsing as a successful tracked-loot detection path
