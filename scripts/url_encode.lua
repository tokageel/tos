---
-- url_encode.lua
-- URLエンコーディング制御.

---
-- 変換テーブル.
-- @table URL_ENCODE_TABLE
local URL_ENCODE_TABLE = {
  [" "] = "\%20",
  ["!"] = "\%21",
  ['"'] = "\%22",
  ["#"] = "\%23",
  ["$"] = "\%24",
  ["%"] = "\%25",
  ["&"] = "\%26",
  ["'"] = "\%27",
  ["("] = "\%28",
  [")"] = "\%29",
  ["*"] = "\%2A",
  ["+"] = "\%2B",
  [","] = "\%2C",
  ["/"] = "\%2F",
  [":"] = "\%3A",
  [";"] = "\%3B",
  ["<"] = "\%3C",
  ["="] = "\%3D",
  [">"] = "\%3E",
  ["?"] = "\%3F",
  ["@"] = "\%40",
  ["["] = "\%5B",
  ["]"] = "\%5D",
  ["^"] = "\%5E",
  ["`"] = "\%60",
  ["{"] = "\%7B",
  ["|"] = "\%7C",
  ["}"] = "\%7D",
  ["~"] = "\%7E"
}

---
-- 指定した文字列をURLエンコードして返す.
-- @param src 元の文字列.
-- @return URLエンコードした文字列. srcがnilまたはstring型以外の場合はnil.
function encodeUrl(src)
  if (src == nil) or (type(src) ~= "string") then
    return nil
  end

  local buffer = {}
  for i = 1, #src do
    local c = string.sub(src, i, i)
    local encoded = URL_ENCODE_TABLE[c]
    if (encoded) then
      buffer[#buffer + 1] = encoded
    else
      buffer[#buffer + 1] = c
    end
  end
  return table.concat(buffer)
end

---
-- URLエンコード済みの文字列をデコードしてして返す.
-- @param src URLエンコード済みの文字列.
-- @return デコードした文字列. srcがnilまたはstring型以外の場合はnil.
function decodeUrl(src)
  if (src == nil) or (type(src) ~= "string") then
    return nil
  end

  local buffer = src
  for k, v in pairs(URL_ENCODE_TABLE) do
    while true do
      local s, e = string.find(buffer, v, 1, true)
      if s then
        local newBuffer = table.concat{
          string.sub(buffer, 1, (s - 1)),
          k,
          string.sub(buffer, (e + 1), #buffer)
        }
        buffer = newBuffer
      else
        break
      end
    end
  end
  return buffer
end

--[[
-- Usage:
local src = " !\"#$%&'()*+,/:;<=>?@[]^@{|}~"
local encoded = encodeUrl(src)
local decoded = decodeUrl(encoded)
print(src)
print(encoded)
print(decoded)
-- Result:
$ lua url_encode.lua 
 !"#$%&'()*+,/:;<=>?@[]^@{|}~
%20%21%22%23%24%25%26%27%28%29%2A%2B%2C%2F%3A%3B%3C%3D%3E%3F%40%5B%5D%5E%40%7B%7C%7D%7E
 !"#$%&'()*+,/:;<=>?@[]^@{|}~
--]]
