local Locales = {}

local translations = {
  enUS = {
    LOOT_WISHLIST = "Loot Wishlist",
    WISHLIST = "Wishlist",
    OTHER = "Other",
    OTHER_PLAYER_LOOTED = "%s looted %s",
  },
  enGB = {
    LOOT_WISHLIST = "Loot Wishlist",
    WISHLIST = "Wishlist",
    OTHER = "Other",
    OTHER_PLAYER_LOOTED = "%s looted %s",
  },
  deDE = {
    LOOT_WISHLIST = "Beuteliste",
    WISHLIST = "Wunschliste",
    OTHER = "Sonstiges",
    OTHER_PLAYER_LOOTED = "%s hat %s gepluendert",
  },
  esES = {
    LOOT_WISHLIST = "Lista de botin deseado",
    WISHLIST = "Lista de deseos",
    OTHER = "Otros",
    OTHER_PLAYER_LOOTED = "%s ha saqueado %s",
  },
  esMX = {
    LOOT_WISHLIST = "Lista de botin deseado",
    WISHLIST = "Lista de deseos",
    OTHER = "Otros",
    OTHER_PLAYER_LOOTED = "%s ha saqueado %s",
  },
  frFR = {
    LOOT_WISHLIST = "Liste de butin",
    WISHLIST = "Liste de souhaits",
    OTHER = "Autre",
    OTHER_PLAYER_LOOTED = "%s a obtenu %s",
  },
  itIT = {
    LOOT_WISHLIST = "Lista bottino desiderato",
    WISHLIST = "Lista dei desideri",
    OTHER = "Altro",
    OTHER_PLAYER_LOOTED = "%s ha ottenuto %s",
  },
  koKR = {
    LOOT_WISHLIST = "loot wishlist",
    WISHLIST = "wishlist",
    OTHER = "other",
    OTHER_PLAYER_LOOTED = "%s looted %s",
  },
  ptBR = {
    LOOT_WISHLIST = "Lista de Saque Desejado",
    WISHLIST = "Lista de Desejos",
    OTHER = "Outros",
    OTHER_PLAYER_LOOTED = "%s saqueou %s",
  },
  ruRU = {
    LOOT_WISHLIST = "spisok dobychi",
    WISHLIST = "spisok zhelaniy",
    OTHER = "drugoe",
    OTHER_PLAYER_LOOTED = "%s poluchil %s",
  },
  zhCN = {
    LOOT_WISHLIST = "loot wishlist",
    WISHLIST = "wishlist",
    OTHER = "other",
    OTHER_PLAYER_LOOTED = "%s looted %s",
  },
  zhTW = {
    LOOT_WISHLIST = "loot wishlist",
    WISHLIST = "wishlist",
    OTHER = "other",
    OTHER_PLAYER_LOOTED = "%s looted %s",
  },
}

function Locales.getSupportedLocales()
  local localeIds = {}

  for localeId in pairs(translations) do
    table.insert(localeIds, localeId)
  end

  table.sort(localeIds)

  return localeIds
end

function Locales.getLocale(localeId)
  return translations[localeId] or translations.enUS
end

function Locales.getString(localeId, key, ...)
  local locale = Locales.getLocale(localeId)
  local value = locale[key] or translations.enUS[key] or key

  if select("#", ...) > 0 then
    return string.format(value, ...)
  end

  return value
end

local _, namespace = ...
if type(namespace) == "table" then
  namespace.Locales = Locales
end

return Locales
