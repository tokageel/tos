---
-- tkgslack

-- Note: settings.json内の設定項目
-- webhookUrl: [M] SlackのwebhookのURL.
-- authorIcon: [O] 投稿者アイコン.

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
local debugIsEnabled = true

local paths = {}
paths.workDir = string.format("%s..\\addons\\%s", path.GetDataPath(), string.lower(Addon.name))
paths.vbsFile = string.format("%s\\%s", paths.workDir, "post_message.vbs")
paths.batFile = string.format("%s\\%s", paths.workDir, "post_message.bat")
paths.postDataFile = string.format("%s\\%s", paths.workDir, "message.json")

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

function TKGSLACK_CREATE_LAUNCHER()
  -- コマンドプロンプトのウィンドウ表示無しで実行させるためのVBScriptファイルを作成
  local file, err = io.open(paths.vbsFile, "w")
  if file then
    file:write("Set ws = CreateObject(\"Wscript.Shell\")\n")
    file:write(string.format("ws.run \"cmd /c %s\", vbhide\n", paths.batFile))
    file:flush()
    file:close()
  else
    log(tostring(err))
  end
end

function TKGSLACK_CREATE_SCRIPT()
  -- コマンドプロンプトで実行するbatファイルを作成
  local file, err = io.open(paths.batFile, "w")
  if file then
    local script = string.format('curl -X POST -H "Content-type: application/json" --data @%s %s\n',
      paths.postDataFile,
      g.settings.webhookUrl
    )
    file:write(script)
    file:flush()
    file:close()
  else
    log(tostring(err))
  end
end

function TKGSLACK_WRITE_POST_DATA(jsonString)
  -- POSTデータを作成
  if (jsonString == nil) then
    return false
  end

  local file, err = io.open(paths.postDataFile, "w")
  if file then
    file:write(jsonString)
    file:flush()
    file:close()
  else
    log(tostring(err))
    return false
  end

  return true
end

---
-- Slackへメッセージを投稿する.
-- @param message
function TKGSLACK_POST_TEXT(message)
  local json = require("json_imc")
  local jsonString = json.encode({text = message})
  if TKGSLACK_WRITE_POST_DATA(jsonString) then
    OpenUploadEmblemFolder(paths.vbsFile)
  end
end

---
-- Slackへ添付メッセージとして投稿する.
-- @param message 発言内容.
-- @param authorName 投稿者名.
-- @param authorIcon 投稿者アイコン.
function TKGSLACK_POST_ATTACHEMENT(message, authorName, authorIcon)
  local attachment = {
    author_name = authorName,
    author_icon = authorIcon,
    text = message
  }
  local json = require("json_imc")
  local jsonString = string.format('{ "attachments": [ %s ] }\n', json.encode(attachment))
  if TKGSLACK_WRITE_POST_DATA(jsonString) then
    OpenUploadEmblemFolder(paths.vbsFile)
  end
end

---
-- Slackへ添付メッセージとして投稿する.
-- メッセージの投稿者として、チーム名、キャラ名、マップ名、チャンネル番号を含む文字列を設定する.
-- 投稿者のアイコンがあらかじめ設定されていた場合、アイコンを付与する.
-- @param message 発言内容.
function TKGSLACK_POST_MY_MESSAGE(message)
  local mapName = "UnknownMap"
  local mapCls = GetClass("Map", session.GetMapName())
  if mapCls then
    mapName = dictionary.ReplaceDicIDInCompStr(mapCls.Name)
  end

  local channelName = "UnknownChannel"
  local channel = session.loginInfo.GetChannel()
  if channel then
    channelName = string.format("%dch", channel + 1)
  end

  local authorName = string.format("%s / %s @%s (%s)",
    info.GetFamilyName(session.GetMyHandle()),
    GETMYPCNAME(),
    mapName,
    channelName)

  TKGSLACK_POST_ATTACHEMENT(message, authorName, g.settings.authorIcon)
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
    local acutil = require("acutil")
    local settingsFilePath = string.format("%s/settings.json", paths.workDir)
    local settings, err = acutil.loadJSON(settingsFilePath, g.settings)
    if not err then
      g.settings = settings
    else
      g.settings = {}
      log(tostring(err))
    end

    if (g.settings.webhookUrl ~= nil) then
      -- アドオンのバージョンアップ直後はスクリプトを再生成する
      if g.settings.version ~= Addon.version then
        TKGSLACK_CREATE_LAUNCHER()
        TKGSLACK_CREATE_SCRIPT()

        g.settings.version = Addon.version
        acutil.saveJSON(settingsFilePath, g.settings)
      end
    end

    TKGSLACK_PRINT_VERSION()
  end
  g.loaded = true
end
