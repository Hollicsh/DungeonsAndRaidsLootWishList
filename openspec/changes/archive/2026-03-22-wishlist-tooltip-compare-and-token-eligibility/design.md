## Context

This change touches two existing tooltip surfaces:

- `WishListAlert.lua` owns the addon alert dialog and its dedicated alert tooltip.
- `TrackerUI.lua` owns the tracker row tooltip and the tracker-specific footer behavior in slot-grouped mode.

The addon currently shows standard item tooltips for alert and tracker hovers, but does not yet show equipped-item comparison alongside those addon-owned tooltip surfaces.

The change must preserve the current architectural boundaries from `AGENTS.md`: keep deterministic logic separate from WoW frame code, prefer Blizzard-native visual patterns where safe, and avoid changes that could increase taint risk in tracker- or tooltip-adjacent code.

## Goals / Non-Goals

**Goals:**
- Add addon-owned equipped-item comparison tooltips to wishlist alert tooltips.
- Add addon-owned equipped-item comparison tooltips to tracker row tooltips without changing their anchor or slot-mode footer behavior.
- Keep tooltip and alert behavior additive and low-risk with respect to taint.

**Non-Goals:**
- Changing wishlist tracking identity rules for normal gear or scaled item variants.
- Introducing new saved-variable fields or a migration for tracker data.
- Reworking Objective Tracker integration, anchors, or row layout.
- Building a brand new comparison UX that departs materially from Blizzard compare tooltip visuals.

## Decisions

### Use addon-owned comparison tooltips on existing dedicated tooltip surfaces

The addon will keep using its existing dedicated tooltip frames for the alert dialog and tracker rows, then show addon-owned equipped comparison tooltips beside the primary tooltip after the base item content is populated.

Rationale:
- This preserves the existing ownership model in `WishListAlert.lua` and `TrackerUI.lua` rather than switching to the shared global `GameTooltip`.
- Avoiding Blizzard's shared shopping tooltip manager reduces taint risk on addon-owned hover surfaces.
- The addon can still mirror Blizzard compare tooltip visuals closely enough to feel native without invoking the taint-prone secure compare path.

Alternatives considered:
- Use Blizzard's native shopping-tooltip comparison path on addon-owned tooltips: rejected because it taints shared Blizzard tooltip flows in this addon context.
- Use the global `GameTooltip`: rejected because it increases cross-surface coupling and makes it easier to interfere with Blizzard-owned tooltip usage.

### Preserve tracker-specific footer behavior on the primary tooltip only

Tracker row tooltips will continue to append the existing wishlist footer in slot-grouped mode only, and that footer will remain on the primary tooltip surface rather than being mirrored into addon-owned comparison tooltips.

Rationale:
- The current tracker spec already treats the footer as a tracker-owned addition layered onto the native item tooltip.
- Comparison tooltips should stay visually close to Blizzard compare panes and not carry addon-specific source text.
- This minimizes the amount of tooltip mutation introduced by the change.

Alternatives considered:
- Add the footer to comparison panes as well: rejected because it creates non-native behavior and complicates cleanup.
- Remove the footer when comparison is shown: rejected because it would regress existing tracker information.

### Centralize compare-tooltip lifecycle logic in a shared UI helper

The compare-item show/hide behavior should be expressed once and reused by the alert tooltip and tracker tooltip call sites.

Rationale:
- Both surfaces follow the same lifecycle: clear/hide, set owner/anchor, populate item content, append optional footer, show, then clean up on leave/hide.
- Centralizing compare behavior reduces the chance that one tooltip cleans up comparison panes correctly while the other leaks state.
- This keeps the change in UI-facing code instead of pushing tooltip policy into the addon entry point.

Alternatives considered:
- Duplicate compare logic in each file: rejected because tooltip cleanup bugs would likely diverge over time.
- Put tooltip policy in `LootWishList.lua`: rejected because it would violate the repository's module-boundary guidance.

### Reuse Blizzard's localized Equipped label

The addon-owned compare tooltip header will use Blizzard's built-in `EQUIPPED` global string for its tab label instead of introducing an addon-localized replacement.

Rationale:
- This keeps the compare header wording aligned with Blizzard's own compare tooltip vocabulary in every supported client locale.
- Reading the Blizzard-provided localized string is safe and avoids maintaining a duplicate localization entry for a label that is intentionally mirroring Blizzard UI.
- It keeps the addon-owned compare tooltip visually and semantically closer to the first-party compare experience.

Alternatives considered:
- Add a separate addon localization key for the compare header: rejected because it risks drifting from Blizzard terminology and duplicates a client-provided localized label.
- Hard-code `Equipped`: rejected because it would regress localization quality outside English clients.

## Risks / Trade-offs

- [Compare-pane cleanup differs between tooltip surfaces] -> Use one shared tooltip helper and require explicit cleanup on leave, row hide, and dialog close.
- [Bare item references produce weaker compare results than full links] -> Attempt compare for any valid tooltip reference, but let the behavior degrade to the base tooltip when comparison item data cannot provide richer results.
- [New helper placement could blur module ownership] -> Keep UI compare behavior in UI-facing code instead of the addon entry point.
- [Tracker tooltip churn increases the chance of sticky tooltip state] -> Preserve the current dedicated tooltip surface and avoid changing tracker anchoring or Objective Tracker integration.
- [Visual mismatch with Blizzard compare tabs or side selection] -> Mirror Blizzard compare-header visuals and keep side-selection logic centralized in the shared helper.

## Migration Plan

No saved-variable migration is required.

Rollout plan:
- Update the compare behavior on the existing alert and tracker tooltip surfaces.
- Keep compare rendering addon-owned and out of Blizzard's shared shopping tooltip path.
- Verify alert and tracker tooltips cleanly remove compare panes when hidden.

Rollback plan:
- Revert the compare helper usage from `WishListAlert.lua` and `TrackerUI.lua`.

## Open Questions

- Does the compare tooltip layout need any follow-up tuning in-game for very long item names or multi-line footer content?
