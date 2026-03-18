## 1. Tracker Layout Update

- [x] 1.1 Add a tracker-local constant for the 5px top-level group gap in `TrackerUI.lua`
- [x] 1.2 Update the top-level group layout loop in `TrackerUI.lua` to add the 5px gap only between adjacent groups
- [x] 1.3 Keep row spacing within each group unchanged, including raid boss subheaders, item rows, and collapsed-group blocks

## 2. Verification

- [x] 2.1 Verify `Loot Source` mode shows a 5px gap between adjacent top-level groups
- [x] 2.2 Verify `Equipment Slot` mode shows a 5px gap between adjacent top-level groups
- [x] 2.3 Verify raid boss headers and item rows within the same group remain tightly stacked
- [x] 2.4 Verify collapsed groups still show the 5px gap before the next top-level group and do not introduce extra trailing space after the last group
