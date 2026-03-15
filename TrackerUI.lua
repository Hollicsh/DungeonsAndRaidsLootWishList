local TrackerUI = {}

local trackerFrame = nil
local trackerTooltip = CreateFrame("GameTooltip", "LootWishListTrackerTooltip", UIParent, "GameTooltipTemplate")
local currentGroups = {}
local knownRowKeys = {}
local knownItemStates = {}
local ns = nil

local COLLAPSE_ATLAS = "ui-questtrackerbutton-secondary-collapse"
local EXPAND_ATLAS = "ui-questtrackerbutton-secondary-expand"
local HEADER_HEIGHT = 26
local ROW_HEIGHT = 16
local DEFAULT_WIDTH = 260
local TRACKER_SECTION_GAP = -10
local WISHLIST_HEADER_TOP_PADDING = 10
local CONTENT_TOP_GAP = 4
local ITEM_TEXT_PADDING = 12
local STANDALONE_HEADER_OFFSET_Y = -3
local FRAME_LEFT_PADDING = 10
local STANDALONE_HEADER_BOTTOM_MARGIN = 10

local function playAddAnimation(frame)
  if frame and frame.headerFrame and frame.headerFrame.AddAnim and frame.headerFrame.AddAnim.Restart then
    frame.headerFrame.AddAnim:Restart()
  elseif type(ObjectiveTracker_PlayBlockAddedAnimation) == "function" then
    ObjectiveTracker_PlayBlockAddedAnimation(frame.headerFrame or frame)
  elseif type(UIFrameFlash) == "function" then
    UIFrameFlash(frame, 0.2, 0.3, 0.8, false, 0, 0)
  end
end

local function ensureHeaderAnimation(row)
  if not row or row.headerGlow then
    return row
  end

  row.headerGlow = row:CreateTexture(nil, "OVERLAY")
  row.headerGlow:SetAtlas("ui-questtracker-objfx-barglow")
  row.headerGlow:SetAlpha(0)
  row.headerGlow:SetSize(240, ROW_HEIGHT)
  row.headerGlow:SetPoint("TOPLEFT", row.text, "TOPLEFT", 0, 3)
  row.headerGlow:SetPoint("BOTTOMLEFT", row.text, "BOTTOMLEFT", 0, -4)

  row.headerGlow:SetTexCoord(0, 1, 0, 1)

  row.headerAddAnim = row:CreateAnimationGroup()

  local addShow = row.headerAddAnim:CreateAnimation("Alpha")
  addShow:SetChildKey("headerGlow")
  addShow:SetOrder(1)
  addShow:SetDuration(0)
  addShow:SetFromAlpha(0)
  addShow:SetToAlpha(1)

  local addFade = row.headerAddAnim:CreateAnimation("Alpha")
  addFade:SetChildKey("headerGlow")
  addFade:SetOrder(1)
  addFade:SetDuration(0.41)
  addFade:SetStartDelay(0.33)
  addFade:SetFromAlpha(1)
  addFade:SetToAlpha(0)

  local textFade = row.headerAddAnim:CreateAnimation("Alpha")
  textFade:SetChildKey("text")
  textFade:SetOrder(1)
  textFade:SetDuration(0.03)
  textFade:SetFromAlpha(0)
  textFade:SetToAlpha(1)

  row.headerCompleteAnim = row:CreateAnimationGroup()
  local completeShow = row.headerCompleteAnim:CreateAnimation("Alpha")
  completeShow:SetChildKey("headerGlow")
  completeShow:SetOrder(1)
  completeShow:SetDuration(0)
  completeShow:SetFromAlpha(0)
  completeShow:SetToAlpha(1)

  local completeFade = row.headerCompleteAnim:CreateAnimation("Alpha")
  completeFade:SetChildKey("headerGlow")
  completeFade:SetOrder(1)
  completeFade:SetDuration(0.33)
  completeFade:SetStartDelay(0.33)
  completeFade:SetFromAlpha(1)
  completeFade:SetToAlpha(0)

  local function onAnimStop()
    row.headerGlow:SetAlpha(0)
    row.text:SetAlpha(1)
  end

  row.headerAddAnim:SetScript("OnFinished", onAnimStop)
  row.headerAddAnim:SetScript("OnStop", onAnimStop)
  row.headerCompleteAnim:SetScript("OnFinished", onAnimStop)
  row.headerCompleteAnim:SetScript("OnStop", onAnimStop)

  return row
