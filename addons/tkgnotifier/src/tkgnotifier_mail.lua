---
-- メール通知機能.
-- 期限が近いメールが存在する場合に通知する.

---
-- 通知トリガーの列挙.
-- @field none 通知なし.
-- @field onLogined ログイン時にのみ通知する.
-- @field onCharacterChanged ログイン時、キャラクター切替時に通知する.
-- @field onMapTransited ログイン時、キャラクター切替時、マップ移動時に通知する.
-- @field onChannelChanged ログイン時、キャラクター切替時、マップ移動時、チャンネル切り替え時に通知する.
-- @table TKGNOTIFIER_MAIL_ENUM_TRIGGER
local TKGNOTIFIER_MAIL_ENUM_TRIGGER = {
  none = 0,
  onLogined = 1,
  onCharacterChanged = 2,
  onMapTransited = 3,
  onChannelChanged = 4,
}

---
-- メール通知の設定.
-- @field trigger メールの期限について通知すべきトリガー.
-- @field threshold_day メールの期限について通知する閾値（単位: 日）.
-- @table mailSettings
local mailSettings = {
  trigger = TKGNOTIFIER_MAIL_ENUM_TRIGGER.onLogined,
  threshold_day = 7
}
-- デバッグ機能の有無.
local debugIsEnabled = false
-- 最後に確認したキャラクター名.
local lastPcName
-- 最後に確認したマップ名.
local lastMapName

---
-- 指定した文字列をシステムログとしてチャットウィンドウへ出力する.
-- @param message 出力する文字列.
local function log(message)
  if debugIsEnabled then
    CHAT_SYSTEM(string.format("[TKGNOTIFIER_MAIL] %s", tostring(message)), "616161")
  end
end

local function dump(value)
  if value and type(value) == "table" then
    buf = "{"
    for k, v in pairs(value) do
      buf = buf .. string.format("%s: %s, ", k, dump(v))
    end
    buf = buf .. "}"
    return buf
  end

  return tostring(value)
end

---
-- メールボックスに存在する未受領のアイテムが添付されたメールのうち、
-- 最も期限が近いメールの受け取り期限までの時間を日単位で返す.
-- @return 受取期限までの日数. 該当するメールがメールボックスに存在しない場合は負数.
function TKGNOTIFIER_MAIL_GET_NEAREST_EXPIRE_IN_DAY()
  log("TKGNOTIFIER_MAIL_GET_NEAREST_EXPIRE_IN_DAY")
  local nearestInSec = -1
  local mailCount = session.postBox.GetMessageCount()
  for i = 0, mailCount - 1 do
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
-- 呼び出しタイミングから通知トリガーを同定する.
-- @return 通知トリガー.
-- @see TKGNOTIFIER_MAIL_ENUM_TRIGGER
function TKGNOTIFIER_MAIL_DICIDE_TRIGGER()
  log("TKGNOTIFIER_MAIL_DICIDE_TRIGGER")
  local trigger
  local pcName = GETMYPCNAME()
  local mapName = session.GetMapName()
  if (lastPcName == nil) then
    trigger = TKGNOTIFIER_MAIL_ENUM_TRIGGER.onLogined
  elseif (lastPcName == pcName) then
    if (lastMapName == mapName) then
      trigger = TKGNOTIFIER_MAIL_ENUM_TRIGGER.onChannelChanged
    else
      trigger = TKGNOTIFIER_MAIL_ENUM_TRIGGER.onMapTransited
    end
  else
    trigger = TKGNOTIFIER_MAIL_ENUM_TRIGGER.onCharacterChanged
  end
  lastPcName = pcName
  lastMapName = mapName
  return trigger
end

---
-- 呼び出しタイミングと閾値が条件に合う場合、期限切れが近いメールの存在を通知する.
function TKGNOTIFIER_MAIL_NOTIFY_IF_NEEDED()
  log("TKGNOTIFIER_MAIL_NOTIFY_IF_NEEDED")

  -- 通知タイミングチェック
  local trigger = TKGNOTIFIER_MAIL_DICIDE_TRIGGER()
  log(string.format("trigger=%d (settings=%d)", trigger, mailSettings.trigger))
  if (mailSettings.trigger < trigger) then
    return
  end

  -- 閾値チェック
  local willExpireInDay = TKGNOTIFIER_MAIL_GET_NEAREST_EXPIRE_IN_DAY()
  log(string.format("expire=%.1f (settings=%.1f)", willExpireInDay, mailSettings.threshold_day))
  if ((willExpireInDay > 0) and (willExpireInDay < mailSettings.threshold_day)) then
    local message = string.format("受取期限まで%.1f日のメールがあります。", willExpireInDay)
    TKGNOTIFIER_NOTIFY("news_btn", message)
  end
end

---
-- メール通知機能を初期化する.
-- @param settings 設定値.
function TKGNOTIFIER_MAIL_INIT(settings)
  log("TKGNOTIFIER_MAIL_INIT")
  log("loaded settings=" .. dump(settings))

  -- デフォルト設定
  if settings and settings.mail then
    if settings.mail.trigger then
      mailSettings.trigger = settings.mail.trigger
    end
    if settings.mail.threshold_day then
      mailSettings.threshold_day = settings.mail.threshold_day
    end
  end
  debugIsEnabled = settings and settings.debug and settings.debug.enable
  log("actual settings=" .. dump(mailSettings))

  TKGNOTIFIER_MAIL_NOTIFY_IF_NEEDED()
end
