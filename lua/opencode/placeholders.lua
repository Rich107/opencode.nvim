local M = {}

function M.replace_file(input)
  -- Replace @file with the current file path
  if input:find("@file") then
    local relative_path = vim.fn.expand("%:.")
    if relative_path == "" then
      vim.notify("No file is currently open.", vim.log.levels.WARN)
      return input
    end
    return input:gsub("@file", "@" .. relative_path)
  end
  return input
end

return M