end

local function playHeaderAnimation(row, animationType)
  ensureHeaderAnimation(row)
  if not row or not row.headerGlow then
    return
  end

  row.headerAddAnim:Stop()
  row.headerCompleteAnim:Stop()
  row.headerGlow:SetAlpha(0)
  row.text:SetAlpha(1)

  if animationType == "complete" then
    row.headerCompleteAnim:Play()
  else
    row.headerAddAnim:Play()
  end
end

local function getCharacterKey()
  local name = UnitName("player") or "Unknown"
  local realm = GetRealmName() or "Unknown"
  return string.format("%s-%s", name, realm)
end

local function getTrackerReferenceFrame()
  if ObjectiveTrackerFrame then
    if ObjectiveTrackerFrame.BlocksFrame then
      return ObjectiveTrackerFrame.BlocksFrame
    end

    if ObjectiveTrackerFrame.ContentsFrame then
      return ObjectiveTrackerFrame.ContentsFrame
    end
  end

  return ObjectiveTrackerFrame
end

local function isTrackerExplicitlyCollapsed()
  if not ObjectiveTrackerFrame then
    return false
  end

  if ObjectiveTrackerFrame.isCollapsed or ObjectiveTrackerFrame.collapsed then
    return true
  end

  if type(ObjectiveTrackerFrame.IsCollapsed) == "function" then
    return ObjectiveTrackerFrame:IsCollapsed()
  end

  return false
end

local function isNativeTrackerShown()
  if not ObjectiveTrackerFrame or not ObjectiveTrackerFrame:IsShown() or isTrackerExplicitlyCollapsed() then
    return false
  end

  local parent = getTrackerReferenceFrame()
  if parent and type(parent.IsShown) == "function" then
    return parent:IsShown()
  end

  return true
end

local function applyCollapseButtonState(button, collapsed)
  if not button then
    return
  end

  button:SetNormalAtlas(collapsed and EXPAND_ATLAS or COLLAPSE_ATLAS)
  button:SetPushedAtlas((collapsed and EXPAND_ATLAS or COLLAPSE_ATLAS) .. "-pressed")
end

local function applyStandaloneHeaderButtonState(frame)
  local button = frame and frame.topHeaderMinimizeButton or nil
  local atlases = frame and frame.topHeaderButtonAtlases or nil
  if not button or not atlases then
    return
  end

  local state = frame.lootWishlistStandaloneHidden and "collapsed" or "expanded"
  local normalAtlas = atlases[state] and atlases[state].normal or nil
  local pushedAtlas = atlases[state] and atlases[state].pushed or nil

  if normalAtlas then
    button:SetNormalAtlas(normalAtlas)
  end

  if pushedAtlas then
    button:SetPushedAtlas(pushedAtlas)
  end
end

local function getBottommostVisibleChild(parent)
  if not parent or not parent.GetChildren then
    return nil, nil, nil
  end

  local anchorTarget = nil
  local anchorBottom = nil
  local anchorLeft = nil

  for _, child in ipairs({ parent:GetChildren() }) do
    if child and child:IsShown() and child.GetBottom then
      local bottom = child:GetBottom()
      if bottom and (anchorBottom == nil or bottom < anchorBottom) then
        anchorBottom = bottom
        anchorLeft = child.GetLeft and child:GetLeft() or nil
        anchorTarget = child
      end
    end
  end

  return anchorTarget, anchorBottom, anchorLeft
end

local function hasVisibleNativeTrackerSections()
  local parent = getTrackerReferenceFrame()
  local anchorTarget = select(1, getBottommostVisibleChild(parent))
  return anchorTarget ~= nil
end

