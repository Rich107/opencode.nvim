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

---Send a prompt to opencode. Supports visual mode selection.
---You can reference the current file with @file.
---@param opts? opencode.Config Optional config that will override the base config for this call only
function M.ask(opts)
  local mode = vim.fn.mode()

  -- Visual mode handling
  if vim.tbl_contains({ "v", "V", "" }, mode) then
    local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = mode })
    local selected_text = table.concat(lines, "\n")

    vim.ui.input({ prompt = "Add a prompt to your selection (empty to skip):" }, function(input)
      if input ~= nil then
        if input ~= "" then
          selected_text = selected_text .. "\n\n" .. placeholders.replace_file(input)
        end
        terminal.send(selected_text, opts or {}, true)
      end
    end)
  else
    -- Normal mode handling
    vim.ui.input({ prompt = "Ask opencode:" }, function(input)
      if input then
        terminal.send(placeholders.replace_file(input), opts or {})
      end
    end)
  end
end

---Send text to opencode.
---@param text string Text to send to opencode
---@param opts? opencode.Config Optional config that will override the base config for this call only
function M.send(text, opts)
  terminal.send(text, opts or {})
end

---Send a command to opencode.
---@param command string opencode command (e.g. "/new")
---@param opts? opencode.Config Optional config that will override the base config for this call only
function M.command(command, opts)
  -- FIX: How to press "enter" after?
  -- I don't understand why it works fine with `ask`.
  -- That uses multi-line, which ends with \r.
  -- But single line uses \n.
  -- I tried sending commands with multi-line but it just sends the actual text - doesn't select the command.
  -- Maybe we need to send the text, wait a moment for the menu to appear, and then send the enter key?
  terminal.send(command, opts, false)
end

return M
