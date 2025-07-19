local M = {}

---@class opencode.Config: snacks.terminal.Opts
---@field auto_reload? boolean Automatically reload buffers edited by opencode
---@field auto_focus? boolean Focus the opencode window after prompting
---@field command? string Command to launch opencode
---@field context? table<string, fun(string): string|nil> Context to add to prompts
local defaults = {
  auto_reload = false,
  auto_focus = false,
  -- TODO: default to system theme https://github.com/sst/opencode/issues/445#issuecomment-3071197414
  command = "opencode",
  win = {
    position = "right",
    enter = false,
    -- See https://github.com/folke/snacks.nvim/blob/main/docs/win.md for more window options
  },
  context = {
    ["@file"] = require("opencode.context").file,
    ["@files"] = require("opencode.context").files,
    ["@cursor"] = require("opencode.context").cursor_position,
    ["@selection"] = require("opencode.context").visual_selection,
    ["@diagnostics"] = require("opencode.context").diagnostics,
    ["@quickfix"] = require("opencode.context").quickfix,
    ["@diff"] = require("opencode.context").git_diff,
  },
  -- See https://github.com/folke/snacks.nvim/blob/main/docs/terminal.md for more terminal options
}

---@type opencode.Config
M.options = vim.deepcopy(defaults)

---@param opts? opencode.Config
function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.options, opts or {})

  if M.options.auto_reload then
    require("opencode.reload").setup()
  end

  return M.options
end

return M
