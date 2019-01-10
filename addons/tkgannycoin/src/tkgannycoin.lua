---
-- 「帰ってきた碧き結晶とモンスター」イベント用アドオン.

---
-- @local
-- アドオン概要.
-- @field name アドオン名.
-- @field author 作者名.
-- @field version バージョン.
-- @table Addon
local Addon = {
  name = "TKGANNYCOIN",
  author = "TOKAGEEL",
  version = "1.0.0"
}

_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][Addon.author] = _G["ADDONS"][Addon.author] or {}
_G["ADDONS"][Addon.author][Addon.name] = _G["ADDONS"][Addon.author][Addon.name] or {}
local g = _G["ADDONS"][Addon.author][Addon.name]

local TKGANNYCOIN_NOTIFICATION = {
  icon = "icon_item_annycoin_1",
  message = "モンスターコインを受領できます。",
  kind = "TKGANNYCOIN"
}

local function eventWasFinished()
  local curTime = geTime.GetServerSystemTime()
  local curTimeStr = string.format("%04d%02d%02d%02d%02d",
    curTime.wYear, curTime.wMonth, curTime.wDay,
    curTime.wHour, curTime.wMinute)
  local curTimeNumber = tonumber(curTimeStr)
  -- イベント終了時刻は2019/01/30 12:00としておく
  local eventEndNumber = tonumber("201901301200")
  return curTimeNumber > eventEndNumber
end

local function isTakenCoinToday()
  local curTime = geTime.GetServerSystemTime()
  local curDateStr = string.format("%d/%d/%d", curTime.wYear, curTime.wMonth, curTime.wDay)
  local lastReceivedDate = TryGetProp(GetMyAccountObj(), "EVENT_1801_ORB_GIVE_DATE")
  return lastReceivedDate ~= curDateStr
end

local function hasNotifier()
  if type(TKGNOTIFIER_NOTIFY) ~= "function" then
    return false
  end
  if type(TKGNOTIFIER_GET_API_VERSION) ~= "function" then
    return false
  end
  if TKGNOTIFIER_GET_API_VERSION() ~= 1 then
    return false
  end

  return true
end

function TKGANNYCOIN_LATE_INIT()
  if eventWasFinished() then
    return
  end

  if isTakenCoinToday() then
    if hasNotifier() then
      TKGNOTIFIER_NOTIFY(TKGANNYCOIN_NOTIFICATION)
    else
      CHAT_SYSTEM(string.format("[TKGANNYCOIN] %s", TKGANNYCOIN_NOTIFICATION.message), "FFFF00")
    end
  end
end

---
-- @local
-- アドオン初期化処理.
-- フレームワークからの呼び出しを期待しているため、直接呼び出さないこと.
-- @param addon アドオン.
-- @param frame アドオンのフレーム.
function TKGANNYCOIN_ON_INIT(addon, frame)
  g.addon = addon
  g.frame = frame

  -- 日本サーバ以外では動作させない
  if GetServerNation() ~= "JP" then
    return
  end

  addon:RegisterMsg("GAME_START_3SEC", "TKGANNYCOIN_LATE_INIT")
end
