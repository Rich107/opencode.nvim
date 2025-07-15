local M = {}

-- NOTE: Seems files - like commands - need to be "selected" in the menu that appears when they're typed.
-- We can't just send the text. But opencode will usually use the `read` tool anyway so it's fine.
function M.file()
  return vim.api.nvim_buf_get_name(0)
end

return M
