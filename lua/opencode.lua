local M = {}

local config = require("opencode.config")
local terminal = require("opencode.terminal")
local placeholders = require("opencode.placeholders")

--@param opts opencode.Config
function M.setup(opts)
  config.setup(opts)
end

function M.toggle(opts)
  return terminal.toggle(opts)
end

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
    vim.ui.input({ prompt = "Ask opencode: " }, function(input)
      if input then
        terminal.send(placeholders.replace_file(input), opts or {})
      end
    end)
  end
end

function M.send(text, opts)
  terminal.send(text, opts or {})
end

function M.command(command, opts)
  terminal.command(command, opts or {})
end

return M
