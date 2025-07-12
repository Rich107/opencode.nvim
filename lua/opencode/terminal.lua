local M = {}

local config = require("opencode.config")

---@param opts opencode.Config
---@return string
local function create_cmd(opts)
  local cmd = { opts.opencode_cmd }
  vim.list_extend(cmd, opts.args or {})

  return table.concat(cmd, " ")
end

---Toggle terminal visibility
---@param opts? opencode.Config Optional config that will override the base config for this call only
---@return snacks.win?
function M.toggle(opts)
  local snacks = require("snacks.terminal")

  opts = vim.tbl_deep_extend("force", config.options, opts or {})

  local cmd = create_cmd(opts)
  return snacks.toggle(cmd, opts)
end

---Send text to terminal
---@param text string Text to send
---@param opts? opencode.Config Optional config that will override the base config for this call only
---@param multi_line? boolean Whether to send as multi-line text (default: true)
function M.send(text, opts, multi_line)
  multi_line = multi_line == nil and true or multi_line
  opts = vim.tbl_deep_extend("force", config.options, opts or {})

  local cmd = create_cmd(opts)
  local term = require("snacks.terminal").get(cmd, opts)
  if not term then
    vim.notify("Please open an opencode terminal first.", vim.log.levels.INFO)
    return
  end

  if term and term:buf_valid() then
    local chan = vim.api.nvim_buf_get_var(term.buf, "terminal_job_id")
    if chan then
      if multi_line then
        -- Use bracketed paste sequences
        local bracket_start = "\27[200~"
        local bracket_end = "\27[201~\r"
        local bracketed_text = bracket_start .. text .. bracket_end
        vim.api.nvim_chan_send(chan, bracketed_text)
      else
        text = text:gsub("\n", " ") .. "\n"
        vim.api.nvim_chan_send(chan, text)
      end
    else
      vim.notify("No opencode terminal job found!", vim.log.levels.ERROR)
    end
  else
    vim.notify("Please open an opencode terminal first.", vim.log.levels.INFO)
  end
end

---Send a command to the terminal
---@param command string opencode command (e.g. "/add")
---@param text? string Text to send after the command
---@param opts? opencode.Config Optional config that will override the base config for this call only
function M.command(command, text, opts)
  text = text or ""

  -- NOTE: For opencode commands that shouldn't get a newline (e.g. `/add file`)
  M.send(command .. " " .. text, opts, false)
end

return M
