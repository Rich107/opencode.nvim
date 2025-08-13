local M = {}

---@param default? string
---@param callback fun(value: string)
function M.show(default, callback)
  -- snacks.input supports completion and normal mode movement, unlike the standard vim.ui.input.
  require("snacks.input").input(
    vim.tbl_deep_extend("force", require("opencode.config").options.input, {
      default = default,
    }),
    function(value)
      if value and value ~= "" then
        callback(value)
      end
    end
  )
end

return M