local function anchorTrackerFrame(frame)
  local parent = getTrackerReferenceFrame()
  if not frame or not parent then
    return
  end

  local width = parent.GetWidth and parent:GetWidth() or DEFAULT_WIDTH
  if width and width > 0 then
    frame:SetWidth(width)
    if frame.headerFrame then
      frame.headerFrame:SetWidth(width)
    end
  end

  frame:ClearAllPoints()

  if isNativeTrackerShown() then
    local anchorTarget, _, anchorLeft = getBottommostVisibleChild(parent)
    if anchorTarget then
      local parentLeft = parent.GetLeft and parent:GetLeft() or nil
      local offsetX = 0
      if parentLeft and anchorLeft then
        offsetX = parentLeft - anchorLeft
      end

      frame:SetPoint("TOPLEFT", anchorTarget, "BOTTOMLEFT", offsetX, -TRACKER_SECTION_GAP)
      return
    end
  end

  frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
end

local function ensureRow(frame, index)
  frame.rows = frame.rows or {}
  local row = frame.rows[index]
  if row then
    return row
  end

  local parent = frame.contentFrame or frame
  row = CreateFrame("Button", nil, parent)
  row:SetHeight(ROW_HEIGHT)
  row:RegisterForClicks("LeftButtonUp")

  row.tick = row:CreateTexture(nil, "ARTWORK")
  row.tick:SetSize(ns.TrackerRowStyle.CHECK_SIZE, ns.TrackerRowStyle.CHECK_SIZE)
  row.tick:SetAtlas(ns.TrackerRowStyle.CHECK_ATLAS, false)

  row.dash = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  row.dash:SetText("-")
  row.dash:SetJustifyH("CENTER")
  row.dash:SetWidth(12)
  row.dash:SetTextColor(0.7, 0.7, 0.7)

  row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  row.text:SetJustifyH("LEFT")
  row.text:SetWordWrap(false)

  row.collapseButton = CreateFrame("Button", nil, row)
  row.collapseButton:SetSize(16, 16)
  row.collapseButton:SetHighlightAtlas("ui-questtrackerbutton-yellow-highlight", "ADD")
  row.collapseButton:Hide()

  frame.rows[index] = row
  return row
end

local function hideUnusedRows(frame, firstUnusedIndex)
  if not frame or not frame.rows then
    return
  end

  for index = firstUnusedIndex, #frame.rows do
    local row = frame.rows[index]
    if row.headerAddAnim then
      row.headerAddAnim:Stop()
    end
    if row.headerCompleteAnim then
      row.headerCompleteAnim:Stop()
    end
    row:Hide()
    row:SetScript("OnClick", nil)
    row:SetScript("OnEnter", nil)
    row:SetScript("OnLeave", nil)
    row.collapseButton:SetScript("OnClick", nil)
    row.tooltipRef = nil
    row.itemID = nil
    row.groupLabel = nil
    row.instanceID = nil
    row.isBossHeader = nil
  end
end

local function showTrackerTooltip(row)
  if not row or row.isBossHeader then
    return
  end

  local ref = row.tooltipRef
  local id = row.itemID
  if type(ref) ~= "string" and type(id) ~= "number" then
    return
  end

  trackerTooltip:Hide()
  trackerTooltip:SetOwner(UIParent, "ANCHOR_NONE")
  trackerTooltip:ClearAllPoints()
  trackerTooltip:SetPoint("TOPRIGHT", row, "TOPLEFT", -4, 0)

  if type(ref) == "string" and ref:find("item:") then
    trackerTooltip:SetHyperlink(ref)
  elseif id and trackerTooltip.SetItemByID then
    trackerTooltip:SetItemByID(id)
  end

  trackerTooltip:Show()
end

local function hideTrackerTooltip()
  trackerTooltip:Hide()
end

local function getHeaderTextAnchor(frame)
  return frame and (frame.headerText or (frame.headerFrame and (frame.headerFrame.Text or frame.headerFrame.HeaderText))) or
      nil
end

