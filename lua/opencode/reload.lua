local M = {}

function M.setup()
  if not vim.o.autoread then
    -- TODO: Is this really necessary? I presume it's so checktime works.
    -- But is there another way to reload the buffer's file without autoread?
    -- Then we can enable auto_reload by default.
    vim.notify("Please enable autoread to use opencode.nvim auto_reload", vim.log.levels.WARN, { title = "opencode" })
    return
  end

  -- Autocommand group to avoid stacking duplicates on reload
  local group = vim.api.nvim_create_augroup("OpencodeAutoReload", { clear = true })

  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "OpencodeEvent",
    callback = function(args)
      if args.data.type == "file.edited" then
        -- TODO: I presume the event has the edited file's path - can we reload that specific buffer?
        -- Then may not need the more general autocommands below.
        vim.cmd("checktime")
      end
    end,
    desc = "Reload buffer when opencode edits a file",
  })

  vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI", "TermClose" }, {
    group = group,
    pattern = "*",
    callback = function()
      vim.cmd("checktime")
    end,
    desc = "Reload buffer if the underlying file was changed by opencode or anything else",
  })
end

return M
