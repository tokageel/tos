---
-- tkgslack

---
-- @local
-- アドオン概要.
-- @field name アドオン名.
-- @field author 作者名.
-- @field version バージョン.
-- @field apiVersion APIバージョン.
-- @table Addon
local Addon = {
  name = "TKGSLACK",
  author = "TOKAGEEL",
  version = "1.0.0",
}

-- グローバルスコープへの格納.
_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][Addon.author] = _G["ADDONS"][Addon.author] or {}
_G["ADDONS"][Addon.author][Addon.name] = _G["ADDONS"][Addon.author][Addon.name] or {}
local g = _G["ADDONS"][Addon.author][Addon.name]
-- デバッグ機能の有無.
local debugIsEnabled = false

---
-- @local
-- 指定した文字列をシステムログとしてチャットウィンドウへ出力する.
-- @param message 出力する文字列.
local function log(message)
  if debugIsEnabled then
    CHAT_SYSTEM(string.format("[TKGSLACK] %s", tostring(message)), "616161")
  end
end

---
-- @local
-- このアドオンのバージョン情報をシステムメッセージとして出力する.
function TKGSLACK_PRINT_VERSION()
  CHAT_SYSTEM(string.format("%s - v%s", Addon.name, tostring(Addon.version)), "616161")
end

---
-- @local
-- アドオン初期化処理.
-- フレームワークからの呼び出しを期待しているため、直接呼び出さないこと.
-- @param addon アドオン.
-- @param frame アドオンのフレーム.
function TKGSLACK_ON_INIT(addon, frame)
  log("TKGSLACK_ON_INIT")
  g.addon = addon
  g.frame = frame

  -- 設定読み込み
  if not g.loaded then
    TKGSLACK_PRINT_VERSION()
  end
  g.loaded = true
end
