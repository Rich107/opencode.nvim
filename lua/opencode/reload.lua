local M = {}

function M.setup()
  if not vim.o.autoread then
    -- Unfortunately autoread is kinda necessary, for :checktime.
    -- Alternatively we could :edit! but that would lose any unsaved changes.
    vim.notify("Please enable autoread to use opencode.nvim auto_reload", vim.log.levels.WARN, { title = "opencode" })
    return
  end

  vim.api.nvim_create_autocmd("User", {
    -- Group to avoid stacking duplicates on reload
    group = vim.api.nvim_create_augroup("OpencodeAutoReload", { clear = true }),
    pattern = "OpencodeEvent",
    callback = function(args)
      if args.data.type == "file.edited" then
        -- :checktime checks all buffers - no need to check event's file
        vim.cmd("checktime")
      end
    end,
    desc = "Reload buffers when opencode edits a file",
  })
end

return M
