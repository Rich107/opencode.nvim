local M = {}

---@class opencode.Config: snacks.terminal.Opts
---@field auto_reload boolean Automatically reload buffers changed by opencode
---@field auto_focus boolean Focus the opencode window after prompting
---@field command string Command to launch opencode
---@field context table<string, fun(): string> Context added to prompts
local defaults = {
  auto_reload = false,
  auto_focus = false,
  -- TODO: default to system theme https://github.com/sst/opencode/issues/445#issuecomment-3071197414
  command = "opencode",
  win = {
    position = "right",
  },
  context = {
    file = require("opencode.context").file,
    cursor = require("opencode.context").cursor_position,
    selection = require("opencode.context").visual_selection,
    diagnostics = require("opencode.context").diagnostics,
  },
}

---@type opencode.Config
M.options = vim.deepcopy(defaults)

local function setup_auto_reload()
  if not vim.o.autoread then
    vim.notify("Please enable autoread to use opencode.nvim auto_reload", vim.log.levels.WARN)
    return
  end

  -- Autocommand group to avoid stacking duplicates on reload
  local group = vim.api.nvim_create_augroup("OpencodeAutoReload", { clear = true })

  -- Trigger :checktime on the events that matter
  vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI", "TermClose" }, {
    group = group,
    pattern = "*",
    callback = function()
      -- Don’t interfere while editing a command line or in terminal‑insert mode
      if vim.fn.mode():match("[ciR!t]") == nil and vim.fn.getcmdwintype() == "" then
        vim.cmd("checktime")
      end
    end,
    desc = "Reload buffer if the underlying file was changed by opencode or anything else",
  })
end

---@param opts? opencode.Config
function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.options, opts or {})

  if M.options.auto_reload then
    setup_auto_reload()
  end

  return M.options
end

return M
