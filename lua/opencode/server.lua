local M = {}

---@param command string
---@return string|nil
local function exec(command)
  if command:match("^lsof") and vim.fn.executable("lsof") == 0 then
    -- lsof is the only utility in this file that's not guaranteed to be available on all systems.
    vim.notify(
      "'lsof' command is not available. Please install it to auto-find the opencode server, or set opts.port.",
      vim.log.levels.ERROR,
      { title = "opencode" }
    )
    return nil
  end

  local handle = io.popen(command)
  if not handle then
    vim.notify("Couldn't execute command: " .. command, vim.log.levels.ERROR, { title = "opencode" })
    return nil
  end

  local output = handle:read("*a")
  handle:close()
  return output
end

---@return table<number>|nil
local function get_all_pids()
  -- Regex also allows flags like --port
  local output = exec("ps aux | grep -E 'opencode(\\s+--.*)?$' | grep -v grep | awk '{print $2}'")
  if not output then
    vim.notify("Couldn't retrieve PIDs", vim.log.levels.ERROR, { title = "opencode" })
    return nil
  end

  local pids = {}
  for pid_str in output:gmatch("[^\r\n]+") do
    local pid = tonumber(pid_str:match("^%s*(.-)%s*$"))
    if pid then
      table.insert(pids, pid)
    end
  end
  return pids
end

---Beware: returns special values for some ports, e.g. 6969 = "acmsoda".
---@param pid number
---@return number|nil
local function get_port(pid)
  local port = exec("lsof -p " .. pid .. " | grep LISTEN | grep TCP | awk '{print $9}' | cut -d: -f2")
  port = (port or ""):match("^%s*(.-)%s*$") -- trim whitespace
  if port == "" then
    vim.notify("Couldn't determine opencode server's port", vim.log.levels.ERROR, { title = "opencode" })
    return nil
  end
  return tonumber(port)
end

---@param pid number
---@return string|nil
local function get_cwd(pid)
  local cwd = exec("lsof -a -p " .. pid .. " -d cwd | tail -1 | awk '{print $NF}'")
  cwd = (cwd or ""):match("^%s*(.-)%s*$") -- trim whitespace
  if cwd == "" then
    vim.notify("Couldn't determine opencode server's CWD", vim.log.levels.ERROR, { title = "opencode" })
    return nil
  end
  return cwd
end

local function find_pid_inside_neovim_cwd()
  local server_pid
  for _, pid in ipairs(get_all_pids() or {}) do
    local opencode_cwd = get_cwd(pid)
    -- CWDs match exactly, or opencode's CWD is under neovim's CWD.
    if opencode_cwd and opencode_cwd:find(vim.fn.getcwd(), 1, true) == 1 then
      server_pid = pid
      break
    end
  end

  if not server_pid then
    vim.notify(
      "Couldn't find an opencode server process running inside Neovim's CWD",
      vim.log.levels.ERROR,
      { title = "opencode" }
    )
    return nil
  end

  return server_pid
end

---Find the port of an opencode server process running inside Neovim's CWD.
---@return number|nil
function M.find_port()
  local server_pid = find_pid_inside_neovim_cwd()
  if not server_pid then
    return nil
  end

  return get_port(server_pid)
end

return M
