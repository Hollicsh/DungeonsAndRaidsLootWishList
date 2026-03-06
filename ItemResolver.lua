local ItemResolver = {}

function ItemResolver.getWishlistKey(itemData)
  if itemData == nil then
    return nil
  end

  local itemId = itemData.itemID or itemData.itemId or itemData.id
  if itemId == nil then
    return nil
  end

  return "item:" .. tostring(itemId)
end

function ItemResolver.getItemIdFromLink(itemLink)
  if type(itemLink) ~= "string" then
    return nil
  end

  local itemId = itemLink:match("item:(%d+)")
  if itemId == nil then
    return nil
  end

  return tonumber(itemId)
end

function ItemResolver.normalizeItemData(itemData)
  if itemData == nil then
    return nil
  end

  local itemId = itemData.itemID or itemData.itemId or ItemResolver.getItemIdFromLink(itemData.itemLink)
  if itemId == nil then
    return nil
  end

  return {
    itemID = itemId,
    wishlistKey = ItemResolver.getWishlistKey({ itemID = itemId }),
    itemLink = itemData.itemLink,
    itemName = itemData.itemName,
    itemLevel = itemData.itemLevel,
    instanceName = itemData.instanceName,
  }
end

local _, namespace = ...
if type(namespace) == "table" then
  namespace.ItemResolver = ItemResolver
end

return ItemResolver
