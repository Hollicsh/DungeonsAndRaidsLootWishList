local WishlistStore = {}

local function normalizeItemId(itemId)
  if itemId == nil then
    return nil
  end

  return tostring(itemId)
end

function WishlistStore.ensureCharacter(db, characterKey)
  db.characters = db.characters or {}
  db.characters[characterKey] = db.characters[characterKey] or { items = {} }
  db.characters[characterKey].items = db.characters[characterKey].items or {}

  return db.characters[characterKey]
end

function WishlistStore.getItemEntry(db, characterKey, itemId)
  local character = WishlistStore.ensureCharacter(db, characterKey)
  local itemKey = normalizeItemId(itemId)

  if itemKey == nil then
    return nil
  end

  character.items[itemKey] = character.items[itemKey] or {}

  return character.items[itemKey]
end

function WishlistStore.getExistingItemEntry(db, characterKey, itemId)
  local character = WishlistStore.ensureCharacter(db, characterKey)
  local itemKey = normalizeItemId(itemId)

  if itemKey == nil then
    return nil
  end

  return character.items[itemKey]
end

function WishlistStore.setTracked(db, characterKey, itemId, tracked)
  local entry = WishlistStore.getItemEntry(db, characterKey, itemId)
  entry.tracked = tracked and true or false
end

function WishlistStore.setSourceLabel(db, characterKey, itemId, sourceLabel)
  local entry = WishlistStore.getItemEntry(db, characterKey, itemId)
  entry.sourceLabel = sourceLabel
end

function WishlistStore.setItemMetadata(db, characterKey, itemId, metadata)
  local entry = WishlistStore.getItemEntry(db, characterKey, itemId)

  if metadata.itemName ~= nil then
    entry.itemName = metadata.itemName
  end

  if metadata.itemLink ~= nil then
    entry.itemLink = metadata.itemLink
  end

  if metadata.sourceLabel ~= nil then
    entry.sourceLabel = metadata.sourceLabel
  end
end

function WishlistStore.getSourceLabel(db, characterKey, itemId)
  local entry = WishlistStore.getExistingItemEntry(db, characterKey, itemId)
  return entry and entry.sourceLabel or nil
end

function WishlistStore.isTracked(db, characterKey, itemId)
  local entry = WishlistStore.getExistingItemEntry(db, characterKey, itemId)
  return entry ~= nil and entry.tracked == true
end

function WishlistStore.updateBestLootedItemLevel(db, characterKey, itemId, itemLevel)
  local entry = WishlistStore.getItemEntry(db, characterKey, itemId)

  if itemLevel == nil then
    return entry.bestLootedItemLevel
  end

  if entry.bestLootedItemLevel == nil or itemLevel > entry.bestLootedItemLevel then
    entry.bestLootedItemLevel = itemLevel
  end

  return entry.bestLootedItemLevel
end

function WishlistStore.getBestLootedItemLevel(db, characterKey, itemId)
  local entry = WishlistStore.getExistingItemEntry(db, characterKey, itemId)
  return entry and entry.bestLootedItemLevel or nil
end

function WishlistStore.removeItem(db, characterKey, itemId)
  local character = WishlistStore.ensureCharacter(db, characterKey)
  local itemKey = normalizeItemId(itemId)

  if itemKey == nil then
    return
  end

  character.items[itemKey] = {
    tracked = false,
  }
end

function WishlistStore.getTrackedItems(db, characterKey)
  local character = WishlistStore.ensureCharacter(db, characterKey)
  local trackedItems = {}

  for itemKey, entry in pairs(character.items) do
    if entry.tracked == true then
      table.insert(trackedItems, {
        itemID = tonumber(itemKey) or itemKey,
      tracked = true,
      bestLootedItemLevel = entry.bestLootedItemLevel,
      sourceLabel = entry.sourceLabel,
      itemName = entry.itemName,
      itemLink = entry.itemLink,
      })
    end
  end

  table.sort(trackedItems, function(left, right)
    return tostring(left.itemID) < tostring(right.itemID)
  end)

  return trackedItems
end

local _, namespace = ...
if type(namespace) == "table" then
  namespace.WishlistStore = WishlistStore
end

return WishlistStore
