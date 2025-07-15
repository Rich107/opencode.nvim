local M = {}

-- NOTE: Seems files - like commands - need to be "selected" in the menu that appears when they're typed.
-- We can't just send the text. But opencode will usually use the `read` tool anyway so it's fine.
function M.file()
  return vim.api.nvim_buf_get_name(0)
end

function M.visual_selection()
  local mode = vim.fn.mode()
  local is_visual = mode:match("[vV\22]")

  if not is_visual then
    return nil
  end

  local start_pos = vim.fn.getpos("v")
  local end_pos = vim.fn.getpos(".")
  local start_line = start_pos[2]
  local end_line = end_pos[2]
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end
  local file_path = vim.api.nvim_buf_get_name(0)

  -- Exit visual mode now that we've "consumed" the selection
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)

  return string.format("%s:L%d-%d", file_path, start_line, end_line)
end

function M.diagnostics()
  -- TODO:
  return nil
end

function M.cursor_position()
  local pos = vim.api.nvim_win_get_cursor(0)
  local line = pos[1]
  local col = pos[2] + 1 -- Convert to 1-based index
  local file_path = vim.api.nvim_buf_get_name(0)

  return string.format("%s:L%d:C%d", file_path, line, col)
end

return M
