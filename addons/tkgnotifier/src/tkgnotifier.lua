---
-- 何かを通知してくれるアドオン.

--- @field acutil.
local acutil = require("acutil")

---
-- アドオン概要.
-- @field name アドオン名.
-- @field author 作者名.
-- @field version バージョン.
-- @table Addon
local Addon = {
  name = "TKGNOTIFIER",
  author = "TOKAGEEL",
  version = "0.0.2"
}

-- グローバルスコープへの格納.
_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][Addon.author] = _G["ADDONS"][Addon.author] or {}
_G["ADDONS"][Addon.author][Addon.name] = _G["ADDONS"][Addon.author][Addon.name] or {}
local g = _G["ADDONS"][Addon.author][Addon.name]
-- デバッグ機能の有無.
local debugIsEnabled = false
-- 通知スタック.
local stack = {}

---
-- 指定した文字列をシステムログとしてチャットウィンドウへ出力する.
-- @param message 出力する文字列.
local function log(message)
  if debugIsEnabled then
    CHAT_SYSTEM(string.format("[TKGNOTIFIER] %s", tostring(message)), "616161")
  end
end

---
-- このアドオンのバージョン情報をシステムメッセージとして出力する.
function TKGNOTIFIER_PRINT_VERSION()
  CHAT_SYSTEM(string.format("%s - v%s", Addon.name, tostring(Addon.version)), "616161")
end

---
-- 指定したアイコンと文字列を使用して通知ウィンドウを表示する.
-- @param icon 表示するアイコン.
-- @param message 表示する文字列.
function TKGNOTIFIER_NOTIFY(icon, message)
  log("TKGNOTIFIER_NOTIFY(icon, message)")
  -- アイコンの指定が誤っている場合はデフォルトアイコン
  if (icon == nil) or (type(icon) ~= "string") then
    icon = "news_btn"
  end
  message = message or ""
  if (type(message) ~= "string") then
    message = tostring(message)
  end

  table.insert(stack, { icon=icon, message=message })
  TKGNOTIFIER_FRAME_ON_STACK_CHANGED(stack)
end

---
-- 指定したアイコンと文字列を使用して通知ウィンドウを表示する.
-- @param icon 表示するアイコン.
-- @param message 表示する文字列.
-- @param kind 通知種別. 同一の通知種別の通知がスタック上に存在する場合、後発の通知で上書きする.
function TKGNOTIFIER_NOTIFY(icon, message, kind)
  log("TKGNOTIFIER_NOTIFY(icon, message, kind)")
  -- 種別の指定がない場合は単純に通知
  if (kind == nil) then
    TKGNOTIFIER_NOTIFY(icon, message)
    return
  end

  -- 同一種別の通知をスタックから取り除く
  for index, notification in pairs(stack) do
    if (kind == notification.kind) then
      table.remove(stack, index)
      break
    end
  end
  table.insert(stack, { icon=icon, message=message, kind=kind })
  TKGNOTIFIER_FRAME_ON_STACK_CHANGED(stack)
end

---
-- 直近の通知を削除する.
function TKGNOIFIER_POP()
  log("TKGNOTIFIER_POP")
  table.remove(stack)
  TKGNOTIFIER_FRAME_ON_STACK_CHANGED(stack)
end

---
-- アドオン初期化処理.
-- フレームワークからの呼び出しを期待しているため、直接呼び出さないこと.
-- @param addon アドオン.
-- @param frame アドオンのフレーム.
function TKGNOTIFIER_ON_INIT(addon, frame)
  log("TKGNOTIFIER_ON_INIT")
  g.addon = addon
  g.frame = frame

  -- 設定読み込み
  if not g.loaded then
    -- デフォルト設定
    g.settings = {}
    log("loadJSON")
    settingsFilePath = string.format("../addons/%s/settings.json", string.lower(Addon.name))
    local settings, err = acutil.loadJSON(settingsFilePath, g.settings)
    if not err then
      g.settings = settings
    else
      log(tostring(err))
    end
    TKGNOTIFIER_PRINT_VERSION()
  end

  -- 関連機能へ設定値を通知
  TKGNOTIFIER_FRAME_INIT(g.settings)
  TKGNOTIFIER_MAIL_INIT(g.settings)

  g.loaded = true
end
