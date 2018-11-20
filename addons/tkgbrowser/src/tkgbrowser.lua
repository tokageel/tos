---
-- tkgbrowser.lua
-- 冒険日誌のコレクション画面から規定のブラウザを起動する機能を提供するアドオン.

-- ############################################################################
-- ユーティリティ.
-- ############################################################################

--- @field デバッグログ出力.
local DEBUG = false
--- @field acutil.
local acutil = require("acutil")

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

  -- デバッグ時は詳細をコンソールへ出力
  if DEBUG then
    local stackInfo = debug.getinfo(2)
    local line = string.format("[%s][%u][%s]%s",
      stackInfo.source,
      stackInfo.currentline,
      stackInfo.name or "nil",
      message)
    print(line)
  end

  CHAT_SYSTEM(string.format("[%s] %s", Addon.name, message), Appearances.colorWarnings)
end

---
-- バージョン出力
local function printVersionMessage()
  log(string.format("%s - v%s", Addon.name, tostring(Addon.version)))
end

---
-- グローバルスコープへの格納.
_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][Addon.author] = _G["ADDONS"][author] or {}
_G["ADDONS"][Addon.author][Addon.name] = _G["ADDONS"][Addon.author][Addon.name] or {}
local g = _G["ADDONS"][Addon.author][Addon.name]

-- ############################################################################
-- アドオン制御
-- ############################################################################

--- アドオン初期化処理.
-- @param addon アドオン.
-- @param frame アドオンのフレーム.
function TKGBROWSER_ON_INIT(addon, frame)
  g.addon = addon
  g.frame = frame
  if not g.loaded then
    g.loaded = true
  end
  printVersionMessage()
end
