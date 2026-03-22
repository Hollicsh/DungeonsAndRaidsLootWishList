## MODIFIED Requirements

### Requirement: Loot Alert Dialog Configuration

The system SHALL present an addon-owned tracked-loot alert popup for tracked items looted by another player. The popup MUST preserve a StaticPopup-like user experience while remaining fully addon-owned, including the player-name text, item icon, item name, item tooltip on hover, a single `OK` dismissal action, Escape-key dismissal, and NO timeout. When the alerted item supports equipped-item comparison, hovering the alert item MUST show the alert tooltip together with addon-owned equipped comparison tooltips that visually align with Blizzard compare panes.

#### Scenario: Displaying the Alert Dialog

- **WHEN** the tracked-item alert dialog is shown
- **THEN** it displays the text prompt, the item icon, the item name, an interactive item presentation for the tracked item, and waits indefinitely for the user to click `OK` or dismiss it with Escape

#### Scenario: Deferred display preserves the same dialog experience

- **WHEN** the dialog is shown after being deferred until a safe UI state
- **THEN** it presents the same text, item presentation, and dismissal behavior as an immediately shown alert dialog

#### Scenario: Hovering the alert item shows a tooltip

- **WHEN** the tracked-item alert dialog is shown and the user hovers the item presentation
- **THEN** the popup shows the tooltip for the alerted item

#### Scenario: Hovering an equippable alert item shows equipped comparison

- **WHEN** the tracked-item alert dialog is shown and the user hovers an alerted item that supports equipped-item comparison
- **THEN** the popup shows the alert item's tooltip together with addon-owned equipped comparison tooltips styled to match Blizzard compare panes

#### Scenario: Leaving the alert item hides comparison panes

- **WHEN** the tracked-item alert dialog is showing equipped comparison for an alerted item
- **THEN** moving the pointer away from the item presentation or dismissing the dialog hides both the primary alert tooltip and any comparison panes
