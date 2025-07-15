local M = {}

---@class opencode.Config: snacks.terminal.Opts
---@field auto_reload boolean Automatically reload buffers changed by opencode
---@field auto_focus boolean Show and focus the terminal after sending text
---@field command string Command to launch opencode
---@field expansions table<string, fun(): string> Prompt placeholder expansions
local defaults = {
  auto_reload = false,
  auto_focus = true,
  -- TODO: default to system theme https://github.com/sst/opencode/issues/445#issuecomment-3071197414
  command = "opencode",
  win = {
    position = "right",
  },
  expansions = {
    -- WARNING: Hmm, seems files - like commands - need to be "selected" in the menu that appears when they're typed.
    -- We can't just send the text. But it usually uses the `read` tool anyway so it's fine.
    -- TODO: Open an issue in sst/opencode for this and commands?
    ["@file"] = function()
      return vim.api.nvim_buf_get_name(0)
    end,
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
