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
-- FIX: How to press "enter" after?
-- I don't understand why it works fine with `ask`.
-- That uses multi-line, which ends with \r.
-- But single line uses \n.
-- I tried sending commands with multi-line but it just sends the actual text - doesn't select the command.
-- Maybe we need to send the text, wait a moment for the menu to appear, and then send the enter key?
-- function M.command(command, opts)
--   terminal.send(command, opts, false)
-- end

---Send a prompt to opencode.
---Includes visual mode selection.
---Replaces `@file` with current file's path.
---@param text? string Optional text to send; will prompt for input if not provided
---@param opts? opencode.Config Optional config that will override the base config for this call only
function M.ask(text, opts)
  local mode = vim.fn.mode()
  local is_visual = vim.fn.mode():match("[vV\22]")

  local function send(prompt)
    if is_visual then
      local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = mode })
      local selected_text = table.concat(lines, "\n")
      terminal.send(selected_text .. "\n\n" .. placeholders.replace_file(prompt), opts)
    else
      terminal.send(placeholders.replace_file(prompt), opts)
    end
  end

  if text then
    send(text)
  else
    vim.ui.input(
      { prompt = is_visual and "Add a prompt to your selection (empty to skip): " or "Ask opencode: " },
      function(input)
        if input and input ~= "" then
          send(input)
        end
      end
    )
  end
end

return M