local function getHeaderTextInset(frame)
  local defaultInset = 15
  if not frame then
    return defaultInset
  end

  local headerText = getHeaderTextAnchor(frame)
  if not headerText or not headerText.GetLeft or not frame.GetLeft then
    return defaultInset
  end

  local headerLeft = headerText:GetLeft()
  local frameLeft = frame:GetLeft()
  if not headerLeft or not frameLeft then
    return defaultInset
  end

  local inset = headerLeft - frameLeft
  if inset < 0 then
    return defaultInset
  end

  return inset
end

local function setWishlistCollapse(frame, collapsed)
  frame.lootWishlistCollapsed = collapsed and true or false
  if frame.headerMinimizeButton then
    applyCollapseButtonState(frame.headerMinimizeButton, frame.lootWishlistCollapsed)
  end
end

local function setStandaloneCollapse(frame, collapsed)
  collapsed = collapsed and true or false
  if frame.lootWishlistStandaloneHidden == collapsed then
    return
  end

  frame.lootWishlistStandaloneHidden = collapsed
  applyStandaloneHeaderButtonState(frame)
end

local function renderGroupHeader(row, group, itemCount, collapsed)
  local headerInset = getHeaderTextInset(trackerFrame)
  row.tick:Hide()
  row.dash:Hide()
  row.collapseButton:Show()
  row.collapseButton:ClearAllPoints()
  row.collapseButton:SetPoint("RIGHT", row, "RIGHT", 0, 0)
  applyCollapseButtonState(row.collapseButton, collapsed)

  row.text:ClearAllPoints()
  row.text:SetPoint("LEFT", row, "LEFT", headerInset, 0)
  row.text:SetPoint("RIGHT", row.collapseButton, "LEFT", -4, 0)
  row.text:SetFontObject(GameFontNormal)
  local r, g, b = GameFontNormal:GetTextColor()
  row.text:SetTextColor(r, g, b)

  if collapsed and itemCount > 0 then
    row.text:SetText(string.format("%s (%d)", group.label, itemCount))
  else
    row.text:SetText(group.label)
  end

  row.groupLabel = group.label
  row.instanceID = group.instanceID
  row.isBossHeader = false
  row.tooltipRef = nil
  row.itemID = nil

  row:SetScript("OnClick", nil)
  row:SetScript("OnEnter", nil)
  row:SetScript("OnLeave", nil)
  row.collapseButton:SetScript("OnClick", function()
    ns.WishlistStore.toggleGroupCollapse(LootWishListDB, getCharacterKey(), group.label)
    TrackerUI.Refresh(ns, currentGroups)
  end)

  row:Show()
end

local function renderItemRow(row, item)
  local headerInset = getHeaderTextInset(trackerFrame)

  row.collapseButton:Hide()
  row.collapseButton:SetScript("OnClick", nil)
  row:SetScript("OnClick", nil)

  row.text:ClearAllPoints()
  row.text:SetPoint("RIGHT", row, "RIGHT", -4, 0)

  if item.isBossHeader then
    row.tick:Hide()
    row.dash:Hide()
    row.text:SetPoint("LEFT", row, "LEFT", headerInset, 0)
    row.text:SetFontObject(GameFontNormal)
    row.text:SetTextColor(0.65, 0.65, 0.65)
    row.text:SetText(item.displayText)
    row.isBossHeader = true
    row.tooltipRef = nil
    row.itemID = nil
    row:SetScript("OnEnter", nil)
    row:SetScript("OnLeave", nil)
  else
    if item.showTick then
      row.tick:Show()
      row.tick:ClearAllPoints()
      row.tick:SetPoint("LEFT", row, "LEFT", headerInset - 5, 0)
      row.dash:Hide()
    else
      row.tick:Hide()
      row.dash:Show()
      row.dash:ClearAllPoints()
      row.dash:SetPoint("LEFT", row, "LEFT", headerInset + 1, 0)
    end

    row.text:SetPoint("LEFT", row, "LEFT", headerInset + ITEM_TEXT_PADDING, 0)
    row.text:SetFontObject(GameFontHighlight)
    row.text:SetText(item.displayText)

    if item.displayLink and type(GetItemInfo) == "function" then
      local _, _, itemQuality = GetItemInfo(item.displayLink)
      if itemQuality and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[itemQuality] then
        local qc = ITEM_QUALITY_COLORS[itemQuality]
        row.text:SetTextColor(qc.r, qc.g, qc.b)
      else
        local r, g, b = GameFontHighlight:GetTextColor()
        row.text:SetTextColor(r, g, b)
      end
    else
      local r, g, b = GameFontHighlight:GetTextColor()
      row.text:SetTextColor(r, g, b)
    end

    row.isBossHeader = false
    row.itemID = item.itemID
    row.tooltipRef = item.displayLink or item.tooltipRef
    row:SetScript("OnEnter", function(self)
      showTrackerTooltip(self)
    end)
    row:SetScript("OnLeave", function()
      hideTrackerTooltip()
    end)
    row:SetScript("OnClick", function(_, button)
      if button == "LeftButton" and IsShiftKeyDown() and item.itemID then
        ns.RemoveTrackedItem(item.itemID)
      end
    end)
  end

  row.groupLabel = nil
  row.instanceID = nil
  row:Show()
