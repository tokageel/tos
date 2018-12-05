---
-- メール通知機能.
-- 期限が近いメールが存在する場合に通知する.

---
-- メール通知の設定.
-- @field trigger メールの期限について通知すべきトリガー.
-- @field threshold_day メールの期限について通知する閾値（単位: 日）.
-- @table mailSettings
local mailSettings
-- デバッグ機能の有無.
local debugIsEnabled = false
-- この機能で使用する通知種別.
local notificationKind = "TKGNOTIFIER_MAIL"
-- リソース一覧.
local resources = {
  EN = {
    icon = {
      news = "news_btn"
    },
    string = {
      deadline_is_nearling = "Until a time limit of a message: %.1f days."
    }
  },
  JP = {
    icon = {
      news = "news_btn"
    },
    string = {
      deadline_is_nearling = "受取期限まで%.1f日のメールがあります。"
    }
  }
}

-- リソース.
local R = resources.EN

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
-- 呼び出しタイミングと閾値が条件に合う場合、期限切れが近いメールの存在を通知する.
function TKGNOTIFIER_MAIL_NOTIFY_IF_NEEDED(trigger)
  log("TKGNOTIFIER_MAIL_NOTIFY_IF_NEEDED")

  -- 通知タイミングチェック
  log(string.format("trigger=%d (settings=%d)", trigger, mailSettings.trigger))
  if (mailSettings.trigger < trigger) then
    return
  end

  -- 閾値チェック
  local willExpireInDay = TKGNOTIFIER_MAIL_GET_NEAREST_EXPIRE_IN_DAY()
  log(string.format("expire=%.1f (settings=%.1f)", willExpireInDay, mailSettings.threshold_day))
  if ((willExpireInDay > 0) and (willExpireInDay < mailSettings.threshold_day)) then
    local message = string.format(R.string.deadline_is_nearling, willExpireInDay)
    TKGNOTIFIER_NOTIFY({
      icon = R.icon.news,
      message = message,
      kind = notificationKind
    })
  end
end

---
-- 指定した設定値を使用して設定を構築する.
-- @param settings 設定値.
function TKGNOTIFIER_MAIL_LOAD_SETTINGS(settings)
  log("TKGNOTIFIER_MAIL_LOAD_SETTINGS")
  log("loaded settings=" .. dump(settings))

  -- デフォルト設定
  mailSettings = {
    trigger = TKGNOTIFIER_ENUM_TRIGGER.onLogined,
    threshold_day = 7
  }

  -- 指定された設定をマージ
  if settings then
    if settings.locale then
      local getResource = function(locale)
        for k, v in pairs(resources) do
          if locale == k then
            return v
          end
        end
        return resources["EN"]
      end
      R = getResource(settings.locale)
    end
    if settings.mail then
      if settings.mail.trigger then
        mailSettings.trigger = settings.mail.trigger
      end
      if settings.mail.threshold_day then
        mailSettings.threshold_day = settings.mail.threshold_day
      end
    end
    debugIsEnabled = settings.debug and settings.debug.enable
  end

  log("actual settings=" .. dump(mailSettings))
end

---
-- メール通知機能を初期化する.
-- @param settings 設定値.
function TKGNOTIFIER_MAIL_INIT(settings, trigger)
  log("TKGNOTIFIER_MAIL_INIT")

  -- ログイン時のみ設定読み込み
  if trigger == TKGNOTIFIER_ENUM_TRIGGER.onLogined then
    TKGNOTIFIER_MAIL_LOAD_SETTINGS(settings)
  end

  TKGNOTIFIER_MAIL_NOTIFY_IF_NEEDED(trigger)
end
