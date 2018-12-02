---
-- UI管理機能.

-- デバッグ機能の有無.
local debugIsEnabled = false

---
-- デバッグONの場合指定した文字列をシステムログとしてチャットウィンドウへ出力する.
-- @param message 出力する文字列.
local function log(message)
  if debugIsEnabled then
    CHAT_SYSTEM(string.format("[TKGNOTIFIER_FRAME] %s", tostring(message)), "616161")
  end
end

---
-- UI管理機能の初期化処理.
-- @param settings 設定値.
function TKGNOTIFIER_FRAME_INIT(settings)
  log("TKGNOTIFIER_FRAME_INIT")
end

---
-- フレーム表示時のコールバック.
-- @param frame 表示対象のフレーム.
function TKGNOTIFIER_FRAME_OPEN(frame)
  log("TKGNOTIFIER_FRAME_OPEN")
  if not frame then
    return
  end
  local x = 0
  local y = 0

  -- クエスト欄の上辺りに画面右詰めで表示
  local questFrame = ui.GetFrame("questinfoset_2")
  if questFrame and questFrame:IsVisible() then
    x = questFrame:GetX() + (questFrame:GetWidth() - frame:GetWidth())
    y = questFrame:GetY() - frame:GetHeight()
  end
  frame:SetOffset(x, y)
end

---
-- フレームを非表示時のコールバック.
-- @param frame 非表示対象のフレーム.
function TKGNOTIFIER_FRAME_CLOSE(frame)
  log("TKGNOTIFIER_FRAME_CLOSE")
end

---
-- ウィジェットクリック時のコールバック.
-- @param frame 指定されたウィジェットを含むフレーム.
-- @param ctrl 指定されたウィジェット.
-- @param argStr LBtnUpArgStrで指定された引数.
-- @param argNum 引数の数.
function TKGNOTIFIER_FRAME_ON_CLICKED(frame, ctrl, argStr, argNum)
  log("TKGNOTIFIER_FRAME_ON_CLICKED")
  if not frame then
    return
  end

  ui.CloseFrame(frame:GetName())
end

---
-- アイコンとメッセージを指定して通知を表示する.
-- @param icon アイコン.
-- @param message メッセージ.
function TKGNOTIFIER_FRAME_SHOW_NOTIFY(icon, message)
  log("TKGNOTIFIER_FRAME_SHOW_NOTIFY")
  local frameName = "tkgnotifier"
  local frame = ui.GetFrame(frameName)
  if not frame then
    return
  end
  if (frame:IsVisible() == 1) then
    ui.CloseFrame(frameName)
  end

  local richText = GET_CHILD_RECURSIVELY(frame, "message")
  if richText then
    richText:SetText(message)
  end

  local picture = GET_CHILD_RECURSIVELY(frame, "icon")
  if picture then
    picture:SetImage(icon)
  end
  ui.OpenFrame(frameName)
end
