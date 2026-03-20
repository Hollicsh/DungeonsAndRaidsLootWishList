## Context

The proposal targets two taint-prone boundaries that are both active in moment-to-moment gameplay: the tracker row right-click remove menu in `TrackerUI.lua` and the tracked-loot event pipeline in `LootEvents.lua` / `LootWishList.lua`. The current menu path relies on Blizzard-owned shared menu systems (`MenuUtil.CreateContextMenu`, `UIDropDownMenu`, `ToggleDropDownMenu`, `CloseDropDownMenus`), and the current loot path still touches raw `CHAT_MSG_LOOT` payloads even though some parsing is wrapped in `pcall`.

Neither path needs Blizzard-owned shared state to satisfy the user-facing requirements. The tracker menu only needs a one-action `Remove` popup, and tracked-loot alerts only need stable addon-owned item identity plus the looting player when available. That makes both issues good candidates for isolation rather than further guard logic.

The Blizzard menu source also gives us a narrow visual target without requiring Blizzard's menu manager. Current mainline menus open at the cursor, play checkbox-style open/close sounds, use `GameFontNormal` text, and show a full-row additive hover highlight based on `Interface\\QuestFrame\\UI-QuestTitleHighlight`. We can mirror that behavior on addon-owned frames while keeping the execution path local to the addon.

## Goals / Non-Goals

**Goals:**

- Replace the tracker row right-click remove menu with an addon-owned popup that keeps the same visible single-action `Remove` behavior.
- Mimic Blizzard context-menu interaction closely enough to feel native by matching cursor-open behavior, sounds, fonts, and hover highlight patterns.
- Play native checkbox-style sound feedback when the surrogate tracker header, the `Loot Wishlist` header, and tracker group headers are expanded or collapsed.
- Remove dependence on shared Blizzard menu managers and dropdown infrastructure from tracker row interactions.
- Refactor tracked-loot processing so downstream alert logic consumes only addon-owned normalized records rather than raw taint-sensitive loot payloads.
- Keep the change scoped to the owning modules: `TrackerUI.lua` for tracker interaction, `LootEvents.lua` for loot normalization, and `LootWishList.lua` only for orchestration changes needed to consume normalized records.

**Non-Goals:**

- Redesign the tracker layout, row spacing, grouping model, or existing Shift-click removal path.
- Change the visible content of the remove menu beyond the single `Remove` action already specified.
- Rework loot-roll badge presentation or other non-taint-related tracker styling.
- Solve every historical taint issue in the addon; this change focuses on the tracker menu boundary and the loot-event normalization boundary.
- Introduce new saved-variable data or a new persistent model for loot events.

## Decisions

### Decision 1: Replace the shared tracker context menu with a fully addon-owned popup frame

**Choice:** `TrackerUI.lua` will stop calling Blizzard shared menu APIs for tracker-row right-click and instead show one lazily created addon-owned popup frame with one addon-owned button row.

**Rationale:**

- The current behavior only needs one action, so shared Blizzard menu machinery is unnecessary surface area.
- Removing `MenuUtil` and dropdown helpers from this flow reduces the chance of taint propagating into unrelated Blizzard systems such as Damage Meter.
- A single popup instance reused across rows keeps the interaction simple and localized.

**Alternatives considered:**

- Keep `MenuUtil.CreateContextMenu` and only remove the `UIDropDownMenu` fallback. Rejected because the shared modern menu manager is still part of the suspected taint path.
- Use a Blizzard menu template without the manager. Rejected because the value is in the visual behavior, not in inheriting Blizzard menu ownership.
- Remove right-click support entirely and rely on Shift-click only. Rejected because the tracker spec already requires the discoverable remove menu.

**Design details:**

- The popup opens at the cursor, not attached to Blizzard menu state.
- The popup owns its own show/hide, item binding, and dismissal behavior.
- The popup closes before removal triggers a tracker refresh so the menu never depends on a row that is about to disappear.

