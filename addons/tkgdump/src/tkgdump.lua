---
-- tkgdump

local log = TKGDEBUGGER_LOG or CHAT_SYSTEM or print

local function dump(root, rootName)
  if type(root) ~= "table" or type(rootName) ~= "string" then
    return
  end

  local getPath = function(categoryName)
    return string.format("../addons/tkgdump/dump_%s_%s.txt", rootName, categoryName)
  end

  local functions = {}
  local uds = {}
  local tables = {}
  local variables = {}
  for k, v in pairs(root) do
    local aType = type(v)
    if aType == "function" then
      if k ~= "TKGDUMP_DUMP" and k ~= "TKGDUMP_ON_INIT" then
        table.insert(functions, k)
      end
    elseif aType == "userdata" then
      table.insert(uds, k)
    elseif aType == "table" then
      if k ~= root then
        table.insert(tables, k)
      end
    else
      table.insert(variables, k)
    end
  end

  local sortIgnoreCase = function(a, b)
    return string.lower(a) < string.lower(b)
  end
  table.sort(functions, sortIgnoreCase)
  table.sort(uds, sortIgnoreCase)
  table.sort(tables, sortIgnoreCase)
  table.sort(variables, sortIgnoreCase)

  local file, err = io.open(getPath("functions"), "w")
  if file then
    for _, name in pairs(functions) do
      file:write(string.format("%s\n", name))
    end
    file:flush()
    file:close()
  else
    log(tostring(err))
  end

  file, err = io.open(getPath("userdata"), "w")
  if file then
    for _, name in pairs(uds) do
      local meta = getmetatable(root[name])
      local sortedMeta = {}
      for k, _ in pairs(meta) do
        table.insert(sortedMeta, k)
      end
      table.sort(sortedMeta, sortIgnoreCase)

      file:write(string.format("%s = {\n", name))
      for _, v in pairs(sortedMeta) do
        file:write(string.format("  %s: %s\n", v, type(meta[v])))
      end
      file:write("}\n")
    end
    file:flush()
    file:close()
  else
    log(tostring(err))
  end

  file, err = io.open(getPath("tables"), "w")
  if file then
    for _, name in pairs(tables) do
      local sortedMembers = {}
      for k, _ in pairs(root[name]) do
        table.insert(sortedMembers, k)
      end
      table.sort(sortedMembers, sortIgnoreCase)

      file:write(string.format("%s = {\n", name))
      if name == "TEXT_ZONENAMELIST" or name == "TEXT_MONNAMELIST" or name == "ZONENAME_LIST" or name == "ZONENAME_LIST_LV" then
        file:write(string.format("  (omitted)\n"))
      else
        for _, v in pairs(sortedMembers) do
          file:write(string.format("  %s: %s\n", v, type(root[name][v])))
        end
      end
      file:write("}\n")
    end
    file:flush()
    file:close()
  else
    log(tostring(err))
  end

  file, err = io.open(getPath("variables"), "w")
  if file then
    for _, name in pairs(variables) do
      file:write(string.format("%s: %s: %s\n", name, type(root[name]), tostring(root[name])))
    end
    file:flush()
    file:close()
  else
    log(tostring(err))
  end
end

function TKGDUMP_DUMP()
  dump(_G, "G")
  dump(session, "session")
  dump(ui, "ui")
end

---
-- @local
-- アドオン初期化処理.
-- フレームワークからの呼び出しを期待しているため、直接呼び出さないこと.
function TKGDUMP_ON_INIT()
end
