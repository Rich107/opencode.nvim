local M = {}

local config = require("opencode.config")
local terminal = require("opencode.terminal")

--@param opts opencode.Config
function M.setup(opts)
  config.setup(opts)
end

---Toggle the opencode window.
---@param opts? opencode.Config Optional config that will override the base config for this call only
function M.toggle(opts)
  return terminal.toggle(opts)
end

---Send a command to opencode.
---@param command string opencode command (e.g. "/new")
---@param opts? opencode.Config Optional config that will override the base config for this call only
function M.command(command, opts)
  terminal.send(command, opts, false)
end

---Send a prompt to opencode.
---Prepends visual selection and expands placeholders before sending.
---@param prompt string The prompt to send
---@param opts? opencode.Config Optional config that will override the base config for this call only
function M.send(prompt, opts)
  local mode = vim.fn.mode()
  local is_visual = mode:match("[vV\22]")
  if is_visual then
    local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = mode })
    local selected_text = table.concat(lines, "\n")
    prompt = prompt .. "\n\n" .. selected_text
  end

  -- Expand placeholders
  for placeholder, replace_func in pairs(config.options.expansions) do
    prompt = prompt:gsub(placeholder, replace_func())
  end

  terminal.send(prompt, opts)
end

---Input a prompt to send to opencode.
---Convenience function that calls `send` internally.
---@param opts? opencode.Config Optional config that will override the base config for this call only
function M.ask(opts)
  vim.ui.input({ prompt = "Ask opencode: " }, function(input)
    if input ~= nil then
      M.send(input, opts)
    end
  end)
end

return M
