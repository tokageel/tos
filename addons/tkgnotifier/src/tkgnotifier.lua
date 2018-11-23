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
  version = "0.0.2"
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
-- メールボックスに存在する未受領のアイテムが添付されたメールのうち、
-- 最も期限が近いメールの受け取り期限までの時間を日単位で返す.
-- @return 受取期限までの日数. 該当するメールがメールボックスに存在しない場合は負数.
function TKGNOTIFIER_GET_MAIL_WILL_EXPIRE_IN_DAY()
  local nearestInSec = -1
  local mailCount = session.postBox.GetMessageCount()
  for i = 0 , mailCount - 1 do
    local mail = session.postBox.GetMessageByIndex(i)
    local itemCount = mail:GetItemCount()
    if ((itemCount > 0) and (itemCount ~= mail:GetItemTakeCount())) then
      local time = imcTime.ImcTimeToSysTime(mail:GetTime())
      local diffInSec = -imcTime.GetDiffSecFromNow(time)
      nearestInSec = (nearestInSec < 0) and diffInSec or math.min(nearestInSec, diffInSec)
    end
  end

  return nearestInSec / 60 / 60 / 24
end


---
-- 指定したアイコンと文字列を使用して通知ウィンドウを表示する.
-- @param icon 表示するアイコン.
-- @param message 出力する文字列.
function TKGNOTIFIER_NOTIFY(icon, message)
  local frameName = "tkgnotifier"
  local frame = ui.GetFrame(frameName)
  if not frame then
    return
  end
  if (frame:IsVisible() == 1) then
    ui.CloseFrame(frameName)
  end

  message = message or ""
  local richText = GET_CHILD_RECURSIVELY(frame, "message")
  if richText then
    richText:SetText(tostring(message or ""))
  end

  local picture = GET_CHILD_RECURSIVELY(frame, "icon")
  if picture then
    picture:SetImage(icon or "")
  end
  ui.OpenFrame(frameName)
end

---
-- 必要に応じて通知を行う.
function TKGNOTIFIER_NOTIFY_ALL()
  local willExpireInDay = TKGNOTIFIER_GET_MAIL_WILL_EXPIRE_IN_DAY()
  if ((willExpireInDay > 0) and (willExpireInDay < g.settings.mail_notify_threshold_day)) then
    local message = string.format("受取期限まで%.1f日のメールがあります。", willExpireInDay)
    TKGNOTIFIER_NOTIFY("news_btn", message)
  end
end

---
-- フレームを初期化する.
-- @param frame 初期化対象のフレーム.
function TKGNOTIFIER_FRAME_INIT(frame)
  if not frame then
    return
  end
  local x = 200
  local y = 200

  -- クエスト欄の上辺りに画面右詰めで表示
  local questFrame = ui.GetFrame("questinfoset_2")
  if questFrame and questFrame:IsVisible() then
    x = questFrame:GetX() + (questFrame:GetWidth() - frame:GetWidth())
    y = questFrame:GetY() - frame:GetHeight()
  end
  frame:SetOffset(x, y)

  frame:Invalidate()
  frame:ShowWindow(1)
end

---
-- フレーム表示時のコールバック.
-- @param frame 表示対象のフレーム.
function TKGNOTIFIER_FRAME_OPEN(frame)
  TKGNOTIFIER_FRAME_INIT(frame)
end

---
-- フレームを非表示時のコールバック.
-- @param frame 非表示対象のフレーム.
function TKGNOTIFIER_FRAME_CLOSE(frame)
end

---
-- ウィジェットクリック時のコールバック.
-- @param frame 指定されたウィジェットを含むフレーム.
-- @param ctrl 指定されたウィジェット.
-- @param argStr LBtnUpArgStrで指定された引数.
-- @param argNum 引数の数.
function TKGNOTIFIER_FRAME_ON_CLICKED(frame, ctrl, argStr, argNum)
  if not frame then
    return
  end

  ui.CloseFrame(frame:GetName())
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
