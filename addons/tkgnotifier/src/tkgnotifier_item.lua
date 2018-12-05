---
-- 期限付きアイテム通知機能.
-- 期限が近いアイテムが存在する場合に通知する.

---
-- メール通知の設定.
-- @field trigger メールの期限について通知すべきトリガー.
-- @field threshold_day メールの期限について通知する閾値（単位: 日）.
-- @table ItemSettings
local itemSettings = {}
-- デバッグ機能の有無.
local debugIsEnabled = false
-- この機能で使用する通知種別.
local notificationKind = "TKGNOTIFIER_ITEM"
-- リソース一覧.
local resources = {
  EN = {
    string = {
      deadline_is_nearling = "%s: After it expired in %.1f days."
    }
  },
  JP = {
    string = {
      deadline_is_nearling = "%s: 使用期限まで%.1f日です。"
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
    CHAT_SYSTEM(string.format("[TKGNOTIFIER_ITEM] %s", tostring(message)), "616161")
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
-- 呼び出しタイミングと閾値が条件に合う場合、期限切れが近いメールの存在を通知する.
function TKGNOTIFIER_ITEM_NOTIFY_IF_NEEDED()
  log("TKGNOTIFIER_ITEM_NOTIFY_IF_NEEDED")

  -- 通知タイミングチェック
  local trigger = TKGNOTIFIER_ITEM_DICIDE_TRIGGER()
  log(string.format("trigger=%d (settings=%d)", trigger, itemSettings.trigger))
  if (itemSettings.trigger < trigger) then
    return
  end

  -- 閾値チェック
  local thresholdInSec = itemSettings.threshold_day * 24 * 60 * 60
  local itemList = GET_SCHEDULED_TO_EXPIRED_ITEM_LIST(thresholdInSec)
  if (itemList ~= nil) and (#itemList > 0) then
    itemList = SORT_ITEM_LIST_BY_LIFETIME(itemList)
    for _, item in pairs(itemList) do
      local remainInSec = imcTime.GetDifSec(
        imcTime.GetSysTimeByStr(item.ItemLifeTime),
        geTime.GetServerSystemTime())
      local message = string.format(R.string.deadline_is_nearling, item.Name, remainInSec / 60 / 60 / 24)
      local kind = string.format("%s_%s", notificationKind)
      TKGNOTIFIER_NOTIFY({
        icon = item.Icon,
        message = message,
        kind = kind
      })
    end
  end
end

---
-- 指定した設定値を使用して設定を構築する.
-- @param settings 設定値.
function TKGNOTIFIER_ITEM_LOAD_SETTINGS(settings)
  log("TKGNOTIFIER_ITEM_LOAD_SETTINGS")
  log("loaded settings=" .. dump(settings))

  -- デフォルト設定
  itemSettings = {
    trigger = TKGNOTIFIER_ENUM_TRIGGER.onCharacterChanged,
    threshold_day = 3
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
    if settings.item then
      if settings.item.trigger then
        itemSettings.trigger = settings.item.trigger
      end
      if settings.item.threshold_day then
        itemSettings.threshold_day = settings.item.threshold_day
      end
    end
    debugIsEnabled = settings.debug and settings.debug.enable
  end

  log("actual settings=" .. dump(itemSettings))
end

---
-- メール通知機能を初期化する.
-- @param settings 設定値.
-- @param trigger 呼び出しのトリガー.
function TKGNOTIFIER_ITEM_INIT(settings, trigger)
  log("TKGNOTIFIER_ITEM_INIT")

  -- ログイン時のみ設定読み込み
  if trigger == TKGNOTIFIER_ENUM_TRIGGER.onLogined then
    TKGNOTIFIER_ITEM_LOAD_SETTINGS(settings)
  end

  TKGNOTIFIER_ITEM_NOTIFY_IF_NEEDED(trigger)
end
