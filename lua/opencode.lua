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
          selected_text = selected_text .. "\n\n" .. input
        end
        terminal.send(selected_text, opts or {}, true)
      end
    end)
  else
    -- Normal mode handling
    if selected_text == "" then
      vim.ui.input({ prompt = "Ask opencode: " }, function(input)
        if input then
          if input:match("@file") then
            -- If the input contains '@file', replace it with the current file path
            -- TODO: Handle when nvim and opencode have different working directories?
            local relative_path = vim.fn.expand("%:.")
            if relative_path == "" then
              vim.notify("No file is currently open.", vim.log.levels.WARN)
              return
            end

            -- Prefix with '@' per opencode syntax
            local prefixed_relative_path = "@" .. relative_path

            input = input:gsub("@file", prefixed_relative_path)
          end

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
