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
---Prepends visual selection and contexts before sending.
---@param prompt string The prompt to send
---@param opts? opencode.Config Optional config that will override the base config for this call only
function M.send(prompt, opts)
  -- Add context
  -- TODO: Allow overriding context in opts
  local context = ""
  for name, fun in pairs(config.options.context) do
    local context_value = fun()
    if context_value ~= nil and context_value ~= "" then
      context = context .. name .. ": " .. context_value .. "\n"
    end
  end

  if context ~= "" then
    prompt = context .. "\n" .. prompt
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
