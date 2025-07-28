local M = {}

---@class opencode.Config
---@field provider_id? string [Provider](https://models.dev/) to use for opencode requests
---@field model_id? string [Model](https://models.dev/) to use for opencode requests
---@field port? number The port opencode is running on — use `--port <port>`. If `nil`, tries to find a running instance in or under Neovim's CWD.
---@field auto_reload? boolean Automatically reload buffers edited by opencode
---@field context? table<string, fun(string): string|nil> Context to add to prompts
---@field input? snacks.input.Opts Input options — see [snacks.input](https://github.com/folke/snacks.nvim/blob/main/docs/input.md)
---@field terminal? snacks.terminal.Opts Terminal options — see [snacks.terminal](https://github.com/folke/snacks.nvim/blob/main/docs/terminal.md)
local defaults = {
  provider_id = "github-copilot",
  model_id = "gpt-4.1",
  port = nil,
  auto_reload = false,
  context = {
    ["@file"] = require("opencode.context").file,
    ["@files"] = require("opencode.context").files,
    ["@cursor"] = require("opencode.context").cursor_position,
    ["@selection"] = require("opencode.context").visual_selection,
    ["@diagnostic"] = function()
      return require("opencode.context").diagnostics(true)
    end,
    ["@diagnostics"] = require("opencode.context").diagnostics,
    ["@quickfix"] = require("opencode.context").quickfix,
    ["@diff"] = require("opencode.context").git_diff,
  },
  input = {
    prompt = "Ask opencode",
    icon = "󱚣",
    completion = "customlist,v:lua.require'opencode.cmp'",
  },
  terminal = {
    win = { position = "right" },
  },
}

---@type opencode.Config
M.options = vim.deepcopy(defaults)

---@param opts? opencode.Config
---@return opencode.Config
function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.options, opts or {})

  if M.options.auto_reload then
    require("opencode.reload").setup()
  end

  return M.options
end

return M
