local M = {}

---@param command string
---@return string
local function exec(command)
  if command:match("^lsof") and vim.fn.executable("lsof") == 0 then
    -- lsof is the only utility in this file that's not guaranteed to be available on all systems.
    error("'lsof' command is not available — please install it to auto-find the opencode, or set opts.port", 0)
  end

  local handle = io.popen(command)
  if not handle then
    error("Couldn't execute command: " .. command, 0)
  end

  local output = handle:read("*a")
  handle:close()
  return output
end

---@return table<number>
local function get_all_pids()
  -- Regex also allows flags like --port
  local output = exec("ps -o pid,comm | awk '$2 == \"opencode\" {print $1}'")
  if not output then
    error("Couldn't retrieve PIDs", 0)
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
---@return number
local function get_port(pid)
  local port = exec("lsof -p " .. pid .. " | grep LISTEN | grep TCP | awk '{print $9}' | cut -d: -f2")
  port = (port or ""):match("^%s*(.-)%s*$") -- trim whitespace
  if port == "" then
    error("Couldn't determine opencode's port", 0)
  end
  return tonumber(port) or error("Found opencode port is not a number: " .. port, 0)
end

---@param pid number
---@return string
local function get_cwd(pid)
  local cwd = exec("lsof -a -p " .. pid .. " -d cwd | tail -1 | awk '{print $NF}'")
  cwd = (cwd or ""):match("^%s*(.-)%s*$") -- trim whitespace
  if cwd == "" then
    error("Couldn't determine opencode's CWD", 0)
  end
  return cwd
end

local function is_descendant_of_neovim(pid)
  local neovim_pid = vim.fn.getpid()
  local current_pid = pid

  -- Walk up because the way some shells launch processes,
  -- Neovim will not be the direct parent.
  for _ = 1, 10 do -- limit to 10 steps to avoid infinite loop
    local output = exec("ps -o ppid= -p " .. current_pid)
    local parent_pid = tonumber((output or ""):match("^%s*(.-)%s*$"))
    if not parent_pid or parent_pid == 1 then
      return false
    end
    if parent_pid == neovim_pid then
      return true
    end
    current_pid = parent_pid
  end

  return false
end

local function find_pid_inside_neovim_cwd()
  local server_pid
  for _, pid in ipairs(get_all_pids() or {}) do
    local opencode_cwd = get_cwd(pid)
    -- CWDs match exactly, or opencode's CWD is under neovim's CWD.
    if opencode_cwd and opencode_cwd:find(vim.fn.getcwd(), 1, true) == 1 then
      server_pid = pid
      if is_descendant_of_neovim(pid) then
        -- Prioritize embedded
        break
      end
    end
  end

  if not server_pid then
    error("Couldn't find an opencode process running inside Neovim's CWD", 0)
  end

  return server_pid
end

---Find the port of an opencode server process running inside Neovim's CWD.
---@return number
function M.find_port()
  local ok, server_pid = pcall(find_pid_inside_neovim_cwd)
  if not ok then
    error(server_pid, 0)
  end

  local ok2, port = pcall(get_port, server_pid)
  if not ok2 then
    error(port, 0)
  end

  return port
end

---@param callback fun(ok: boolean, result: any) Called with eventually found port or error if not found after some time.
function M.poll_for_port(callback)
  local retries = 0
  local timer = vim.uv.new_timer()
  timer:start(
    100,
    100,
    vim.schedule_wrap(function()
      local ok, port_result = pcall(M.find_port)
      if ok then
        timer:stop()
        callback(true, port_result)
      elseif retries >= 20 then
        timer:stop()
        callback(false, port_result)
      else
        retries = retries + 1
      end
    end)
  )
end

return M
