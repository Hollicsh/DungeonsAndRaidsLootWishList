## MODIFIED Requirements

### Requirement: Other-player tracked-item loot shows an addon-owned alert without changing local ownership state

When another player loots an item that matches the active character's tracked wishlist, the addon SHALL normalize the relevant alert data immediately into addon-owned values and SHALL show an addon-owned tracked-loot alert popup identifying the looting player and the item when the UI is in a safe state for dialog display. If the UI is already in a safe state, the alert MAY appear immediately. The popup SHALL preserve the current StaticPopup-style user experience while staying fully addon-owned, including player-name text, item icon, item name, dismiss interaction, and item tooltip on hover. The addon SHALL NOT change the active character's possession indicator or remembered best looted item level based on another player's loot. Loot-event handling SHALL process incoming loot payloads immediately at the event boundary rather than storing or replaying raw payloads later, SHALL use recent-self-loot correlation instead of comparing the reported looter name against the active player name, SHALL determine whether the `CHAT_MSG_LOOT` payload is safe to inspect before performing any string comparison or pattern matching on it, and SHALL NOT treat generic error suppression around unsafe payload parsing as an acceptable success path.

#### Scenario: Another player loots a tracked item while UI state is safe
- **WHEN** another player loots an item that matches one of the active character's tracked wishlist items and the UI is already in a safe state for dialog display
- **THEN** the addon shows the addon-owned tracked-loot alert popup naming the player and presenting the item

#### Scenario: Another player loots a tracked item during unsafe UI state
- **WHEN** another player loots an item that matches one of the active character's tracked wishlist items while the UI is not in a safe state for dialog display
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

#### Scenario: Secret or inaccessible loot-chat payload is rejected before parsing
- **WHEN** the relevant `CHAT_MSG_LOOT` payload is secret or inaccessible to the current caller
- **THEN** the addon rejects that event before any string comparison or pattern matching is attempted
- **AND** the addon does not queue or show a tracked-loot alert from that payload

#### Scenario: Unsafe payload does not become a hidden successful alert path
- **WHEN** the relevant loot event cannot be safely normalized into addon-owned values
- **THEN** the addon does not queue or show a tracked-loot alert from that unsafe payload
- **AND** the addon does not treat generic error suppression around unsafe parsing as a successful tracked-loot detection path
