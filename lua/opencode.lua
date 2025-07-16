local M = {}

local config = require("opencode.config")
local terminal = require("opencode.terminal")

--@param opts opencode.Config
function M.setup(opts)
  config.setup(opts)
end

---Toggle the opencode window.
---@param opts? opencode.Config
function M.toggle(opts)
  return terminal.toggle(opts)
end

---Send a command to opencode (e.g. "/new").
---@param command string
---@param opts? opencode.Config
function M.command(command, opts)
  terminal.send(command, opts, false)
end

---Send a prompt to opencode.
---Inserts `opts.context` before sending.
---@param prompt string
---@param opts? opencode.Config
function M.prompt(prompt, opts)
  -- Add context
  local context = ""
  for name, fun in pairs(config.options.context) do
    local context_value = fun(prompt)
    if context_value ~= nil and context_value ~= "" then
      -- TODO: LLM sometimes gets distracted by the literal "@file" etc.
      -- Some may be more appropriate to replace inline in the prompt.
      context = context .. "**" .. name .. "**" .. ": " .. context_value .. "\n"
    end
  end

  if context ~= "" then
    prompt = context .. "\n" .. prompt
  end

  terminal.send(prompt, opts)
end

---Input a prompt to send to opencode.
---Convenience function that calls `send` internally.
---@param prefill? string Text to prefill the input with.
---@param opts? opencode.Config
function M.ask(prefill, opts)
  vim.ui.input({ prompt = "Ask opencode: ", default = prefill }, function(input)
    if input ~= nil then
      M.prompt(input, opts)
    end
  end)
end

return M
