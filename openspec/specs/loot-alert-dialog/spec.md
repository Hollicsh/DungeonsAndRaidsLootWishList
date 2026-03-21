# Loot Alert Dialog

## Purpose

Define the addon-owned popup surface, interaction model, and message formatting for tracked-item loot alerts.

## Requirements

### Requirement: Loot Alert Dialog Configuration

The system SHALL present an addon-owned tracked-loot alert popup for tracked items looted by another player. The popup MUST preserve a StaticPopup-like user experience while remaining fully addon-owned, including the player-name text, item icon, item name, item tooltip on hover, a single `OK` dismissal action, Escape-key dismissal, and NO timeout.

#### Scenario: Displaying the Alert Dialog

- **WHEN** the tracked-item alert dialog is shown
- **THEN** it displays the text prompt, the item icon, the item name, an interactive item presentation for the tracked item, and waits indefinitely for the user to click `OK` or dismiss it with Escape

#### Scenario: Deferred display preserves the same dialog experience

- **WHEN** the dialog is shown after being deferred until a safe UI state
- **THEN** it presents the same text, item presentation, and dismissal behavior as an immediately shown alert dialog

#### Scenario: Hovering the alert item shows a tooltip

- **WHEN** the tracked-item alert dialog is shown and the user hovers the item presentation
- **THEN** the popup shows the tooltip for the alerted item

### Requirement: Loot Alert Dialog Formatting

The system SHALL format the alert message text to be white (`|cFFFFFFFF`), and the looting player's name SHALL be highlighted in a distinct orange color (`|cFFFF8000`) to stand out. This formatting requirement SHALL remain the same whether the dialog is shown immediately or reconstructed later from normalized addon-owned alert data.

#### Scenario: Highlighting the Player Name

- **WHEN** the active character receives a loot alert for another player
- **THEN** that player's name is rendered in the distinct alert color within the dialog text

#### Scenario: Deferred alert preserves message formatting

- **WHEN** the addon shows a previously deferred loot alert
- **THEN** the dialog still renders white body text and the player's name in the distinct alert color
