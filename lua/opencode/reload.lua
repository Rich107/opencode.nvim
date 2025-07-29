local M = {}

function M.setup()
  if not vim.o.autoread then
    vim.notify("Please enable autoread to use opencode.nvim auto_reload", vim.log.levels.WARN)
    return
  end

  -- Autocommand group to avoid stacking duplicates on reload
  local group = vim.api.nvim_create_augroup("OpencodeAutoReload", { clear = true })

  -- Trigger :checktime on the events that matter
  -- TODO: Possible to trigger immediately, i.e. without user interactions?
  -- Seems like `curl.on_exit` doesn't fire until opencode has completely finished responding,
  -- so we could fire an autocmd event there and listen for it here.
  -- May not cover gradually edited files in the middle of a long response though.
  vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI", "TermClose" }, {
    group = group,
    pattern = "*",
    callback = function()
      -- Don’t interfere while editing a command line or in terminal‑insert mode
      if vim.fn.mode():match("[ciR!t]") == nil and vim.fn.getcmdwintype() == "" then
        vim.cmd("checktime")
      end
    end,
    desc = "Reload buffer if the underlying file was changed by opencode or anything else",
  })
end

return M
