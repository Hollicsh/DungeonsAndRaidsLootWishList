local LootEvents = {}

local function findRollFrameById(rollID)
  local maxFrames = NUM_GROUP_LOOT_FRAMES or 4
  for index = 1, maxFrames do
    local frame = _G["GroupLootFrame" .. index]
    if frame and frame.rollID == rollID then
      return frame
    end
  end

  return nil
end

function LootEvents.HandleStartLootRoll(namespace, rollID)
  if type(GetLootRollItemLink) ~= "function" then
    return
  end

  local itemLink = GetLootRollItemLink(rollID)
  local itemID = namespace.ItemResolver.getItemIdFromLink(itemLink)
  if not itemID or not namespace.IsTrackedItem(itemID) then
    return
  end

  local frame = findRollFrameById(rollID)
  if not frame then
    return
  end

  frame.LootWishListTag = frame.LootWishListTag or frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  frame.LootWishListTag:SetPoint("TOP", frame, "TOP", 0, -6)
  frame.LootWishListTag:SetText(namespace.GetText("WISHLIST"))
  frame.LootWishListTag:Show()
end

function LootEvents.HandleChatLoot(namespace, message, playerName)
  if type(message) ~= "string" then
    return
  end

  local itemLink = message:match("(|Hitem:.-|h.-|h)")
  local itemID = namespace.ItemResolver.getItemIdFromLink(itemLink)
  if not itemID or not namespace.IsTrackedItem(itemID) then
    return
  end

  local player = playerName and Ambiguate(playerName, "short") or nil
  local selfName = UnitName("player")
  if player and selfName and player == selfName then
    return
  end

  if player and itemLink then
    namespace.ShowAlert(namespace.GetText("OTHER_PLAYER_LOOTED", player, itemLink))
  else
    namespace.ShowAlert(message)
  end
end

local _, namespace = ...
if type(namespace) == "table" then
  namespace.LootEvents = LootEvents
end

return LootEvents
