---
-- サルラス修道院キャッスルミッションでボスが出現したことを自キャラ周辺に表示するアドオン.

local acutil = require("acutil")

---
-- @local
-- アドオン概要.
-- @field name アドオン名.
-- @field author 作者名.
-- @field version バージョン.
-- @table Addon
local Addon = {
  name = "TKGCASTLEPROGRESS",
  author = "TOKAGEEL",
  version = "1.0.0"
}

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
    CHAT_SYSTEM(string.format("[TKGCASTLEPROGRESS] %s", tostring(message)), "616161")
  end
end

-- 進捗が進むごとに通知する内容
local progressInfo = {}
progressInfo["@dicID_^*$QUEST_LV_0100_20150904_008067$*^"] = {
--  icon = "M_boss_Moyabruka",
  icon = "3_1",
  sound = "quest_success_2"
}
progressInfo["@dicID_^*$ETC_20170919_028904$*^"] = {
--  icon = "M_boss_Mothstem",
  icon = "2_1",
  sound = "quest_success_2"
}
progressInfo["@dicID_^*$ETC_20180517_032879$*^"] = {
--  icon = "boss_plokste",
  icon = "1_1",
  sound = "quest_success_2"
}
progressInfo["@dicID_^*$ETC_20170919_028907$*^"] = {
--  icon = "boss_werewolf",
  icon = "0_1",
  sound = "quest_success_3"
}

---
-- @local
-- 指定した画像を吹き出し表示する.
-- @param frame アドオンのフレーム.
-- @param info 通知内容.
function TKGCASTLEPROGRESS_SHOW_FRAME(frame, info)
  if type(info) ~= "table" then
    return
  end
  if frame:IsVisible() == 1 then
    -- すでに吹き出し表示中の場合は一度非表示にする
    frame:ShowWindow(0)
  end
  local icon = GET_CHILD_RECURSIVELY(frame, "icon")
  if icon and info.icon then
    icon:SetImage(info.icon)
    -- フレーム表示後は一定時間後に非表示にする
    frame:ShowWindow(1)
    frame:SetDuration(10.0)
  end

  -- 進捗100%到達時は効果音鳴動させよう
  if info.sound then
    imcSound.PlaySoundEvent(info.sound)
  end
end

function TKGCASTLEPROGRESS_ON_NOTICED(frame, msg)
  log("TKGCASTLEPROGRESS_ON_NOTICED")
  local icon
  local aFrame, aMsg, anArgStr, anArgNum = acutil.getEventArgs(msg)
  if (aMsg == "NOTICE_Dm_scroll") then
    local icon = progressInfo[anArgStr]
    if icon then
      TKGCASTLEPROGRESS_SHOW_FRAME(frame, icon)
    end
  end
end

---
-- @local
-- アドオン初期化処理.
-- フレームワークからの呼び出しを期待しているため、直接呼び出さないこと.
-- @param addon アドオン.
-- @param frame アドオンのフレーム.
function TKGCASTLEPROGRESS_ON_INIT(addon, frame)
  log("TKGCASTLEPROGRESS_ON_INIT")
  g.addon = addon
  g.frame = frame

  -- サルラスキャッスルミッション時にのみ動作させる
  if session.GetMapName() == "mission_d_castle_67_2_nunnery" then
    -- フレーム位置は自キャラ追従
    FRAME_AUTO_POS_TO_OBJ(frame, session.GetMyHandle(), -100, -150, 1, 1)
    acutil.setupEvent(g.addon, "NOTICE_ON_MSG", "TKGCASTLEPROGRESS_ON_NOTICED")
  end
end
