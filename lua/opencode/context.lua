local M = {}

local function current_file_path()
  -- Relative paths are prettier and more readable.
  -- But may be less reliable...?
  -- Probably only if they pass a different `cwd` to the terminal config.
  return vim.fn.expand("%:.")
  -- Absolute path
  -- return vim.api.nvim_buf_get_name(0)
end

function M.file()
  return current_file_path()
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
    -- Handle "backwards" selection
    start_line, end_line = end_line, start_line
  end
  local file_path = current_file_path()

  -- Exit visual mode now that we've "consumed" the selection
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)

  return string.format("%s:L%d-%d", file_path, start_line, end_line)
end

function M.diagnostics()
  local diagnostics = vim.diagnostic.get(0)
  if #diagnostics == 0 then
    return nil
  end

  local file_path = current_file_path()
  local message = #diagnostics .. " error" .. (#diagnostics > 1 and "s" or "") .. ":"

  for _, diagnostic in ipairs(diagnostics) do
    local start_line = diagnostic.lnum + 1 -- Convert to 1-based line numbers
    local start_col = diagnostic.col + 1
    local end_line = diagnostic.end_lnum + 1
    local end_col = diagnostic.end_col + 1
    local short_message = diagnostic.message:gsub("%s+", " "):gsub("^%s", ""):gsub("%s$", "")

    message = string.format(
      "%s\n  - %s:L%d:C%d-L%d:C%d: (%s) %s",
      message,
      file_path,
      start_line,
      start_col,
      end_line,
      end_col,
      diagnostic.source or "unknown source",
      short_message
    )
  end

  return message
end

function M.cursor_position()
  local pos = vim.api.nvim_win_get_cursor(0)
  local line = pos[1]
  local col = pos[2] + 1 -- Convert to 1-based index

  -- Include file path so we don't depend on `file` context.
  -- We don't replace `file` with `cursor_position` because the LLM can over-index on the cursor position.
  -- e.g. "Analyze this file" will pay special attention to the code surrounding the cursor.
  local file_path = current_file_path()

  return string.format("%s:L%d:C%d", file_path, line, col)
end

return M
