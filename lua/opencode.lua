local M = {}

local config = require("opencode.config")
local context = require("opencode.context")
local client = require("opencode.client")
local server = require("opencode.server")

-- Important to track the port, not just true/false,
-- because opencode may have restarted (usually on a new port) while the plugin is running
local sse_listening_port = nil

---@param opts opencode.Config
function M.setup(opts)
  config.setup(opts)

  for _, prompt in pairs(config.options.prompts) do
    if prompt.key then
      vim.keymap.set({ "n", "v" }, prompt.key, function()
        M.prompt(prompt.prompt)
      end, { desc = prompt.description })
    end
  end
end

---Send a prompt to opencode.
---Injects context before sending.
---@param prompt string
function M.prompt(prompt)
  local server_port = config.options.port or server.find_port()
  if not server_port then
    return
  end

  prompt = context.inject(prompt, config.options.context)

  if server_port ~= sse_listening_port then
    -- WARNING: If user never prompts opencode via the plugin, we'll never receive SSEs.
    -- Could register in `setup` and even periodically check, but is it worth the complexity?
    client.sse_listen(server_port, function(response)
      vim.api.nvim_exec_autocmds("User", {
        pattern = "OpencodeEvent",
        data = response,
      })
    end)
    sse_listening_port = server_port
  end

  client.tui_clear_prompt(server_port, function()
    client.tui_append_prompt(prompt, server_port, function()
      client.tui_submit_prompt(server_port, function()
        -- ...
      end)
    end)
  end)
end

---Send a command to opencode.
---See https://opencode.ai/docs/keybinds/ for available commands.
---@param command string
function M.command(command)
  local server_port = config.options.port or server.find_port()
  if not server_port then
    return
  end

  client.tui_execute_command(command, server_port)
end

---Input a prompt to send to opencode.
---@param default? string Text to prefill the input with.
function M.ask(default)
  -- snacks.input supports completion and normal mode movement, unlike the standard vim.ui.input.
  require("snacks.input").input(
    vim.tbl_deep_extend("force", config.options.input, {
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
  local prompts = vim.tbl_values(config.options.prompts)

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
  local port = config.options.port
  require("snacks.terminal").toggle("opencode" .. (port and (" --port " .. port) or ""), config.options.terminal)
end

return M
