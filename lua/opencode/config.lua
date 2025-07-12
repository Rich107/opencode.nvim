---@class opencode.Config: snacks.terminal.Opts
---@field auto_reload? boolean Automatically reload buffers changed by Aider (requires vim.o.autoread = true)
---@field opencode_cmd? string
---@field args? string[]
---@field win? snacks.win.Config
---@field picker_cfg? snacks.picker.layout.Config
local M = {}

M.defaults = {
  auto_reload = true,
  opencode_cmd = "opencode",
  args = {},
  win = {
    wo = { winbar = "opencode" },
    style = "opencode",
    position = "right",
  },
  picker_cfg = {
    preset = "vscode",
  },
}

---@type opencode.Config
M.options = vim.deepcopy(M.defaults)

---@param opts? opencode.Config
function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.options, opts or {})
  Snacks.config.style("opencode", {})
  return M.options
end

return M
