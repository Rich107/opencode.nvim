local M = {}

---Highlights context placeholders in the input string.
---See `:help input()-highlight`.
---@param input string
---@return table[]
local function highlight(input)
  local placeholders = vim.tbl_keys(require("opencode.config").options.contexts)
  local hls = {}

  for _, placeholder in ipairs(placeholders) do
    local init = 1
    while true do
      local start_pos, end_pos = input:find(placeholder, init, true)
      if not start_pos then
        break
      end
      table.insert(hls, {
        start_pos - 1,
        end_pos,
        -- I don't expect users to care to customize this, so keep it simple with a sensible built-in highlight
        "@lsp.type.enum",
      })
      init = end_pos + 1
    end
  end

  -- Must occur in-order or neovim will error
  table.sort(hls, function(a, b)
    return a[1] < b[1] or (a[1] == b[1] and a[2] < b[2])
  end)

  return hls
end

---@param default? string
---@param on_confirm fun(value: string|nil)
function M.input(default, on_confirm)
  -- Recommended configuration uses snacks.input (for completions and normal-mode movement),
  -- so we pass options for it too, not just for vim.ui.input.
  vim.ui.input(
    vim.tbl_deep_extend("force", require("opencode.config").options.input, {
      default = default,
      highlight = highlight,
      win = {
        -- Do some setup. Not in default config object for brevity, and I don't expect users to modify this.
        on_buf = function(win)
          -- Wait as long as possible to check for blink.cmp loaded - many users lazy-load on `InsertEnter`.
          -- And OptionSet :runtimepath didn't seem to fire for lazy.nvim.
          vim.api.nvim_create_autocmd("InsertEnter", {
            once = true,
            buffer = win.buf,
            callback = function()
              if package.loaded["blink.cmp"] then
                require("opencode.cmp.blink").setup(require("opencode.config").options.auto_register_cmp_sources)
              end
            end,
          })

          -- snacks.input doesn't seem to actually call `opts.highlight`... so highlight its buffer ourselves
          vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "BufWinEnter" }, {
            group = vim.api.nvim_create_augroup("OpencodeAskHighlight", { clear = true }),
            buffer = win.buf,
            callback = function(args)
              local input = vim.api.nvim_buf_get_lines(args.buf, 0, 1, false)[1] or ""
              local hls = highlight(input)

              local ns_id = vim.api.nvim_create_namespace("opencode_placeholders")
              vim.api.nvim_buf_clear_namespace(args.buf, ns_id, 0, -1)

              for _, hl in ipairs(hls) do
                vim.api.nvim_buf_set_extmark(args.buf, ns_id, 0, hl[1], {
                  end_col = hl[2],
                  hl_group = hl[3],
                })
              end
            end,
          })
        end,
      },
    }),
    on_confirm
  )
end

return M
