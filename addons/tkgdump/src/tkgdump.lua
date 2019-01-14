---
-- tkgdump

local log = TKGDEBUGGER_LOG or CHAT_SYSTEM or print

function TKGDUMP_DUMP()
  local functions = {}
  local uds = {}
  local tables = {}
  local variables = {}
  for k, v in pairs(_G) do
    local aType = type(v)
    if aType == "function" then
      if k ~= "TKGDUMP_DUMP" and k ~= "TKGDUMP_ON_INIT" then
        table.insert(functions, k)
      end
    elseif aType == "userdata" then
      table.insert(uds, k)
    elseif aType == "table" then
      if k ~= "_G" then
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

  local file, err = io.open("../addons/tkgdump/dump_functions.txt", "w")
  if file then
    for _, name in pairs(functions) do
      file:write(string.format("%s\n", name))
    end
    file:flush()
    file:close()
  else
    log(tostring(err))
  end

  file, err = io.open("../addons/tkgdump/dump_userdata.txt", "w")
  if file then
    for _, name in pairs(uds) do
      local meta = getmetatable(_G[name])
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

  file, err = io.open("../addons/tkgdump/dump_tables.txt", "w")
  if file then
    for _, name in pairs(tables) do
      local sortedMembers = {}
      for k, _ in pairs(_G[name]) do
        table.insert(sortedMembers, k)
      end
      table.sort(sortedMembers, sortIgnoreCase)

      file:write(string.format("%s = {\n", name))
      for _, v in pairs(sortedMembers) do
        file:write(string.format("  %s: %s\n", v, type(_G[name][v])))
      end
      file:write("}\n")
    end
    file:flush()
    file:close()
  else
    log(tostring(err))
  end

  file, err = io.open("../addons/tkgdump/dump_variables.txt", "w")
  if file then
    for _, name in pairs(variables) do
      file:write(string.format("%s: %s: %s\n", name, type(_G[name]), tostring(_G[name])))
    end
    file:flush()
    file:close()
  else
    log(tostring(err))
  end
end

---
-- @local
-- アドオン初期化処理.
-- フレームワークからの呼び出しを期待しているため、直接呼び出さないこと.
function TKGDUMP_ON_INIT()
end
