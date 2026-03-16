local Locales = {}

local translations = {
  enUS = {
    LOOT_WISHLIST = "Loot Wishlist",
    WISHLIST = "Wishlist",
    OTHER = "Other",
    LOOT_SOURCE = "Source",
    EQUIPMENT_SLOT = "Slot",
    DROPS_FROM = "Drops from: %s",
    DROPS_FROM_RAID = "Drops from: %s - %s",
    PLAYER_LOOTED_WISHLIST_ITEM = "%s looted an item on your Wishlist!",
  },
  enGB = {
    LOOT_WISHLIST = "Loot Wishlist",
    WISHLIST = "Wishlist",
    OTHER = "Other",
    LOOT_SOURCE = "Source",
    EQUIPMENT_SLOT = "Slot",
    DROPS_FROM = "Drops from: %s",
    DROPS_FROM_RAID = "Drops from: %s - %s",
    PLAYER_LOOTED_WISHLIST_ITEM = "%s looted an item on your Wishlist!",
  },
  deDE = {
    LOOT_WISHLIST = "Beuteliste",
    WISHLIST = "Wunschliste",
    OTHER = "Sonstiges",
    LOOT_SOURCE = "Quelle",
    EQUIPMENT_SLOT = "Slot",
    DROPS_FROM = "Droppt in: %s",
    DROPS_FROM_RAID = "Droppt in: %s - %s",
    PLAYER_LOOTED_WISHLIST_ITEM = "%s hat einen Gegenstand von deiner Wunschliste erbeutet!",
  },
  esES = {
    LOOT_WISHLIST = "Lista de botin deseado",
    WISHLIST = "Lista de deseos",
    OTHER = "Otros",
    LOOT_SOURCE = "Fuente",
    EQUIPMENT_SLOT = "Ranura",
    DROPS_FROM = "Cae en: %s",
    DROPS_FROM_RAID = "Cae en: %s - %s",
    PLAYER_LOOTED_WISHLIST_ITEM = "¡%s ha saqueado un objeto de tu lista de deseos!",
  },
  esMX = {
    LOOT_WISHLIST = "Lista de botin deseado",
    WISHLIST = "Lista de deseos",
    OTHER = "Otros",
    LOOT_SOURCE = "Fuente",
    EQUIPMENT_SLOT = "Ranura",
    DROPS_FROM = "Cae en: %s",
    DROPS_FROM_RAID = "Cae en: %s - %s",
    PLAYER_LOOTED_WISHLIST_ITEM = "¡%s ha saqueado un objeto de tu lista de deseos!",
  },
  frFR = {
    LOOT_WISHLIST = "Liste de butin",
    WISHLIST = "Liste de souhaits",
    OTHER = "Autre",
    LOOT_SOURCE = "Source",
    EQUIPMENT_SLOT = "Slot",
    DROPS_FROM = "Tombe sur : %s",
    DROPS_FROM_RAID = "Tombe sur : %s - %s",
    PLAYER_LOOTED_WISHLIST_ITEM = "%s a obtenu un objet de votre liste de souhaits !",
  },
  itIT = {
    LOOT_WISHLIST = "Lista bottino desiderato",
    WISHLIST = "Lista dei desideri",
    OTHER = "Altro",
    LOOT_SOURCE = "Fonte",
    EQUIPMENT_SLOT = "Slot",
    DROPS_FROM = "Droppa da: %s",
    DROPS_FROM_RAID = "Droppa da: %s - %s",
    PLAYER_LOOTED_WISHLIST_ITEM = "%s ha ottenuto un oggetto dalla tua lista dei desideri!",
  },
  koKR = {
    LOOT_WISHLIST = "전리품 위시리스트",
    WISHLIST = "위시리스트",
    OTHER = "기타",
    LOOT_SOURCE = "출처",
    EQUIPMENT_SLOT = "슬롯",
    DROPS_FROM = "획득처: %s",
    DROPS_FROM_RAID = "획득처: %s - %s",
    PLAYER_LOOTED_WISHLIST_ITEM = "%s님이 위시리스트에 있는 아이템을 전리품으로 획득했습니다!",
  },
  ptBR = {
    LOOT_WISHLIST = "Lista de Saque Desejado",
    WISHLIST = "Lista de Desejos",
    OTHER = "Outros",
    LOOT_SOURCE = "Fonte",
    EQUIPMENT_SLOT = "Slot",
    DROPS_FROM = "Cai em: %s",
    DROPS_FROM_RAID = "Cai em: %s - %s",
    PLAYER_LOOTED_WISHLIST_ITEM = "%s saqueou um item da sua Lista de Desejos!",
  },
  ruRU = {
    LOOT_WISHLIST = "spisok dobychi",
    WISHLIST = "spisok zhelaniy",
    OTHER = "drugoe",
    LOOT_SOURCE = "Источник",
    EQUIPMENT_SLOT = "Slot",
    DROPS_FROM = "Padaet iz: %s",
    DROPS_FROM_RAID = "Padaet iz: %s - %s",
    PLAYER_LOOTED_WISHLIST_ITEM = "%s poluchil predmet iz vashego spiska zhelaniy!",
  },
  zhCN = {
    LOOT_WISHLIST = "战利品心愿单",
    WISHLIST = "心愿单",
    OTHER = "其他",
    LOOT_SOURCE = "来源",
    EQUIPMENT_SLOT = "栏位",
    DROPS_FROM = "掉落自：%s",
    DROPS_FROM_RAID = "掉落自：%s - %s",
    PLAYER_LOOTED_WISHLIST_ITEM = "%s 拾取了您愿望清单上的一件物品！",
  },
  zhTW = {
    LOOT_WISHLIST = "戰利品願望清單",
    WISHLIST = "願望清單",
    OTHER = "其他",
    LOOT_SOURCE = "來源",
    EQUIPMENT_SLOT = "欄位",
    DROPS_FROM = "掉落自：%s",
    DROPS_FROM_RAID = "掉落自：%s - %s",
    PLAYER_LOOTED_WISHLIST_ITEM = "%s 拾取了您願望清單上的一件物品！",
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
