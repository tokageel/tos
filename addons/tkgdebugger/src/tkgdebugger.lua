-- acutil
local acutil = require("acutil")

---
-- アドオン概要.
-- @field name アドオン名.
-- @field author 作者名.
-- @field version バージョン.
-- @table Addon
local Addon = {
  name = "TKGDEBUGGER",
  author = "TOKAGEEL",
  version = "0.0.1"
}

-- グローバルスコープへの格納.
_G["ADDONS"] = _G["ADDONS"] or {}
_G["ADDONS"][Addon.author] = _G["ADDONS"][Addon.author] or {}
_G["ADDONS"][Addon.author][Addon.name] = _G["ADDONS"][Addon.author][Addon.name] or {}
local g = _G["ADDONS"][Addon.author][Addon.name]
g.version = Addon.version
g.logBuffer = {}

---
-- タイムスタンプ文字列取得.
-- @return タイムスタンプ文字列,
function TKGDEBUGGER_GET_TIME_STAMP()
  local curTime = geTime.GetServerSystemTime()
  local curTimeStr = string.format("%04d-%02d-%02d %02d:%02d:%02d",
    curTime.wYear, curTime.wMonth, curTime.wDay,
    curTime.wHour, curTime.wMinute, curTime.wSecond)
  return curTimeStr
end

function TKGDEBUGGER_LOG(message)
  --CHAT_SYSTEM(string.format("[TKGDEBUGGER] %s", tostring(message)), "616161")
  local frame = ui.GetFrame("tkgdebugger")
  if frame == nil then
    return
  end
  if (frame:IsVisible() == 0) then
    ui.OpenFrame("tkgdebugger")
  end

  local safeMessage = tostring(message)
  table.insert(g.logBuffer, safeMessage)
  local logText = GET_CHILD(frame, "log_text")
  logText:AddText(safeMessage)
  frame:Invalidate()
end

function TKGDEBUGGER_CLEAR()
  local frame = ui.GetFrame("tkgdebugger")
  if frame == nil then
    return
  end
  g.glogBuffer = {}
  local logText = GET_CHILD(frame, "log_text")
  logText:Clear()
  frame:Invalidate()
end

function TKGDEBUGGER_DUMP_TO_FILE(filename)
  local file, err = io.open(filename, "w")
  if file then
    for _, text in pairs(g.logBuffer) do
      file:write(tostring(text), "\n")
    end
    file:flush()
    file:close()
  else
    TKGDEBUGGER_LOG(tostring(err))
  end
end

---
-- アドオン初期化処理.
-- @param addon アドオン.
-- @param frame アドオンのフレーム.
function TKGDEBUGGER_ON_INIT(addon, frame)
  CHAT_SYSTEM("TKGDEBUGGER_ON_INIT")
  g.addon = addon
  g.frame = frame
end
