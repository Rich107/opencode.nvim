local M = {}

-- Important to track the port, not just true/false,
-- because opencode may have restarted (usually on a new port) while the plugin is running
local sse_listening_port = nil

local function opencode_cmd()
  local port = require("opencode.config").options.port
  return "opencode" .. (port and (" --port " .. port) or "")
end

---@return number
local function opencode_port()
  return require("opencode.config").options.port or require("opencode.server").find_port()
end

---Set up the plugin with your configuration.
---You don't need to call this if you use the default configuration - it does nothing else.
---@param opts opencode.Config
function M.setup(opts)
  -- What if we just received the relevant opts in each function?
  -- But people have come to expect a `setup` function with global `opts`...
  require("opencode.config").setup(opts)
end

---Send a prompt to opencode after injecting contexts.
---
---As the entry point to prompting, this function also:
---1. Opens an embedded opencode terminal if `auto_fallback_to_embedded` is enabled and an opencode port is not found.
---2. Starts listening for SSEs from opencode to forward as `OpencodeEvent` autocmd.
---3. Sets up `auto_reload` if enabled.
---@param prompt string
function M.prompt(prompt)
  -- TODO: Maybe extract this whole thing (checking opts.port, synchronously finding, polling) to a local function?
  -- With a callback that just receives port. So we don't have to concern how to get it here.
  -- Then can reuse in `M.command` too.
  local ok, opencode_port_result = pcall(opencode_port)
  if not ok then
    if require("opencode.config").options.auto_fallback_to_embedded then
      local win, created = require("snacks.terminal").get(opencode_cmd(), require("opencode.config").options.terminal)
      if not win then
        vim.notify("Failed to auto-open fallback embedded opencode terminal", vim.log.levels.ERROR, {
          title = "opencode",
        })
      elseif created then
        require("opencode.server").poll_for_port(function()
          -- Try again.
          -- We simply re-enter the function to re-use its logic and error-handling.
          -- Not sure that's readable though?
          -- Won't infinitely loop because next time `created` will be false.
          M.prompt(prompt)
        end)
        return
      end
    end

    vim.notify(opencode_port_result, vim.log.levels.ERROR, { title = "opencode" })
    return
  end

  prompt = require("opencode.context").inject(prompt, require("opencode.config").options.contexts)

  -- WARNING: If user never prompts opencode via the plugin, we'll never receive SSEs or register auto_reload autocmds.
  -- Could register `/plugin` and even periodically check, but is it worth the complexity?
  if require("opencode.config").options.auto_reload then
    require("opencode.reload").setup()
  end
  if opencode_port_result ~= sse_listening_port then
    require("opencode.client").sse_listen(opencode_port_result, function(response)
      vim.api.nvim_exec_autocmds("User", {
        pattern = "OpencodeEvent",
        data = response,
      })
    end)
    sse_listening_port = opencode_port_result
  end

  local opencode_win = require("snacks.terminal").get(
    opencode_cmd(),
    vim.tbl_deep_extend("force", require("opencode.config").options.terminal, { create = false })
  )
  if opencode_win then
    -- Noting unlikely edge case where the found port may be an external instance,
    -- but a simultaneously-open embedded instance will still confusingly show.
    opencode_win:show()
  end

  require("opencode.client").tui_clear_prompt(opencode_port_result, function()
    require("opencode.client").tui_append_prompt(prompt, opencode_port_result, function()
      require("opencode.client").tui_submit_prompt(opencode_port_result, function()
        --
      end)
    end)
  end)
end

---Send a command to opencode.
---See https://opencode.ai/docs/keybinds/ for available commands.
---@param command string
function M.command(command)
  -- TODO: Should this also implement auto_fallback_to_embedded?
  -- TODO: Should `M.command` also register the SSE listener?
  -- And even `auto_reload`? Only `input_*` commands would edit files, and hopefully the user uses `M.prompt` for that...
  local ok, opencode_port_result = pcall(opencode_port)
  if not ok then
    vim.notify(opencode_port_result, vim.log.levels.ERROR, { title = "opencode" })
    return
  end

  require("opencode.client").tui_execute_command(command, opencode_port_result)
end

---Input a prompt to send to opencode.
---@param default? string Text to prefill the input with.
function M.ask(default)
  -- snacks.input supports completion and normal mode movement, unlike the standard vim.ui.input.
  require("snacks.input").input(
    vim.tbl_deep_extend("force", require("opencode.config").options.input, {
      default = default,
    }),
    function(value)
      if value and value ~= "" then
        M.prompt(value)
      end
    end
  )
end

---Select a prompt to send to opencode.
function M.select_prompt()
  -- vim.tbl_values does not include nils, allowing users to remove built-in prompts.
  ---@type opencode.Prompt[]
  local prompts = vim.tbl_values(require("opencode.config").options.prompts)

  vim.ui.select(
    prompts,
    {
      prompt = "Prompt opencode: ",
      ---@param item opencode.Prompt
      format_item = function(item)
        return item.description
      end,
    },
    ---@param choice opencode.Prompt
    function(choice)
      if choice then
        M.prompt(choice.prompt)
      end
    end
  )
end

---Toggle embedded opencode TUI.
function M.toggle()
  return require("snacks.terminal").toggle(opencode_cmd(), require("opencode.config").options.terminal)
end

return M
