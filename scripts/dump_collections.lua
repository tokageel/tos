--[[
dump_collections.lua

登録していないコレクションアイテムについてtosbaseのURLを出力するスクリプト.
UIをもたないのでコンソールからdofile()で実行すること.
--]]
local BASE_ITEM_URL = "https://tos-jp.neet.tv/items"
local DUMP_FILE_PATH = "../dump_collection.txt"

--- タイムスタンプの文字列表現を返す.
-- @return タイムスタンプの文字列表現.
local function getCurrentTimeString()
  local now = os.date('*t')
  return string.format("%04d/%02d/%02d %02d:%02d:%02d",
    now['year'], now['month'], now['day'],
    now['hour'], now['min'], now['sec'])
end

--- コレクション情報を収集する.
-- 収集対象とするのは、コレクション画面に表示されるものかつ完成状態ではないもの.
-- 返却値は以下の形式.
--[[
[
  {
    name: string コレクション名（dictID_XXX形式）
    count: number コレクション対象のアイテムの数
    remain: number コレクション対象のアイテムのうち、未収集のアイテムの数
    items: [
      {
        id: number tosbase上のID
        name: string アイテム名（dictID_XXX形式）
      },
      {...}
    ]
  },
  {...}
]
--]]
-- @return コレクション情報.
local function scanCollections()
  local collectionClasses, collectionClassCount = GetClassList("Collection")
  local pc = session.GetMySession()
  local collectionList = pc:GetCollection()
  local etcObject = GetMyEtcObject()
  local remainCollections = {}

  -- コレクションを走査
  for i = 0, (collectionClassCount - 1) do
    local collectionClass = GetClassByIndexFromList(collectionClasses, i)
    local collection = collectionList:Get(collectionClass.ClassID)
    local collectionInfo = GET_COLLECTION_INFO(collectionClass, collection, etcObject, {})

    -- 冒険日誌の対象かつ収集完了状態ではないコレクションを対象とする
    if ((collectionClass.Journal == "TRUE") and (collectionInfo.status ~= 2)) then
      -- コレクション名と収集状況を格納
      local currentCount, collectionCount = GET_COLLECTION_COUNT(collectionClass.ClassID, collection)
      remainCollection = {}
      remainCollection.name = collectionInfo.name
      remainCollection.count = collectionCount
      remainCollection.remain = (collectionCount - currentCount)

      -- コレクション内のアイテムを走査
      remainCollection.items = {}
      for j = 0, (collectionCount -1) do
        local itemName = TryGetProp(collectionClass, "ItemName_" .. (j + 1))
        local itemClass = GetClass("Item", itemName)
        local itemClassId = itemClass.ClassID
        if ((collection == nil) or (collection:GetItemCountByType(itemClassId) == 0)) then
          -- (Workaround) 製造書のアイテムIDをURL向けに変換する
          -- 製造書-ロングスポントゥーンのClassIDには927033が格納されてくるが、URLとしての期待値は7127033
          -- 差分の6200000加算してうまく動くことを祈ろう
          if (itemClass.GroupName == "Recipe") then
            itemClassId = itemClassId + 6200000
          end
          remainCollection.items[j] = {
            id = itemClassId,
            name = itemClass.Name
          }
        end
      end

      remainCollections[i] = remainCollection
    end
  end

  return remainCollections
end

-- アイテム1件分の文字列表現を返す.
-- @param item 文字列化するアイテム.
-- @return 引数で指定したアイテムの文字列表現.
local function itemToString(item)
  return string.format("  %s - %s/%d\n",
   dictionary.ReplaceDicIDInCompStr(item.name),
   BASE_ITEM_URL,
   item.id)
end

--- コレクション1件分の文字列表現を返す.
-- @param collection 文字列化するコレクション.
-- @return 引数で指定したコレクションの文字列表現.
local function collectionToString(collection)
  local str = string.format("%s (%d / %d)\n",
   dictionary.ReplaceDicIDInCompStr(collection.name),
   collection.remain, collection.count)
   for index, item in pairs(collection.items) do
    str = str .. itemToString(item)
  end
  return str
end

--- エントリポイント.
local function main()
  -- コレクション情報を収集
  local collections = scanCollections()

  -- ファイル出力
  local file, err = io.open(DUMP_FILE_PATH, "a")
  if (not file) then
    print("[ERROR] cannot open dump file")
  else
    local header = string.format("----------\nDate: %s\n----------", getCurrentTimeString())
    local result, msg, code = file:write((header), "\n")
    if result then
      for index, collection in pairs(collections) do
        local body = collectionToString(collection)
        local result, msg, code = file:write((body), "\n")
        if (not result) then
          print(string.format("[ERROR] %s (code=%d)", msg, code))
          break;
        end
      end
    else
      print(string.format("[ERROR] %s (code=%d)", msg, code))
    end
    file:flush()
    file:close()
  end
end

main()
