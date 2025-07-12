local M = {}

function M.replace_file(input)
  -- If the input contains '@file', replace it with the current file path
  local relative_path = vim.fn.expand("%:.")
  if relative_path == "" then
    vim.notify("No file is currently open.", vim.log.levels.WARN)
    return input
  end
  -- Prefix with '@' per opencode syntax
  local prefixed_relative_path = "@" .. relative_path
  return input:gsub("@file", prefixed_relative_path)
end

return M
