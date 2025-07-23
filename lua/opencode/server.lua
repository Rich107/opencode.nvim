local M = {}

---@return table<number>
function M.get_all_pids()
  local handle = io.popen("ps aux | grep 'opencode$' | grep -v grep | awk '{print $2}'")
  if not handle then
    return {}
  end
  local output = handle:read("*a")
  handle:close()

  local pids = {}
  for pid_str in output:gmatch("[^\r\n]+") do
    local pid = tonumber(pid_str:match("^%s*(.-)%s*$"))
    if pid then
      table.insert(pids, pid)
    end
  end
  return pids
end

---@param pid number
---@return number|nil
function M.get_port(pid)
  local command = "lsof -p " .. pid .. " | grep LISTEN | grep TCP | awk '{print $9}' | cut -d: -f2"
  local handle = io.popen(command)
  if not handle then
    return nil
  end
  local port = handle:read("*a")
  handle:close()
  port = port:match("^%s*(.-)%s*$") -- trim whitespace
  if port == "" then
    return nil
  end
  return tonumber(port)
end

---@param pid number
---@return string|nil
function M.get_cwd(pid)
  local command = "lsof -a -p " .. pid .. " -d cwd | tail -1 | awk '{print $NF}'"
  local handle = io.popen(command)
  if not handle then
    return nil
  end
  local cwd = handle:read("*a")
  handle:close()
  cwd = cwd:match("^%s*(.-)%s*$") -- trim whitespace
  if cwd == "" then
    return nil
  end
  return cwd
end

return M
