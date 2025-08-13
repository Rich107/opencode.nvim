local M = {}

local function opencode_cmd()
  local port = require("opencode.config").options.port
  return "opencode" .. (port and (" --port " .. port) or "")
end

---@return snacks.win?, boolean?
function M.toggle()
  return require("snacks.terminal").toggle(opencode_cmd(), require("opencode.config").options.terminal)
end

---@return snacks.win?, boolean?
function M.get()
  return require("snacks.terminal").get(opencode_cmd(), require("opencode.config").options.terminal)
end

function M.show_if_exists()
  local win = require("snacks.terminal").get(
    opencode_cmd(),
    vim.tbl_deep_extend("force", require("opencode.config").options.terminal, { create = false })
  )
  if win then
    win:show()
  end
end

return M
