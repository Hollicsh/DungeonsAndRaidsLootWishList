local SourceResolver = {}

SourceResolver.OTHER_GROUP = "Other"

function SourceResolver.getGroupLabel(itemData)
  if itemData == nil then
    return SourceResolver.OTHER_GROUP
  end

  local instanceName = itemData.instanceName or itemData.currentInstanceName or itemData.sourceName or itemData.instance
  if type(instanceName) ~= "string" or instanceName == "" then
    return SourceResolver.OTHER_GROUP
  end

  return instanceName
end

local _, namespace = ...
if type(namespace) == "table" then
  namespace.SourceResolver = SourceResolver
end

return SourceResolver
