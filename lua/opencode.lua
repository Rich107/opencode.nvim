local M = {}

local terminal = require("opencode.terminal")

--@param opts opencode.Config
function M.setup(opts)
  require("opencode.config").setup(opts)
end

function M.toggle(opts)
  return terminal.toggle(opts)
end

function M.ask(text, opts)
  local mode = vim.fn.mode()
  local selected_text = text or ""
  -- Visual mode handling
  if vim.tbl_contains({ "v", "V", "" }, mode) then
    local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = mode })
    selected_text = table.concat(lines, "\n")

    vim.ui.input({ prompt = "Add a prompt to your selection (empty to skip):" }, function(input)
      if input ~= nil then
        if input ~= "" then
          selected_text = selected_text .. "\n> " .. input
        end
        terminal.send(selected_text, opts or {}, true)
      end
    end)
  else
    -- Normal mode handling
    if selected_text == "" then
      vim.ui.input({ prompt = "Send to opencode: " }, function(input)
        if input then
          -- TODO: Replace `@file` with the actual file path if needed
          -- (or separate fn/option for that...?)
          terminal.send(input, opts or {})
        end
      end)
    else
      terminal.send(selected_text, opts or {})
    end
  end
end

function M.send(text, opts)
  terminal.send(text, opts or {}, false)
end

return M