### Decision 2: Mirror Blizzard menu feel with Blizzard assets, not Blizzard menu systems

**Choice:** The addon-owned popup will imitate Blizzard context-menu presentation using Blizzard-provided sounds, font objects, and hover highlight art, but it will not use Blizzard menu mixins or dropdown managers.

**Rationale:**

- Repository guidance prefers Blizzard-native visual patterns where practical.
- Blizzard's own menu source gives us the relevant appearance cues: cursor-opened menus, `GameFontNormal` menu text, open/close checkbox sounds, and the additive `UI-QuestTitleHighlight` row highlight.
- Borrowing the visuals without the manager preserves the familiar feel while avoiding shared taint-sensitive ownership.

**Alternatives considered:**

- Build a fully custom visual style. Rejected because it would solve the taint problem but unnecessarily diverge from Blizzard UI language.
- Try to reproduce every internal detail of Blizzard menu composition. Rejected because the implementation goal is behavioral fidelity, not coupling to internal menu mixins.

**Design details:**

- Open sound uses Blizzard's checkbox-on sound kit; close/selection uses the corresponding checkbox-off or activation sound pattern.
- Menu text uses a Blizzard font object already present in the tracker UI.
- Hover highlight uses the same additive quest-title highlight texture pattern Blizzard menus use for button-like rows.
- The popup auto-hides when its owner row disappears, when the tracker refreshes, or when the player clicks elsewhere.

### Decision 3: Collapse and expand interactions use the same native checkbox-style sound feedback

**Choice:** `TrackerUI.lua` will play Blizzard's menu checkbox-style sound when the surrogate header, the `Loot Wishlist` header, or a tracker group header changes collapsed state.

**Rationale:**

- The addon already aims to feel native inside the tracker area, and collapse/expand actions are part of that feel.
- The affected controls are addon-owned tracker interactions, so the sound can be triggered locally without relying on Blizzard menu managers.
- Applying the same sound across the surrogate header, main wishlist header, and group headers keeps the interaction consistent.

**Alternatives considered:**

- Leave collapse/expand silent and only style the visuals. Rejected because the user explicitly wants native checkbox-style audio feedback.
- Use different open/close sounds for expand versus collapse. Rejected because the requested behavior is one consistent menu checkbox sound for both transitions.

**Design details:**

- Sound playback stays inside addon-owned click handlers in `TrackerUI.lua`.
- The same sound is used for both expanding and collapsing.
- Sound is played only when the click actually changes collapsed state.

### Decision 4: Keep the menu boundary entirely inside addon-owned tracker surfaces

**Choice:** The popup will be anchored and dismissed from addon-owned row logic only; group headers, boss headers, and Blizzard-owned tracker controls remain outside this menu path.

**Rationale:**

- The existing spec already limits right-click removal to tracked item rows.
- Restricting the popup to addon-owned rows avoids widening the taint surface to header controls or Blizzard-owned tracker buttons.
- The popup can safely store only the row's `itemID` and invoke the existing remove path.

**Alternatives considered:**

- Anchor the menu to Blizzard tracker headers or reuse Blizzard minimize buttons for dismissal behavior. Rejected because those are precisely the controls most likely to spread taint.
- Create a separate menu frame per row. Rejected because it increases object churn and cleanup complexity without adding safety.

**Design details:**

- Only `renderItemRow`-style tracked item rows can open the popup.
- The popup stores one active `itemID` and an optional `ownerRow` reference for lifetime checks.
- Tracker refresh code explicitly hides the popup when rows are recycled.

### Decision 5: Treat loot events as immediate parse boundaries and queue only normalized alert records

**Choice:** `LootEvents.lua` will process loot events immediately at the event boundary, derive the minimum usable item/player data there, and queue only normalized addon-owned alert records for later UI display.

**Rationale:**

