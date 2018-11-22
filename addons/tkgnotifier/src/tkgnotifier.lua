---
-- tkgnotifier.lua
-- 何かを通知してくれるアドオン.

-- ############################################################################
-- ユーティリティ
-- ############################################################################

--- @field acutil.
local acutil = require("acutil")
--- @field 期限日が近づいているメールの通知を行う閾値のデフォルト値（単位:日）.
local DEFAULT_NOTIFY_THRESHOLD_DAY = 7

---
-- アドオン概要.
-- @field name アドオン名.
-- @field author 作者名.
-- @field version バージョン.
-- @table Addon
local Addon = {
  name = "TKGNOTIFIER",
  author = "TOKAGEEL",
  version = "0.0.1"
}

---
-- 表示設定.
-- @field colorWarnings 通常システムメッセージ文字色.
-- @field colorNotify 通知メッセージ文字色.
-- @table Appearances
local Appearances = {
  colorWarnings = "616161",
  colorNotify = "FF00FF"
}

---
-- 指定した文字列をシステムログとしてチャットウィンドウへ出力する.
-- @param message 出力する文字列.
local function log(message)
  CHAT_SYSTEM(string.format("[%s] %s", Addon.name, tostring(message)), Appearances.colorWarnings)
end

---
-- 指定した文字列を目立ちそうな色でチャットウィンドウへ出力する.
-- @param message 出力する文字列.
local function notify(message)
  CHAT_SYSTEM(string.format("[%s] %s", Addon.name, tostring(message)), Appearances.colorNotify)
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
    mail_notify_threshold_day = DEFAULT_NOTIFY_THRESHOLD_DAY
  }
end

---
-- 期限が近づいているアイテム付きのメールが存在するかを確認する.
-- @return 期限が近いアイテム付きのメールが存在する場合はtrue. それ以外の場合はfalse.
function TKGNOTIFIER_HAS_DEADLINE_MAIL()
  local mailCount = session.postBox.GetMessageCount()
  for i = 0 , mailCount - 1 do
    local mail = session.postBox.GetMessageByIndex(i)
    local time = mail:GetTime()
    local diffInSec = -imcTime.GetDiffSecFromNow(imcTime.ImcTimeToSysTime(time))
    local diffInDay = diffInSec / 60 / 60 / 24
    if (diffInDay < g.settings.mail_notify_threshold_day) then
      local itemCount = mail:GetItemCount()
      if ((itemCount > 0) and (itemCount ~= mail:GetItemTakeCount())) then
        return true
      end
    end
  end
  return false
end

---
-- 必要に応じて通知を行う.
function TKGNOTIFIER_NOTIFY_ALL()
  if(TKGNOTIFIER_HAS_DEADLINE_MAIL()) then
    notify("期限が近いメールがあります。メールボックスを確認してください。")
  end
end

---
-- アドオン初期化処理.
-- @param addon アドオン.
-- @param frame アドオンのフレーム.
function TKGNOTIFIER_ON_INIT(addon, frame)
  g.addon = addon
  g.frame = frame

  -- 設定読み込み
  if not g.loaded then
    local settings, err = acutil.loadJSON(g.settingsFilePath, g.settings)
    if not err then
      g.settings = settings
    end

    g.loaded = true
    printVersionMessage()
  end

  TKGNOTIFIER_NOTIFY_ALL()
end
