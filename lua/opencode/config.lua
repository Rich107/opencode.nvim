---@class opencode.Config: snacks.terminal.Opts
---@field auto_reload? boolean Automatically reload buffers changed by opencode
---@field opencode_cmd? string
---@field args? string[]
---@field win? snacks.win.Config
---@field picker_cfg? snacks.picker.layout.Config
local M = {}

M.defaults = {
  -- TODO:
  -- sync_theme = true,
  auto_reload = true,
  opencode_cmd = "opencode",
  args = {},
  win = {
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
  if M.options.auto_reload then
    M.setup_auto_reload()
  end
  return M.options
end

function M.setup_auto_reload()
  vim.o.autoread = true

  -- Autocommand group to avoid stacking duplicates on reload
  local grp = vim.api.nvim_create_augroup("OpencodeAutoReload", { clear = true })

  -- Trigger :checktime on the events that matter
  vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI", "TermClose" }, {
    group = grp,
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

return M
