---
-- WBアナウンス時に通知を表示するTKGNOTIFIER拡張アドオン.

-- acutil
local acutil = require("acutil")

---
-- アドオン概要.
-- @field name アドオン名.
-- @field author 作者名.
-- @field version バージョン.
-- @table Addon
local Addon = {
  name = "BOSSNOTIFIER",
  author = "TOKAGEEL",
  version = "0.0.1"
}

-- グローバルスコープへの格納.
_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][Addon.author] = _G["ADDONS"][Addon.author] or {}
_G["ADDONS"][Addon.author][Addon.name] = _G["ADDONS"][Addon.author][Addon.name] or {}
local g = _G["ADDONS"][Addon.author][Addon.name]
g.version = Addon.version

-- デバッグ機能の有無.
local debugIsEnabled = false
-- 通知に表示するアイコンの名称.
local iconName = "attendance_onion_stamp"

---
-- 指定した文字列をシステムログとしてチャットウィンドウへ出力する.
-- @param message 出力する文字列.
local function log(message)
  if debugIsEnabled then
    CHAT_SYSTEM(string.format("[BOSSNOTIFIER] %s", tostring(message)), "616161")
  end
end

---
-- タイムスタンプ文字列取得.
-- @return タイムスタンプ文字列,
function BOSSNOTIFIER_GET_TIME_STAMP()
  local curTime = geTime.GetServerSystemTime()
  local curTimeStr = string.format("%04d-%02d-%02d %02d:%02d:%02d",
    curTime.wYear, curTime.wMonth, curTime.wDay,
    curTime.wHour, curTime.wMinute, curTime.wSecond)
  return curTimeStr
end

---
-- TKGNOTIFIERの通知クリック時のコールバック関数.
function BOSSNOTIFIER_ON_REMOVED_NOTIFICATION()
  log("BOSSNOTIFIER_ON_REMOVED_NOTIFICATION")
end

---
-- WBボスアナウンス通知.
-- @param bossName WB名.
function BOSSNOTIFIER_NOTIFY(bossName)
  log("BOSSNOTIFIER_NOTIFY")
  local timeStamp = BOSSNOTIFIER_GET_TIME_STAMP()
  local message = string.format("WBアナウンス: %s / %s", bossName, timeStamp)
  log(message)
  TKGNOTIFIER_NOTIFY(iconName, message, "BOSSNOTIFIER", "BOSSNOTIFIER_ON_REMOVED_NOTIFICATION")
end

---
-- NOTICE_ON_MSGハンドラ.
-- @param frame フレーム.
-- @param msg メッセージ.
function BOSSNOTIFIER_NOTICE_ON_MSG(frame, msg)
  log("BOSSNOTIFIER_NOTICE_ON_MSG")
  local aFrame, aMsg, anArgStr, anArgNum = acutil.getEventArgs(msg)
  log(aMsg)
  if (aMsg == "NOTICE_Dm_Global_Shout") then
    log(anArgStr)
    local bossName = anArgStr:gsub("!@%#%$FieldBoss.*WillAppear%$%*%$Name%$%*%$(.*%$%*%^)#@%!", "%1")
    if (bossName ~= anArgStr) then
      BOSSNOTIFIER_NOTIFY(bossName)
    end
  end
end

---
--
function BOSSNOTIFIER_LATE_INIT()
  -- APIバージョン確認
  pcall(function()
    local expectVersion = 0
    local actualVersion = TKGNOTIFIER_GET_API_VERSION()
    if (actualVersion < expectVersion) then
      local message = "BOSSNOTIFIERに対してTKGNOTIFIERのバージョンが古いようです。"
      TKGNOTIFIER_NOTIFY(iconName, message)
    elseif (actualVersion > expectVersion) then
      local message = "TKGNOTIFIERに対してBOSSNOTIFIERのバージョンが古いようです。"
      TKGNOTIFIER_NOTIFY(iconName, message)
    else
      -- ワールドアナウンスのフックを登録
      acutil.setupEvent(addon, "NOTICE_ON_MSG", "BOSSNOTIFIER_NOTICE_ON_MSG")
    end
  end)
end

---
-- スラッシュコマンド処理.
-- @param command コマンド.
function BOSSNOTIFIER_PROCESS_COMMAND(command)
  local args = ""
  if #command > 0 then
    args = table.remove(command, 1)
  else
    return ui.MsgBox("/bossnotifier [time]", "", "Nope")
  end
  if args == "time" then
    local message = string.format("[BOSSNOTIFIER] 現在時刻: %s", BOSSNOTIFIER_GET_TIME_STAMP())
    CHAT_SYSTEM(message, "f06161")
  end
end

---
-- アドオン初期化処理.
-- @param addon アドオン.
-- @param frame アドオンのフレーム.
function BOSSNOTIFIER_ON_INIT(addon, frame)
  log("BOSSNOTIFIER_ON_INIT")
  g.addon = addon
  g.frame = frame

  -- スラッシュコマンド登録
  acutil.slashCommand("/bossnotifier", BOSSNOTIFIER_PROCESS_COMMAND)

  -- TKGNOTIFIERのAPIを呼び出す処理はON_INITで実行しないようにする
  addon:RegisterMsg("GAME_START_3SEC", "BOSSNOTIFIER_LATE_INIT")
end
