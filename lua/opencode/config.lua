local M = {}

---@class opencode.Config
---@field port? number The port opencode's server is running on. If `nil`, searches for an opencode process inside Neovim's CWD — usually you can leave this unset unless that fails. Embedded instances will automatically use this — launch external instances with `opencode --port <port>`.
---@field auto_reload? boolean Automatically reload buffers edited by opencode
---@field prompts? table<string, opencode.Prompt> Prompts to select from
---@field context? table<string, fun(string): string|nil> Context to add to prompts
---@field input? snacks.input.Opts Input options — see [snacks.input](https://github.com/folke/snacks.nvim/blob/main/docs/input.md)
---@field terminal? snacks.terminal.Opts Terminal options — see [snacks.terminal](https://github.com/folke/snacks.nvim/blob/main/docs/terminal.md)
local defaults = {
  port = nil,
  auto_reload = false,
  prompts = {
    ---@class opencode.Prompt
    ---@field description? string Description of the prompt
    ---@field prompt? string The prompt to send to opencode, with placeholders for context like `@cursor`, `@file`, etc.
    ---@field key? string Optional key to bind the prompt to a keymap
    explain = {
      description = "Explain code near cursor",
      prompt = "Explain @cursor and its context",
    },
    review = {
      description = "Review file",
      prompt = "Review @file for correctness and readability",
    },
    fix = {
      description = "Fix diagnostics",
      prompt = "Fix these @diagnostics",
    },
    optimize = {
      description = "Optimize selection",
      prompt = "Optimize @selection for performance and readability",
    },
    document = {
      description = "Document selection",
      prompt = "Add documentation comments for @selection",
    },
    test = {
      description = "Add tests for selection",
      prompt = "Add tests for @selection",
    },
  },
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
    -- Built-in completion as fallback.
    -- It's okay to enable simultaneously with blink.cmp because built-in completion
    -- only triggers via <Tab> and blink.cmp keymaps take priority.
    completion = "customlist,v:lua.require'opencode.cmp.omni'",
    win = {
      title_pos = "left",
      relative = "cursor",
      row = -3,
      col = 0,
      b = {
        -- Enable blink completion
        completion = true,
      },
      bo = {
        -- Custom filetype to configure blink with
        filetype = "opencode_ask",
      },
    },
  },
  terminal = {
    win = {
      position = "right",
      -- I usually want to `toggle` and then immediately `ask` — seems like a sensible default
      enter = false,
    },
    env = {
      -- Other themes have visual bugs in embedded terminals: https://github.com/sst/opencode/issues/445
      OPENCODE_THEME = "system",
    },
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
