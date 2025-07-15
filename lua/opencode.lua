local M = {}

local config = require("opencode.config")
local terminal = require("opencode.terminal")
local placeholders = require("opencode.placeholders")

--@param opts opencode.Config
function M.setup(opts)
  config.setup(opts)
end

---Toggle the opencode window.
---@param opts? opencode.Config Optional config that will override the base config for this call only
function M.toggle(opts)
  return terminal.toggle(opts)
end

---Send arbitrary text to opencode.
---@param text string Text to send to opencode
---@param opts? opencode.Config Optional config that will override the base config for this call only
function M.send(text, opts)
  terminal.send(text, opts)
end

---Send a command to opencode.
---@param command string opencode command (e.g. "/new")
---@param opts? opencode.Config Optional config that will override the base config for this call only
function M.command(command, opts)
  terminal.send(command, opts, false)
end

---Send a prompt to opencode.
---Includes visual mode selection.
---Replaces `@file` with current file's path.
---@param prompt? string Optional text to send; will prompt for input if not provided
---@param opts? opencode.Config Optional config that will override the base config for this call only
function M.ask(prompt, opts)
  local function send(input)
    local mode = vim.fn.mode()
    local is_visual = mode:match("[vV\22]")
    if is_visual then
      -- Prepend selection
      local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = mode })
      local selected_text = table.concat(lines, "\n")
      input = input .. "\n\n" .. selected_text
    end

    terminal.send(placeholders.replace_file(input), opts)
  end

  if prompt then
    send(prompt)
  else
    vim.ui.input({ prompt = "Ask opencode: " }, function(input)
      if input ~= nil then
        send(input)
      end
    end)
  end
end

return M
