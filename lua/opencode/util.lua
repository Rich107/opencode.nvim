local M = {}

---@param command string
---@return string
function M.exec(command)
  local executable = vim.split(command, " ")[1]
  if vim.fn.executable(executable) == 0 then
    -- WARNING: lsof is the only utility in this plugin that's not guaranteed to be available on all systems.
    error("'" .. executable .. "' command is not available — please install it", 0)
  end

  local handle = io.popen(command)
  if not handle then
    error("Couldn't execute command: " .. command, 0)
  end

  local output = handle:read("*a")
  handle:close()
  return output
end

return M
