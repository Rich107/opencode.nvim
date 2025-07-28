local config = require("opencode.config")

---Generate completion items for snacks.input or customlist completion.
---This function finds the last word in the current command line and, for each matching
---placeholder in the config context, returns the entire command line with that word replaced.
---This is necessary because snacks.input replaces the whole input with the selected completion.
---@param ArgLead string The text to be completed (not used directly; snacks.input passes the full line).
---@param CmdLine string The entire current input line.
---@param CursorPos number The cursor position in the input line (not used).
---@return table
return function(ArgLead, CmdLine, CursorPos)
  -- Find the start and end of the latest word in CmdLine
  local start_idx, end_idx = CmdLine:find("([^%s]+)$")
  if not start_idx then
    return {}
  end

  local latest_word = CmdLine:sub(start_idx, end_idx)

  local items = {}
  for placeholder, _ in pairs(config.options.context) do
    if placeholder:find(latest_word, 1, true) == 1 then
      -- Replace the latest word in CmdLine with the placeholder.
      -- Normally for vim's customlist completion we'd just return the placeholder/completion item,
      -- but snacks.input seems to pass the entire command line as ArgLead and thus also replaces the
      -- entire command line with the completion item.
      local new_cmd = CmdLine:sub(1, start_idx - 1) .. placeholder .. CmdLine:sub(end_idx + 1)
      table.insert(items, new_cmd)
    end
  end
  return items
end
