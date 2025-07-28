local M = {}

local config = require("opencode.config")
local context = require("opencode.context")
local client = require("opencode.client")
local server = require("opencode.server")

---@param opts opencode.Config
function M.setup(opts)
  config.setup(opts)
end

---Send a prompt to opencode.
---Injects context before sending.
---Sends to the most recently used session, or creates a new one if none exist.
---@param prompt string Prompt to send to opencode.
---@param opts? opencode.Config Optional config to merge for this call only.
function M.prompt(prompt, opts)
  opts = vim.tbl_deep_extend("force", {}, config.options, opts or {})
  prompt = context.inject(prompt, opts)
  local server_port = opts.port or server.find_port()
  if not server_port then
    return
  end

  client.get_sessions(server_port, function(sessions)
    if #sessions == 0 then
      vim.notify("No opencode sessions found — creating...", vim.log.levels.INFO)
      M.create_session(opts, function(new_session)
        client.send(prompt, new_session.id, server_port, opts)
      end)
    else
      -- TODO: I don't see a way to get the currently active session in the TUI.
      -- Kinda awkward because when the TUI currently has no open session,
      -- we can create one, but we can't then open it in the TUI.
      -- Also awkward because user might change sessions in TUI, but they need
      -- to then send a message there for it to be the active session here.
      -- Waiting/hoping for https://github.com/sst/opencode/issues/1255.

      -- Find the most recently interacted session.
      local most_recent_session_id = sessions[1].id
      local max_updated = sessions[1].time.updated
      for _, session in ipairs(sessions) do
        if session.time.updated > max_updated then
          max_updated = session.time.updated
          most_recent_session_id = session.id
        end
      end

      client.send(prompt, most_recent_session_id, server_port, opts)
    end
  end)
end

---Create a new opencode session.
---For now, the plugin can't select it in the TUI — please use the TUI `/sessions` command.
---@param opts? opencode.Config Optional config to merge for this call only.
---@param callback? fun(new_session: table)
function M.create_session(opts, callback)
  opts = vim.tbl_deep_extend("force", {}, config.options, opts or {})
  local server_port = opts.port or server.find_port()
  if not server_port then
    return
  end

  client.create_session(server_port, function(new_session)
    if not new_session or not new_session.id then
      vim.notify("Failed to create a new opencode session", vim.log.levels.ERROR)
    else
      vim.notify("Created new opencode session — select via TUI /sessions", vim.log.levels.INFO)
      if callback then
        callback(new_session)
      end
    end
  end)
end

---Input a prompt to send to opencode.
---@param default? string Text to prefill the input with.
function M.ask(default)
  -- While I'd like to use the standard vim.ui.input, it doesn't support custom completion.
  -- TODO: Should expose snacks.input opts in config
  require("snacks.input").input({
    prompt = "Ask opencode",
    default = default,
    icon = "󱚣",
    completion = "customlist,v:lua.require'opencode.cmp'",
  }, function(value)
    if value and value ~= "" then
      M.prompt(value)
    end
  end)
end

---Toggle embedded opencode TUI.
function M.toggle()
  -- TODO: Should expose snacks.terminal opts in config
  require("snacks.terminal").toggle("opencode", { win = { position = "right" } })
end

return M
