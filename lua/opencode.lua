local M = {}

local terminal = require("opencode.terminal")
local utils = require("opencode.utils")

--@param opts opencode.Config
function M.setup(opts)
  require("opencode.config").setup(opts)
end

function M.toggle(opts)
  return terminal.toggle(opts)
end

function M.ask(text, opts)
  if text ~= nil then
    terminal.send(text, opts or {}, true)
  end

  local mode = vim.fn.mode()

  -- Visual mode handling
  if vim.tbl_contains({ "v", "V", "" }, mode) then
    local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = mode })
    local selected_text = table.concat(lines, "\n")

    vim.ui.input({ prompt = "Add a prompt to your selection (empty to skip):" }, function(input)
      if input ~= nil then
        if input ~= "" then
          selected_text = selected_text .. "\n\n" .. utils.replace_file(input)
        end
        terminal.send(selected_text, opts or {}, true)
      end
    end)
  else
    -- Normal mode handling
    vim.ui.input({ prompt = "Ask opencode: " }, function(input)
      if input then
        terminal.send(utils.replace_file(input), opts or {})
      end
    end)
  end
end

function M.send(text, opts)
  terminal.send(text, opts or {}, false)
end

return M
