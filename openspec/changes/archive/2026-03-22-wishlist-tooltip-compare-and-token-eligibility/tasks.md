## 1. Tooltip Comparison

- [x] 1.1 Add a shared UI helper that applies addon-owned equipped comparison tooltip behavior to the addon-owned tooltip surfaces and cleans up comparison panes on hide.
- [x] 1.2 Update `WishListAlert.lua` to use the shared compare-tooltip helper for alert item hover and dismissal cleanup.
- [x] 1.3 Update `TrackerUI.lua` to use the shared compare-tooltip helper while preserving the existing row anchor and slot-mode footer behavior.

## 2. Verification

- [x] 2.1 Add or update local tests for compare-tooltip helper behavior where test seams exist.
- [x] 2.2 Manually verify alert tooltip comparison, tracker tooltip comparison, and comparison-pane cleanup behavior in-game.
