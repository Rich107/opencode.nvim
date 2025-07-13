local M = {}

local config = require("opencode.config")
local terminal = require("opencode.terminal")

--@param opts opencode.Config
function M.setup(opts)
  config.setup(opts)
end

function M.toggle(opts)
  return terminal.toggle(opts)
end

function M.ask(opts)
  local mode = vim.fn.mode()

  local function replace_file_placeholder(input)
    -- Replace @file with the current file path
    if input:find("@file") then
      local relative_path = vim.fn.expand("%:.")
      if relative_path == "" then
        vim.notify("No file is currently open.", vim.log.levels.WARN)
        return input
      end
      return input:gsub("@file", "@" .. relative_path)
    end
    return input
  end

  -- Visual mode handling
  if vim.tbl_contains({ "v", "V", "" }, mode) then
    local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = mode })
    local selected_text = table.concat(lines, "\n")

    vim.ui.input({ prompt = "Add a prompt to your selection (empty to skip):" }, function(input)
      if input ~= nil then
        if input ~= "" then
          selected_text = selected_text .. "\n\n" .. replace_file_placeholder(input)
        end
        terminal.send(selected_text, opts or {}, true)
      end
    end)
  else
    -- Normal mode handling
    vim.ui.input({ prompt = "Ask opencode: " }, function(input)
      if input then
        terminal.send(replace_file_placeholder(input), opts or {})
      end
    end)
  end
end

function M.send(text, opts)
  terminal.send(text, opts or {})
end

-- TODO: How to press "enter" after?
-- I don't understand why it works fine with `ask`
function M.command(command, opts)
  terminal.command(command, opts or {})
end

return M
