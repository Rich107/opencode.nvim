local M = {}

local function opencode_cmd()
  local port = require("opencode.config").options.port
  return "opencode" .. (port and (" --port " .. port) or "")
end

function M.toggle()
  require("snacks.terminal").toggle(opencode_cmd(), require("opencode.config").options.terminal)
end

---Open an embedded opencode terminal.
---Returns whether the terminal was successfully opened.
---@return boolean
function M.open()
  -- We use `get`, not `open`, so `toggle` will reference the same terminal
  local win = require("snacks.terminal").get(opencode_cmd(), require("opencode.config").options.terminal)
  return win ~= nil
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