end

local function syncTrackerFrame()
  local frame = trackerFrame
  if not frame then
    return
  end

  hideTrackerTooltip()

  if not currentGroups or #currentGroups == 0 then
    frame:Hide()
    return
  end

  if isTrackerExplicitlyCollapsed() then
    frame:Hide()
    return
  end

  local showStandaloneHeader = (not ObjectiveTrackerFrame or not ObjectiveTrackerFrame:IsShown()) or
      not hasVisibleNativeTrackerSections()

  anchorTrackerFrame(frame)
  frame:Show()

  if frame.topHeader then
    frame.topHeader:SetShown(showStandaloneHeader)
  end

  local headerText = frame.headerText or frame.headerFrame.Text or frame.headerFrame.HeaderText
  if headerText then
    headerText:SetText(ns.GetText("LOOT_WISHLIST"))
  end

  if frame.topHeaderText then
    frame.topHeaderText:SetText(_G.TRACKER_ALL_OBJECTIVES or "All Objectives")
  end

  frame.headerFrame:ClearAllPoints()
  if showStandaloneHeader then
    frame.headerFrame:SetPoint("TOPLEFT", frame.topHeader, "BOTTOMLEFT", 0, -STANDALONE_HEADER_BOTTOM_MARGIN)
    frame.headerFrame:SetPoint("TOPRIGHT", frame.topHeader, "BOTTOMRIGHT", 0, -STANDALONE_HEADER_BOTTOM_MARGIN)
  else
    frame.headerFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -WISHLIST_HEADER_TOP_PADDING)
    frame.headerFrame:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -WISHLIST_HEADER_TOP_PADDING)
  end

  local contentTopOffset = showStandaloneHeader and
      (math.abs(STANDALONE_HEADER_OFFSET_Y) + HEADER_HEIGHT + STANDALONE_HEADER_BOTTOM_MARGIN + HEADER_HEIGHT + CONTENT_TOP_GAP) or
      (WISHLIST_HEADER_TOP_PADDING + HEADER_HEIGHT + CONTENT_TOP_GAP)

  applyStandaloneHeaderButtonState(frame)

  if showStandaloneHeader and frame.lootWishlistStandaloneHidden then
    frame.headerFrame:Hide()
    if frame.contentFrame then
      frame.contentFrame:Hide()
      frame.contentFrame:SetHeight(0)
    end
    hideUnusedRows(frame, 1)
    frame:SetHeight(math.abs(STANDALONE_HEADER_OFFSET_Y) + HEADER_HEIGHT)
    return
  end

  frame.headerFrame:Show()
  if frame.contentFrame then
    frame.contentFrame:ClearAllPoints()
    frame.contentFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", FRAME_LEFT_PADDING, -contentTopOffset)
    frame.contentFrame:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -contentTopOffset)
  end

  if frame.lootWishlistCollapsed then
    if frame.contentFrame then
      frame.contentFrame:Hide()
      frame.contentFrame:SetHeight(0)
    end
    hideUnusedRows(frame, 1)
    frame:SetHeight(contentTopOffset)
    return
  end

  if frame.contentFrame then
    frame.contentFrame:Show()
  end

  local rowIndex = 1
  local yOffset = 0
  local allKeys = {}
  local addedNewItem = false
  local groupAnimations = {}
  local db = LootWishListDB
  local charKey = getCharacterKey()

  for _, group in ipairs(currentGroups) do
    local itemCount = 0
    for _, item in ipairs(group.items) do
      if not item.isBossHeader then
        itemCount = itemCount + 1
        local uniqueKey = tostring(group.label) .. ":" .. tostring(item.itemID)
        allKeys[uniqueKey] = true
        if not knownRowKeys[uniqueKey] then
          knownRowKeys[uniqueKey] = true
          addedNewItem = true
          groupAnimations[group.label] = groupAnimations[group.label] or "add"
        end

        local previousState = knownItemStates[uniqueKey]
        if previousState and not previousState.showTick and item.showTick then
          if groupAnimations[group.label] ~= "add" then
            groupAnimations[group.label] = "complete"
          end
        end

        knownItemStates[uniqueKey] = {
          showTick = item.showTick == true,
        }
      end
    end

    local collapsed = ns.WishlistStore.isGroupCollapsed(db, charKey, group.label)
    local headerRow = ensureRow(frame, rowIndex)
    headerRow:ClearAllPoints()
    headerRow:SetPoint("TOPLEFT", frame.contentFrame or frame, "TOPLEFT", 0, yOffset)
    headerRow:SetPoint("TOPRIGHT", frame.contentFrame or frame, "TOPRIGHT", 0, yOffset)
    renderGroupHeader(headerRow, group, itemCount, collapsed)
    if groupAnimations[group.label] then
      playHeaderAnimation(headerRow, groupAnimations[group.label])
    end
    yOffset = yOffset - ROW_HEIGHT
    rowIndex = rowIndex + 1

    if not collapsed then
      for _, item in ipairs(group.items) do
        local itemRow = ensureRow(frame, rowIndex)
        itemRow:ClearAllPoints()
        itemRow:SetPoint("TOPLEFT", frame.contentFrame or frame, "TOPLEFT", 0, yOffset)
        itemRow:SetPoint("TOPRIGHT", frame.contentFrame or frame, "TOPRIGHT", 0, yOffset)
        renderItemRow(itemRow, item)

        yOffset = yOffset - ROW_HEIGHT
        rowIndex = rowIndex + 1
      end
    end
  end

  for knownKey in pairs(knownRowKeys) do
    if not allKeys[knownKey] then
      knownRowKeys[knownKey] = nil
      knownItemStates[knownKey] = nil
    end
  end

  hideUnusedRows(frame, rowIndex)
  local contentHeight = math.max(0, -yOffset)
  if frame.contentFrame then
    frame.contentFrame:SetHeight(contentHeight)
  end

  frame:SetHeight(contentTopOffset + contentHeight + CONTENT_TOP_GAP)

  if addedNewItem then
    playAddAnimation(frame)
  end
