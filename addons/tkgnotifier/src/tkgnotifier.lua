---
-- 何かを通知してくれるアドオン.

---
-- 通知ウィンドウに表示する情報.
-- @field icon 表示するアイコンの名称（string）.
-- 未指定またはnilを指定した場合はデフォルトのアイコンが使用されます.
-- @field message 表示する文字列（string）.
-- 未指定またはnilを指定した場合は空文字列が使用されます.
-- @field kind 通知種別（string）.
-- 同一の通知種別の通知がスタック上に存在する場合、後発の通知で上書きします.
-- 未指定またはnilを指定した場合は、それぞれを個別の通知として扱います.
-- @field action 通知を閉じた際のコールバック関数名（string）.
-- 未指定またはnilを指定した場合はコールバックしません.
-- 同一通知種別による通知で通知が上書きされた場合、先発の通知に対するコールバックは呼び出しません.
-- コールバック関数内から通知スタックを操作する関数は呼び出さないでください.
-- @table Notification

---
-- アドオン概要.
-- @local
-- @field name アドオン名.
-- @field author 作者名.
-- @field version バージョン.
-- @field apiVersion APIバージョン.
-- @table Addon
local Addon = {
  name = "TKGNOTIFIER",
  author = "TOKAGEEL",
  version = "0.0.2",
  apiVersion = 1
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
-- @local
-- @param message 出力する文字列.
local function log(message)
  if debugIsEnabled then
    CHAT_SYSTEM(string.format("[TKGNOTIFIER] %s", tostring(message)), "616161")
  end
end

---
-- このアドオンのバージョン情報をシステムメッセージとして出力する.
-- @local
function TKGNOTIFIER_PRINT_VERSION()
  CHAT_SYSTEM(string.format("%s - v%s", Addon.name, tostring(Addon.version)), "616161")
end

---
-- APIのバージョンを返す.
-- @return APIバージョン（number）.
function TKGNOTIFIER_GET_API_VERSION()
  log("TKGNOTIFIER_GET_API_VERSION")
  return Addon.apiVersion
end

---
-- 指定した内容の通知ウィンドウを表示する.
-- @param notification 表示する通知の内容（Notification）.
-- @see Notification
function TKGNOTIFIER_NOTIFY(notification)
  log("TKGNOTIFIER_NOTIFY")
  if (type(notification) ~= "table") then
    log("notification is not table")
    return
  end

  local theNotification = TKGNOTIFIER_CREATE_VALID_NOTIFICATION(notification)

  -- 同一種別の通知をスタックから取り除く
  if (theNotification.kind ~= nil) then
    for index, noti in pairs(stack) do
      if (theNotification.kind == noti.kind) then
        table.remove(stack, index)
        break
      end
    end
  end

  table.insert(stack, theNotification)
  TKGNOTIFIER_FRAME_ON_STACK_CHANGED(stack)
end

---
-- 指定したNotificationから使用可能な形に補正したNotificationを生成して返す.
-- @param notification 元となる通知（Notification）.
-- @return 通知可能な状態に修正したNotification.
-- @see Notification
function TKGNOTIFIER_CREATE_VALID_NOTIFICATION(notification)
  local theNotification = {}
  -- アイコン
  if (type(notification.icon) == "string") then
    theNotification.icon = notification.icon
  else
    -- 指定が不正な場合は適当なアイコンを設定
    theNotification.icon = "news_btn"
  end
  -- メッセージ
  theNotification.message = tostring(notification.message)
  -- 種別
  if (type(notification.kind) == "string") then
    theNotification.kind = notification.kind
  end
  -- アクション
  if (type(notification.action) == "string") then
    theNotification.action = notification.action
  end
  return theNotification
end

---
-- 直近の通知を削除する.
-- 削除した通知がコールバック関数を指定されている場合、コールバック関数を呼び出す.
function TKGNOIFIER_POP()
  log("TKGNOTIFIER_POP")
  local action
  if #stack > 0 then
    local notification = stack[#stack]
    if (notification.action ~= nil) then
      action = notification.action
    end
    table.remove(stack)
    TKGNOTIFIER_FRAME_ON_STACK_CHANGED(stack)
  end
  if (action ~= nil) then
    log("callback " .. action)
    pcall(loadstring(action))
  end
end

---
-- アドオン初期化処理.
-- フレームワークからの呼び出しを期待しているため、直接呼び出さないこと.
-- @local
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
    local settingsFilePath = string.format("../addons/%s/settings.json", string.lower(Addon.name))

    local acutil = require("acutil")
    local settings, err = acutil.loadJSON(settingsFilePath, g.settings)
    if not err then
      g.settings = settings
      debugIsEnabled = settings and settings.debug and settings.debug.enable
    else
      log(tostring(err))
    end
    TKGNOTIFIER_PRINT_VERSION()
  end

  -- 関連機能へ設定値を通知
  TKGNOTIFIER_FRAME_INIT(g.settings)
  TKGNOTIFIER_MAIL_INIT(g.settings)

  if (#stack > 0) then
    TKGNOTIFIER_FRAME_ON_STACK_CHANGED(stack)
  end

  g.loaded = true
end
