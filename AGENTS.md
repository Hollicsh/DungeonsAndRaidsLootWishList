# Loot WishList

Loot WishList is a World of Warcraft addon that lets players track dungeon and raid loot from the Adventure Guide, surface tracked items in the Objective Tracker, react to loot events, and persist wishlist state per character.

This file is for both AI agents and human contributors. It describes the addon's architecture and the coding practices expected in this repository.

## Architecture

### System overview

The addon is organized around a small set of focused Lua modules:

- `LootWishList.lua` - addon entry point, event registration, refresh orchestration, shared namespace helpers
- `WishlistStore.lua` - character-scoped saved-variable access and mutation
- `ItemResolver.lua` - stable item identity resolution across links, item IDs, and scaled variants
- `SourceResolver.lua` - loot-source grouping logic with fallback behavior
- `TrackerModel.lua` - pure transformation from tracked items to grouped tracker rows
- `TrackerRowStyle.lua` - tracker row presentation constants such as check atlas, offsets, and visual spacing
- `TrackerUI.lua` - Objective Tracker section header, row creation, collapse behavior, and in-game rendering
- `AdventureGuideUI.lua` - Encounter Journal / Adventure Guide integration and wishlist checkbox injection
- `LootEvents.lua` - loot chat and loot-roll frame reactions
- `Locales.lua` - all user-facing string lookup

### Data flow

The intended runtime flow is:

1. Adventure Guide loot rows expose a wishlist toggle.
2. Toggling updates character-specific saved variables through `WishlistStore.lua`.
3. `LootWishList.lua` rebuilds tracker state by combining:
   - tracked items from saved variables
   - current possession state from bags / equipment / bank when known
   - source grouping from stored metadata and source resolution
4. `TrackerModel.lua` produces grouped row data.
5. `TrackerUI.lua` renders the `Loot Wishlist` section in the Objective Tracker.
6. `LootEvents.lua` updates or decorates UI in response to loot-related events.

### State model

Saved variables are per-character and should stay minimal.

Tracked item state is expected to capture:

- stable item identity
- tracked / untracked membership
- best looted item level when known
- lightweight metadata needed to rebuild tracker display, such as source label or item name if already known

Do not persist derived presentation state such as:

- whether a row is currently visible
- whether the tracker section is expanded or collapsed, unless explicitly designed
- whether the item is currently possessed, since that should be recomputed from game state

## Architectural rules

### Keep pure logic separate from WoW frame code

Prefer putting deterministic logic in pure modules:

- identity resolution in `ItemResolver.lua`
- grouping in `SourceResolver.lua` and `TrackerModel.lua`
- row presentation constants in `TrackerRowStyle.lua`

Keep Blizzard frame manipulation, event hooks, and layout behavior in UI-facing modules only.

### Prefer Blizzard-native UI patterns

When presenting tracker sections, rows, headers, checkmarks, and animations:

- reuse Blizzard templates, atlases, fonts, and interaction patterns where practical
- prefer the native Objective Tracker header / row behavior over bespoke art or custom widget language
- only introduce custom presentation when Blizzard assets cannot express the required behavior

### Stable item identity is more important than displayed item level

Adventure Guide rows often represent a baseline version of an item while actual drops can scale.

The addon should treat all item-level variants of the same underlying item as one wishlist target. Do not key tracking state off displayed item level text.

### Tracker grouping is source-first

Tracked items should group by loot source when known and fall back to `Other` only when a source cannot be resolved.

If a bug appears where items unexpectedly fall into `Other`, debug source resolution before changing tracker rendering.

### Objective Tracker behavior should be additive

The wishlist section should behave like a native tracker section without breaking or reflowing Blizzard-owned sections.

When adjusting tracker layout:

- prefer anchoring and spacing that follow Blizzard module geometry
- avoid hard-coded screen-space conversions when a parent-relative anchor is available
- treat alignment and stacking regressions as architecture issues, not just cosmetic issues

## Coding practices

### File ownership and responsibilities

When changing behavior, edit the narrowest responsible file first.

- persistence bugs -> `WishlistStore.lua`
- item matching bugs -> `ItemResolver.lua`
- source grouping bugs -> `SourceResolver.lua`
- tracker text / grouping output bugs -> `TrackerModel.lua`
- spacing / atlas / row visual bugs -> `TrackerRowStyle.lua` or `TrackerUI.lua`
- Encounter Journal checkbox bugs -> `AdventureGuideUI.lua`
- loot chat / loot-roll behavior bugs -> `LootEvents.lua`
- orchestration or refresh sequencing bugs -> `LootWishList.lua`

Avoid placing unrelated logic into `LootWishList.lua` just because it is the entry point.

### Localization-first strings

All user-facing strings must come from `Locales.lua`.

Do not introduce hard-coded UI text in runtime modules unless it is temporary debugging code that will be removed before completion.

### Minimize hidden coupling

Do not rely on implicit globals or cross-file state when a dependency can be passed explicitly.

In particular:

- pass addon namespace state deliberately into helper functions that need it
- avoid reading visual constants directly from unrelated modules when a local helper or explicit reference is clearer
- keep row-style constants centralized instead of scattering offsets and texture choices across multiple files

### Preserve testable seams

If a behavior can be expressed as pure data transformation, keep it outside WoW-only frame APIs so it can be covered by the local Node + Wasmoon tests.

Good candidates for tests:

- stable item key generation
- source fallback behavior
- grouped tracker row formatting
- row-style contracts such as check atlas and padding

Poor candidates for local tests:

- exact Blizzard frame hierarchy assumptions
- live Encounter Journal widget names that only exist in the game client
- runtime animation appearance

### Debugging approach

When a UI bug appears:

1. identify whether it is a data bug, a layout bug, or a Blizzard integration bug
2. trace which module owns that responsibility
3. fix the root cause in that module instead of layering compensating offsets elsewhere

Do not patch tracker alignment issues by stacking more offsets on top of uncertain anchors.

### Keep changes small and reversible

When modifying UI presentation:

- prefer changing a constant or a narrowly scoped helper before refactoring a whole module
- separate style fixes from behavior fixes when possible
- avoid bundling unrelated cleanups with bug fixes

## Working expectations for agents and contributors

### Before changing code

- read the relevant module end-to-end
- identify whether the issue belongs to data, model, UI, or event handling
- if tests exist for the affected pure logic, update or add a failing test first

### When adding new behavior

- preserve the module boundaries listed above
- update tests for pure logic changes
- keep Blizzard integration code defensive, since frame availability and widget structure can vary by client state

### When adjusting UI styling

- favor `TrackerRowStyle.lua` for row-level constants
- favor Blizzard templates / atlases / fonts over custom assets
- verify that a visual tweak does not unintentionally break stacking, alignment, or visibility

### When unsure

- prefer a small, local change over a broad refactor
- prefer explicit data flow over implicit coupling
- prefer matching Blizzard's tracker patterns over inventing new ones
