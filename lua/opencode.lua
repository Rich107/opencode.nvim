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

---Prompt for input and send to opencode.
---Includes visual mode selection.
---Replaces `@file` with current file's path.
---@param prompt? string Optional text to send instead of prompting for input
---@param opts? opencode.Config Optional config that will override the base config for this call only
function M.ask(prompt, opts)
  local mode = vim.fn.mode()
  local is_visual = vim.fn.mode():match("[vV\22]")
  local selected_text

  if is_visual then
    local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = mode })
    selected_text = table.concat(lines, "\n")
  end

  local function send(text)
    terminal.send(placeholders.replace_file(text), opts or {})
  end

  if prompt then
    if is_visual then
      send(selected_text .. "\n\n" .. prompt)
    else
      send(prompt)
    end
    return
  end

  if is_visual then
    vim.ui.input({ prompt = "Add a prompt to your selection (empty to skip): " }, function(input)
      local text = selected_text
      if input and input ~= "" then
        text = text .. "\n\n" .. input
      end
      send(text)
    end)
  else
    vim.ui.input({ prompt = "Ask opencode: " }, function(input)
      if input and input ~= "" then
        send(input)
      end
    end)
  end
end

---Send arbitrary text to opencode.
---@param text string Text to send to opencode
---@param opts? opencode.Config Optional config that will override the base config for this call only
function M.send(text, opts)
  terminal.send(text, opts or {})
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

return M
