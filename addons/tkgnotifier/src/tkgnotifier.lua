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
    mail_notify_threshold_day = DEFAULT_NOTIFY_THRESHOLD_DAY
  }
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

end
