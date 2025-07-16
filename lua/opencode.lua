local M = {}

local context = require("opencode.context")
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
---Injects context before sending.
---@param prompt string
---@param opts? opencode.Config
function M.prompt(prompt, opts)
  local context_injected_prompt = context.inject(prompt, opts or config.options)
  terminal.send(context_injected_prompt, opts)
end

---Input a prompt to send to opencode.
---Convenience function that calls `prompt` internally.
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
