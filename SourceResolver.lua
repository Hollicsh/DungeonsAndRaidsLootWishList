local SourceResolver = {}

SourceResolver.OTHER_GROUP = "Other"
SourceResolver.OTHER_SOURCE_KEY = "source:other"
SourceResolver.OTHER_SLOT_KEY = "slot:other"

local SLOT_GROUPS = {
  INVTYPE_HEAD = { id = "head", sortIndex = 1 },
  INVTYPE_NECK = { id = "neck", sortIndex = 2 },
  INVTYPE_SHOULDER = { id = "shoulder", sortIndex = 3 },
  INVTYPE_CLOAK = { id = "back", sortIndex = 4 },
  INVTYPE_CHEST = { id = "chest", sortIndex = 5 },
  INVTYPE_ROBE = { id = "chest", sortIndex = 5 },
  INVTYPE_WRIST = { id = "wrist", sortIndex = 6 },
  INVTYPE_HAND = { id = "hands", sortIndex = 7 },
  INVTYPE_WAIST = { id = "waist", sortIndex = 8 },
  INVTYPE_LEGS = { id = "legs", sortIndex = 9 },
  INVTYPE_FEET = { id = "feet", sortIndex = 10 },
  INVTYPE_FINGER = { id = "rings", sortIndex = 11 },
  INVTYPE_TRINKET = { id = "trinkets", sortIndex = 12 },
  INVTYPE_2HWEAPON = { id = "two_hand", sortIndex = 13 },
  INVTYPE_WEAPONMAINHAND = { id = "main_hand", sortIndex = 14 },
  INVTYPE_WEAPON = { id = "main_hand", sortIndex = 14 },
  INVTYPE_WEAPONOFFHAND = { id = "off_hand", sortIndex = 15 },
  INVTYPE_SHIELD = { id = "off_hand", sortIndex = 15 },
  INVTYPE_HOLDABLE = { id = "off_hand", sortIndex = 15 },
}

local function normalizeMode(groupBy)
  return groupBy == "slot" and "slot" or "source"
end

local function getSourceLabel(itemData, otherLabel)
  if itemData == nil then
    return otherLabel
  end

  local instanceName = itemData.instanceName or itemData.currentInstanceName or itemData.sourceName or itemData.instance or
      itemData.sourceLabel
  if type(instanceName) ~= "string" or instanceName == "" then
    return otherLabel
  end

  return instanceName
end

local function getSlotLabel(itemData, otherLabel)
  if itemData == nil then
    return otherLabel
  end

  local slotLabel = itemData.slotLabel
  if type(slotLabel) == "string" and slotLabel ~= "" then
    return slotLabel
  end

  local inventoryType = itemData.inventoryType
  if type(inventoryType) == "string" and inventoryType ~= "" then
    return inventoryType
  end

  return otherLabel
end

local function normalizeSlotGroup(itemData)
  local inventoryType = itemData and itemData.inventoryType or nil
  if type(inventoryType) ~= "string" or inventoryType == "" or inventoryType == "INVTYPE_NON_EQUIP_IGNORE" then
    return nil
  end

  return SLOT_GROUPS[inventoryType]
end

function SourceResolver.getGroupLabel(itemData)
  return getSourceLabel(itemData, SourceResolver.OTHER_GROUP)
end

function SourceResolver.resolveGroup(groupBy, itemData, otherLabel)
  local mode = normalizeMode(groupBy)
  otherLabel = otherLabel or SourceResolver.OTHER_GROUP

  if mode == "slot" then
    local slotGroup = normalizeSlotGroup(itemData)
    local label = getSlotLabel(itemData, otherLabel)
    if slotGroup ~= nil then
      return {
        key = "slot:" .. slotGroup.id,
        label = label,
        mode = mode,
        sortIndex = slotGroup.sortIndex,
      }
    end

    return {
      key = SourceResolver.OTHER_SLOT_KEY,
      label = otherLabel,
      mode = mode,
      sortIndex = 999,
    }
  end

  local instanceID = itemData and itemData.instanceID or nil
  local label = getSourceLabel(itemData, otherLabel)
  if type(instanceID) == "number" and instanceID > 0 then
    return {
      key = "source:instance:" .. tostring(instanceID),
      label = label,
      mode = mode,
    }
  end

  if label ~= otherLabel then
    return {
      key = "source:label:" .. label,
      label = label,
      mode = mode,
    }
  end

  return {
    key = SourceResolver.OTHER_SOURCE_KEY,
    label = otherLabel,
    mode = mode,
  }
end

local _, namespace = ...
if type(namespace) == "table" then
  namespace.SourceResolver = SourceResolver
end

return SourceResolver
