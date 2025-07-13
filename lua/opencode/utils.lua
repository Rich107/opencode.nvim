local M = {}

function M.replace_ask_placeholders(text, placeholders)
  if not text then
    return text
  end

  for placeholder, func in pairs(placeholders or {}) do
    text = text:gsub(placeholder, func())
  end

  return text
end

return M
