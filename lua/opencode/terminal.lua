local M = {}

local config = require("opencode.config")

---Toggle terminal visibility
---@param opts? opencode.Config Optional config that will override the base config for this call only
---@return snacks.win?
function M.toggle(opts)
  local snacks = require("snacks.terminal")
  opts = vim.tbl_deep_extend("force", config.options, opts or {})
  return snacks.toggle(opts.command, opts)
end

---Send text to terminal
---@param text string Text to send
---@param opts? opencode.Config Optional config that will override the base config for this call only
---@param multi_line? boolean Whether to send as multi-line text (default: true)
function M.send(text, opts, multi_line)
  multi_line = multi_line == nil and true or multi_line
  opts = vim.tbl_deep_extend("force", config.options, opts or {})

  -- NOTE: snacks.terminal.get() defaults to creating a terminal if it doesn't exist
  -- TODO: Race condition when it's not created yet and we try to send too quickly (I guess)?
  local term = require("snacks.terminal").get(opts.command, opts)

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

      if opts.auto_focus then
        term:focus()
        -- Exit visual mode if applicable
        if vim.fn.mode():match("[vV\22]") then
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
        end
      end
    else
      vim.notify("No opencode terminal job found!", vim.log.levels.ERROR)
    end
  else
    vim.notify("Please open an opencode terminal first.", vim.log.levels.INFO)
  end
end

return M
