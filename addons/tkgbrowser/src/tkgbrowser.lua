---
-- tkgbrowser.lua
-- 冒険日誌のコレクション画面から規定のブラウザを起動する機能を提供するアドオン.

-- ############################################################################
-- ユーティリティ
-- ############################################################################

--- @field acutil.
local acutil = require("acutil")
--- @field クラスID指定のURL.
local DEFAULT_QUERY_ITEM_URL = "https://tos-jp.neet.tv/items/%s"
--- @field アイテムアイコンのUserValueキー: アイテムのクラスID.
local USER_VALUE_KEY_ITEM_ID = "ITEM_ID"

---
-- アドオン概要.
-- @field name アドオン名.
-- @field author 作者名.
-- @field version バージョン.
-- @table Addon
local Addon = {
  name = "TKGBROWSER",
  author = "TOKAGEEL",
  version = "0.0.1"
}

---
-- 表示設定.
-- @field colorWarnings 通常システムメッセージ文字色.
-- @table Appearances
local Appearances = {
  colorWarnings = "616161"
}

---
-- 指定した文字列をシステムログとしてチャットウィンドウへ出力する.
-- @param message 出力する文字列.
local function log(message)
  if message == nil then
    message = "nil"
  elseif (type(message) ~= "string") then
    message = tostring(message)
  end

  CHAT_SYSTEM(string.format("[%s] %s", Addon.name, message), Appearances.colorWarnings)
end

---
-- バージョン出力.
local function printVersionMessage()
  log(string.format("%s - v%s", Addon.name, tostring(Addon.version)))
end

-- ############################################################################
-- アドオン制御
-- ############################################################################

-- グローバルスコープへの格納.
_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][Addon.author] = _G["ADDONS"][author] or {}
_G["ADDONS"][Addon.author][Addon.name] = _G["ADDONS"][Addon.author][Addon.name] or {}
local g = _G["ADDONS"][Addon.author][Addon.name]
g.settingsFilePath = string.format("../addons/%s/settings.json", string.lower(Addon.name))

-- デフォルト設定
if not g.loaded then
  g.settings = {
    base_url_item = DEFAULT_QUERY_ITEM_URL
  }
end

---
-- 指定したコレクション名に対応するコレクションアイテムのClassIDを返す.
-- @param collectionName コレクション名.
-- @return 指定したコレクション名に対応するコレクションアイテムのClassID. 存在しないコレクション名を指定した場合はnil.
function TKGBROWSER_SEARCH_COLLECTION_ITEM_CLASS_ID(collectionName)
  -- 引数チェック
  if (collectionName == nil) then
    return nil
  end

  -- コレクション一覧走査
  local classes, count = GetClassList("Collection")
  for i = 0, (count - 1) do
    local class = GetClassByIndexFromList(classes, i)
    if ((class ~= nil) and (class.Name == collectionName)) then
      local itemClass = GetClass("Item", class.ClassName)
      if itemClass then
        return itemClass.ClassID
      end
    end
  end

  return nil
end

---
-- アイテムクラスIDを指定してWindows規定のブラウザを起動する.
-- @param itemClassId アイテムクラスID.
function TKGBROWSER_OPEN_BROWSER(itemClassId)
  if itemClassId then
    pcall(
      function()
        local url = string.format(g.settings.base_url_item, itemClassId)
        os.execute("START " .. url)
      end
    )
  end
end

---
-- 指定した文字列をacutilで扱える文字列へエンコードして返す.
-- @param src 元の文字列.
-- @return エンコードされた文字列.
-- @see TKGBROWSER_DECODE
function TKGBROWSER_ENCODE(src)
  -- 少なくとも"/"は扱えないようなので"$"に置換する
  return string.gsub(src, "/", "$")
end

---
-- 指定したエンコード済み文字列をデコードして返す.
-- @param src エンコード済みの文字列.
-- @return デコードされた文字列.
-- @see TKGBROWSER_ENCODE
function TKGBROWSER_DECODE(src)
  -- TKGBROWSER_ENCODE()の逆変換となるように実装すること
  return string.gsub(src, "%$", "/")
end

---
-- コレクション名のクリックハンドラ.
-- 直接呼び出さないこと.
-- @param parent 親ウィジェット.
-- @param ctrl 対象ウィジェット.
function TKGBROWSER_ON_CLICKED_COLLECTION_NAME(parent, ctrl)
  local nameText = GET_CHILD_RECURSIVELY(parent, "collectionNameText")
  local name = nameText:GetTextByKey("name")
  local classId = TKGBROWSER_SEARCH_COLLECTION_ITEM_CLASS_ID(name)
  if classId then
    TKGBROWSER_OPEN_BROWSER(classId)
  end
