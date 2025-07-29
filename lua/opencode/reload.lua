local M = {}

function M.setup()
  if not vim.o.autoread then
    vim.notify("Please enable autoread to use opencode.nvim auto_reload", vim.log.levels.WARN)
    return
  end

  -- Autocommand group to avoid stacking duplicates on reload
  local group = vim.api.nvim_create_augroup("OpencodeAutoReload", { clear = true })

  -- Trigger :checktime on the events that matter
  vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI", "TermClose" }, {
    group = group,
    pattern = "*",
    callback = function()
      vim.cmd("checktime")
    end,
    desc = "Reload buffer if the underlying file was changed by opencode or anything else",
  })

  vim.api.nvim_create_autocmd({ "User" }, {
    group = group,
    pattern = "OpencodePromptPost",
    callback = function()
      vim.cmd("checktime")
    end,
    desc = "Reload buffer if the underlying file was changed by opencode or anything else",
  })
end

return M