- `pcall` can suppress a Lua failure but it does not solve the underlying boundary issue, so it must not be part of the successful tracked-loot path.
- The alert system only needs stable item identity and a looter name after event handling finishes, so later logic should not keep reaching back into original event payloads.
- Keeping parsing immediate preserves combat-time loot awareness while still ensuring deferred UI work consumes addon-owned records only.

**Alternatives considered:**

- Keep the current parsing and add more `pcall` wrappers. Rejected because that masks failure rather than improving the event boundary.
- Remove other-player loot alerts entirely. Rejected because `wishlist-loot-awareness` still requires that capability.

**Design details:**

- The event entrypoint becomes the only place allowed to interpret incoming loot payloads.
- Parsing happens immediately instead of storing or replaying raw event payloads later.
- If the payload cannot be normalized into the required item/player data, the handler drops that event rather than treating masking or partial parsing as success.
- Alert queue records remain addon-owned plain values only.

### Decision 6: Prefer narrower orchestration changes over a broad tracker refactor

**Choice:** The change will update the menu and loot-event boundaries first without bundling unrelated tracker-header or Adventure Guide refactors into the same artifact set.

**Rationale:**

- The repository guidance explicitly prefers small, reversible fixes and warns against bundling unrelated cleanups with bug fixes.
- The new menu system and loot-event normalization are already cross-cutting enough to justify design work.
- Keeping this change narrow makes it easier to validate whether these two boundaries account for the current Damage Meter taint reports.

**Alternatives considered:**

- Fold in a full audit of every tracker button and Adventure Guide overlay during the same change. Rejected because it would obscure which fix actually resolves the reported issue.
- Only fix the menu and ignore loot events. Rejected because loot events remain an independently suspicious taint boundary and the user explicitly called them out.

## Risks / Trade-offs

- **Risk: The addon-owned popup may still feel slightly different from Blizzard's managed context menu.** -> Mitigation: mirror the specific Blizzard assets and behaviors that players notice most: cursor-open, sounds, font treatment, and additive hover highlight.
- **Risk: Added header-toggle sounds could fire too often during refresh if tied to render code instead of state changes.** -> Mitigation: play sounds only inside the click handlers that actually toggle collapsed state.
- **Risk: Clicking outside to dismiss the popup can interact awkwardly with tracker refresh timing.** -> Mitigation: use one shared popup, clear its active row/item state on hide, and explicitly close it during row recycling and refresh.
- **Risk: Some loot-message payloads may still be sensitive at runtime even when parsed immediately.** -> Mitigation: keep parsing isolated to the event boundary, avoid `pcall` masking, and validate against real taint reproduction scenarios.
- **Risk: Damage Meter taint may persist even after these fixes if another tracker control remains contaminated.** -> Mitigation: validate with `taint.log` after this narrower change and treat remaining tracker-header issues as a follow-up if needed.

## Migration Plan

1. Remove the shared menu code path from `TrackerUI.lua` and replace it with one addon-owned popup implementation.
2. Add native checkbox-style sound playback to surrogate-header, wishlist-header, and group-header collapse toggles in addon-owned click paths.
3. Keep the visible tracker interaction contract unchanged: right-click opens `Remove`, Shift-click still removes immediately.
4. Refactor `LootEvents.lua` so only normalized addon-owned records leave the loot-event boundary.
5. Update any orchestration in `LootWishList.lua` so combat-time loot alerts remain functional while deferred UI work consumes normalized records only.
6. Validate tracker right-click, header/group toggle sounds, outside-click dismissal, row refresh/removal timing, and post-loot alert flows with taint logging enabled.

Rollback strategy:

- The menu and loot-event changes are local enough that rollback is restoring the prior tracker menu path and prior loot-event parsing if the new isolated flow causes functional regressions.

## Open Questions

- If immediate `CHAT_MSG_LOOT` parsing still proves taint-prone on some clients, do we need a follow-up design to shift tracked-loot awareness to a different event source?
- If Damage Meter taint still reproduces after this change, should the next targeted fix be the tracker header minimize-button interaction or the Adventure Guide updater path?