end

---
-- コレクションアイテムアイコンのクリックハンドラ.
-- 直接呼び出さないこと.
-- @param parent 親ウィジェット.
-- @param ctrl 対象ウィジェット.
function TKGBROWSER_ON_CLICKED_COLLECTION_ITEM_ICON(parent, ctrl)
  local itemId = ctrl:GetUserValue(USER_VALUE_KEY_ITEM_ID)
  if (itemId and (itemId ~= "None")) then
    TKGBROWSER_OPEN_BROWSER(itemId)
  end
end

---
-- 冒険日誌のコレクション選択時のハンドラ.
-- ADVENTURE_BOOK_COLLECTION_DETAILのフックとして動作することを想定している.
-- 直接呼び出さないこと.
-- @param frame アドオンフレーム.
-- @param message イベントメッセージ.
function TKGBROWSER_ON_RELOADED_COLLECTION_DETAIL(frame, message)
  local parent, ctrl = acutil.getEventArgs(message)

  -- コレクションIDを元にコレクションクラスを取得
  local collectionId = parent:GetUserIValue("COLLECTION_ID")
  local collectionClass = GetClassByType('Collection', collectionId);
  if collectionClass == nil then
    return
  end

  -- コレクションアイテムののアイコンに対してUserValueを設定してクリックハンドラを設定
  local frame = ui.GetFrame("adventure_book")
  local collectionItemBox = GET_CHILD_RECURSIVELY(frame, "collectionItemBox")
  local collectionItemSetCount = collectionItemBox:GetChildCount()
  for i = 1, collectionItemSetCount do
      local itemClass = GetClass("Item", collectionClass["ItemName_" .. i])
      if itemClass then
        local itemClassId = TKGBROWSER_GET_ITEM_CLASS_ID(itemClass)
        local controlSet = collectionItemBox:GetChildByIndex(i)
        local itemPic = GET_CHILD(controlSet, "itemPic")
        if itemPic then
          itemPic:SetUserValue(USER_VALUE_KEY_ITEM_ID, itemClassId)
          itemPic:SetEventScript(ui.LBUTTONUP, "TKGBROWSER_ON_CLICKED_COLLECTION_ITEM_ICON")
        end
      end
  end
end

---
-- 指定したアイテムのURL向けIDを返す.
-- @param itemClass アイテムクラス（非nil）.
-- @return URL向けのアイテムID.
function TKGBROWSER_GET_ITEM_CLASS_ID(itemClass)
  local itemId = itemClass.ClassID
  local isTosbase = (string.find(g.settings.base_url_item, "^https://[^/]+\.neet\.tv/") ~= nil)
  if (isTosbase and (itemClass.GroupName == "Recipe")) then
    itemId = itemId + 6200000
  end
  return itemId
end

---
-- アドオン初期化処理.
-- @param addon アドオン.
-- @param frame アドオンのフレーム.
function TKGBROWSER_ON_INIT(addon, frame)
  g.addon = addon
  g.frame = frame

  -- 設定読み込み
  if not g.loaded then
    g.settings.base_url_item = TKGBROWSER_ENCODE(g.settings.base_url_item)
    local settings, err = acutil.loadJSON(g.settingsFilePath, g.settings)
    if not err then
      g.settings = settings
    end
    g.settings.base_url_item = TKGBROWSER_DECODE(g.settings.base_url_item)

    g.loaded = true
    printVersionMessage()
  end

  -- 冒険日誌フレーム
  local frame = ui.GetFrame("adventure_book")
  -- 右ペインのコレクション名のクリックハンドラを設定
  local collectionNameBox = GET_CHILD_RECURSIVELY(frame, "collectionNameBox")
  collectionNameBox:SetEventScript(ui.LBUTTONUP, "TKGBROWSER_ON_CLICKED_COLLECTION_NAME")
  local collectionNameText = GET_CHILD_RECURSIVELY(frame, "collectionNameText")
  collectionNameText:SetEventScript(ui.LBUTTONUP, "TKGBROWSER_ON_CLICKED_COLLECTION_NAME")

  -- 右ペインのアイテム一覧は左ペインでコレクションを選択するたびに毎回ウィジェットが再生成されるため、
  -- 左ペインのコレクション選択時に右ペインのアイテム名クリックハンドラを再設定する
  acutil.setupEvent(addon, "ADVENTURE_BOOK_COLLECTION_DETAIL", "TKGBROWSER_ON_RELOADED_COLLECTION_DETAIL")
end
