local M = {}

local config = require("opencode.config")

---Toggle terminal visibility
---@param opts? opencode.Config
---@return snacks.win?
function M.toggle(opts)
  local snacks = require("snacks.terminal")
  opts = vim.tbl_deep_extend("force", config.options, opts or {})
  return snacks.toggle(opts.command, opts)
end

---Send text to terminal.
---@param text string
---@param opts? opencode.Config
---@param multi_line? boolean Whether to send as multi-line text (default: true)
function M.send(text, opts, multi_line)
  multi_line = multi_line == nil and true or multi_line
  opts = vim.tbl_deep_extend("force", config.options, opts or {})

  local prev_win = vim.api.nvim_get_current_win()
  local term, created = require("snacks.terminal").get(opts.command, opts)

  if created then
    -- Wait for opencode to be ready before sending text.
    -- Would prefer to use a callback or event, but not sure what...
    ---@diagnostic disable-next-line: missing-return
    vim.wait(1000, function() end)
  end

  if not term or not term:buf_valid() then
    -- Can still happen if they configure snacks.terminal with create = false
    vim.notify("Please open an opencode terminal first.", vim.log.levels.INFO)
    return
  end

  local chan = vim.api.nvim_buf_get_var(term.buf, "terminal_job_id")
  if not chan then
    vim.notify("No opencode terminal job found!", vim.log.levels.ERROR)
    return
  end

  if multi_line then
    -- Use bracketed paste sequences
    local bracket_start = "\27[200~"
    local bracket_end = "\27[201~\r"
    local bracketed_text = bracket_start .. text .. bracket_end
    vim.api.nvim_chan_send(chan, bracketed_text)
  else
    text = text:gsub("\n", " ")
    vim.api.nvim_chan_send(chan, text)
    -- Wait for opencode to show the command menu - it's not
    -- enough to simply send the exact command text
    ---@diagnostic disable-next-line: missing-return
    vim.wait(200, function() end)
    -- Select the command menu item
    vim.api.nvim_chan_send(chan, "\r")
  end

  term:show()

  if opts.auto_focus then
    term:focus()
  elseif created then
    -- Manually re-focus the previous window.
    -- snacks.terminal does not seem to have an option to prevent focusing the new terminal.
    vim.cmd("stopinsert") -- Ensure we leave insert mode in the terminal buffer
    vim.api.nvim_set_current_win(prev_win)
    -- TODO: opencode cursor remains visible,
    -- which is not the case when manually entering Normal mode then switching windows
  end
end

return M