end

local function hookTrackerState()
  if not ObjectiveTrackerFrame or trackerFrame == nil then
    return
  end

  if trackerFrame.trackerHooksInstalled then
    return
  end

  trackerFrame.trackerHooksInstalled = true

  if type(ObjectiveTrackerFrame.Update) == "function" then
    hooksecurefunc(ObjectiveTrackerFrame, "Update", function()
      syncTrackerFrame()
    end)
  elseif type(ObjectiveTracker_Update) == "function" then
    hooksecurefunc("ObjectiveTracker_Update", function()
      syncTrackerFrame()
    end)
  end

  ObjectiveTrackerFrame:HookScript("OnShow", function()
    syncTrackerFrame()
  end)
  ObjectiveTrackerFrame:HookScript("OnHide", function()
    syncTrackerFrame()
  end)

  if ObjectiveTrackerFrame.BlocksFrame and ObjectiveTrackerFrame.BlocksFrame.HookScript then
    ObjectiveTrackerFrame.BlocksFrame:HookScript("OnShow", function()
      syncTrackerFrame()
    end)
    ObjectiveTrackerFrame.BlocksFrame:HookScript("OnHide", function()
      syncTrackerFrame()
    end)
  end

  if ObjectiveTrackerFrame.ContentsFrame and ObjectiveTrackerFrame.ContentsFrame.HookScript then
    ObjectiveTrackerFrame.ContentsFrame:HookScript("OnShow", function()
      syncTrackerFrame()
    end)
    ObjectiveTrackerFrame.ContentsFrame:HookScript("OnHide", function()
      syncTrackerFrame()
    end)
  end

  if type(ObjectiveTrackerFrame.SetCollapsed) == "function" then
    hooksecurefunc(ObjectiveTrackerFrame, "SetCollapsed", function()
      syncTrackerFrame()
    end)
  end

  local header = ObjectiveTrackerFrame.Header
  if header then
    local minBtn = header.MinimizeButton or header.CollapseButton
    if minBtn and minBtn.HookScript then
      minBtn:HookScript("OnClick", function()
        syncTrackerFrame()
      end)
    end
  end
end

function TrackerUI.Initialize(namespace)
  if trackerFrame then
    return
  end

  ns = namespace

  trackerFrame = CreateFrame("Frame", "LootWishListTrackerFrame", UIParent)
  trackerFrame:SetWidth(DEFAULT_WIDTH)
  trackerFrame:SetHeight(HEADER_HEIGHT)
  trackerFrame:SetFrameStrata("LOW")
  trackerFrame.lootWishlistCollapsed = false
  trackerFrame.lootWishlistStandaloneHidden = false

  trackerFrame.topHeader = CreateFrame("Frame", nil, trackerFrame, "ObjectiveTrackerContainerHeaderTemplate")
  trackerFrame.topHeader:SetPoint("TOPLEFT", trackerFrame, "TOPLEFT", 0, STANDALONE_HEADER_OFFSET_Y)
  trackerFrame.topHeader:SetPoint("TOPRIGHT", trackerFrame, "TOPRIGHT", 0, STANDALONE_HEADER_OFFSET_Y)
  trackerFrame.topHeader:SetHeight(HEADER_HEIGHT)
  trackerFrame.topHeaderText = trackerFrame.topHeader.Text or trackerFrame.topHeader.HeaderText
  trackerFrame.topHeaderMinimizeButton = trackerFrame.topHeader.MinimizeButton or trackerFrame.topHeader.CollapseButton
  trackerFrame.topHeaderButtonAtlases = nil

  trackerFrame.headerFrame = CreateFrame("Frame", nil, trackerFrame, "ObjectiveTrackerModuleHeaderTemplate")
  trackerFrame.headerFrame:SetHeight(HEADER_HEIGHT)

  trackerFrame.headerText = trackerFrame.headerFrame.Text or trackerFrame.headerFrame.HeaderText
  trackerFrame.headerMinimizeButton = trackerFrame.headerFrame.MinimizeButton
  trackerFrame.contentFrame = CreateFrame("Frame", nil, trackerFrame)

  if trackerFrame.topHeader and trackerFrame.topHeader.SetCollapsed and trackerFrame.topHeaderMinimizeButton and
      trackerFrame.topHeaderMinimizeButton.GetNormalTexture and trackerFrame.topHeaderMinimizeButton.GetPushedTexture then
    local normalTexture = trackerFrame.topHeaderMinimizeButton:GetNormalTexture()
    local pushedTexture = trackerFrame.topHeaderMinimizeButton:GetPushedTexture()
    if normalTexture and pushedTexture and normalTexture.GetAtlas and pushedTexture.GetAtlas then
      trackerFrame.topHeader:SetCollapsed(false)
      trackerFrame.topHeaderButtonAtlases = {
        expanded = {
          normal = normalTexture:GetAtlas(),
          pushed = pushedTexture:GetAtlas(),
        },
        collapsed = {},
      }

      trackerFrame.topHeader:SetCollapsed(true)
      trackerFrame.topHeaderButtonAtlases.collapsed.normal = normalTexture:GetAtlas()
      trackerFrame.topHeaderButtonAtlases.collapsed.pushed = pushedTexture:GetAtlas()

      trackerFrame.topHeader:SetCollapsed(false)
      trackerFrame.lootWishlistStandaloneHidden = false
      applyStandaloneHeaderButtonState(trackerFrame)
    end
  end

  trackerFrame.topHeaderButton = CreateFrame("Button", nil, trackerFrame.topHeader)
  trackerFrame.topHeaderButton:SetPoint("TOPLEFT", trackerFrame.topHeader, "TOPLEFT", 0, 0)
  trackerFrame.topHeaderButton:SetPoint("BOTTOMLEFT", trackerFrame.topHeader, "BOTTOMLEFT", 0, 0)
  if trackerFrame.topHeaderMinimizeButton then
    trackerFrame.topHeaderButton:SetPoint("RIGHT", trackerFrame.topHeaderMinimizeButton, "LEFT", 0, 0)
  else
    trackerFrame.topHeaderButton:SetPoint("TOPRIGHT", trackerFrame.topHeader, "TOPRIGHT", 0, 0)
    trackerFrame.topHeaderButton:SetPoint("BOTTOMRIGHT", trackerFrame.topHeader, "BOTTOMRIGHT", 0, 0)
  end
  trackerFrame.topHeaderButton:RegisterForClicks("LeftButtonUp")
  trackerFrame.topHeaderButton:SetScript("OnClick", function()
    setStandaloneCollapse(trackerFrame, not trackerFrame.lootWishlistStandaloneHidden)
    syncTrackerFrame()
  end)

  if trackerFrame.topHeaderMinimizeButton then
    trackerFrame.topHeaderMinimizeButton:SetScript("OnClick", function()
      setStandaloneCollapse(trackerFrame, not trackerFrame.lootWishlistStandaloneHidden)
      syncTrackerFrame()
    end)
  end

  trackerFrame.headerButton = CreateFrame("Button", nil, trackerFrame.headerFrame)
  trackerFrame.headerButton:SetPoint("TOPLEFT", trackerFrame.headerFrame, "TOPLEFT", 0, 0)
  trackerFrame.headerButton:SetPoint("BOTTOMLEFT", trackerFrame.headerFrame, "BOTTOMLEFT", 0, 0)
  if trackerFrame.headerMinimizeButton then
    trackerFrame.headerButton:SetPoint("RIGHT", trackerFrame.headerMinimizeButton, "LEFT", 0, 0)
  else
    trackerFrame.headerButton:SetPoint("TOPRIGHT", trackerFrame.headerFrame, "TOPRIGHT", 0, 0)
    trackerFrame.headerButton:SetPoint("BOTTOMRIGHT", trackerFrame.headerFrame, "BOTTOMRIGHT", 0, 0)
  end
  trackerFrame.headerButton:RegisterForClicks("LeftButtonUp")
  trackerFrame.headerButton:SetScript("OnClick", function()
    setWishlistCollapse(trackerFrame, not trackerFrame.lootWishlistCollapsed)
    syncTrackerFrame()
  end)

  if trackerFrame.headerMinimizeButton then
    trackerFrame.headerMinimizeButton:SetScript("OnClick", function()
      setWishlistCollapse(trackerFrame, not trackerFrame.lootWishlistCollapsed)
      syncTrackerFrame()
    end)
    applyCollapseButtonState(trackerFrame.headerMinimizeButton, false)
  end

  namespace.trackerFrame = trackerFrame
  hookTrackerState()
  syncTrackerFrame()
end

function TrackerUI.Refresh(namespace, groups)
  if not trackerFrame then
    TrackerUI.Initialize(namespace)
  end

  if not trackerFrame then
    return
  end

  currentGroups = groups or {}
  syncTrackerFrame()
end

local _, namespace = ...
if type(namespace) == "table" then
  namespace.TrackerUI = TrackerUI
end

return TrackerUI
