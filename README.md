# opencode.nvim

Send editor-aware prompts to the powerful [opencode AI](https://github.com/sst/opencode) from Neovim.

https://github.com/user-attachments/assets/331271d7-e590-4e30-a161-5c643909a922

> [!NOTE]
> Uses opencode's currently undocumented, likely unstable [API](https://github.com/sst/opencode/blob/dev/packages/opencode/src/server/server.ts).
> 
> Latest tested opencode version: `v0.3.76`

## ✨ Features

- Toggle an embedded `opencode` terminal or automatically find any `opencode` process running in or under Neovim's CWD
- Send prompts to its active session
- Inject customizable editor context
- Auto-reload edited buffers

> Please use the opencode TUI to manage its active session until [the plugin can do so](https://github.com/sst/opencode/issues/1255).

## 📦 Setup

<details>
<summary>lazy.nvim</summary>

```lua
{
  'NickvanDyke/opencode.nvim',
  dependencies = { 'folke/snacks.nvim', },
  ---@type opencode.Config
  opts = {
    -- Set these according to https://models.dev/
    provider_id = ...,
    model_id = ...,
  },
  -- stylua: ignore
  keys = {
    { '<leader>ot', function() require('opencode').toggle() end, desc = 'Toggle embedded opencode', },
    { '<leader>oa', function() require('opencode').ask() end, desc = 'Ask opencode', mode = { 'n', 'v' }, },
    { '<leader>oA', function() require('opencode').ask('@file ') end, desc = 'Ask opencode about current file', mode = { 'n', 'v' }, },
    { '<leader>on', function() require('opencode').create_session() end, desc = 'New session', },
    { '<leader>oe', function() require('opencode').prompt('Explain @cursor and its context') end, desc = 'Explain code near cursor', },
    { '<leader>or', function() require('opencode').prompt('Review @file for correctness and readability') end, desc = 'Review file', },
    { '<leader>of', function() require('opencode').prompt('Fix these @diagnostics') end, desc = 'Fix errors', },
    { '<leader>oo', function() require('opencode').prompt('Optimize @selection for performance and readability') end, desc = 'Optimize selection', mode = 'v', },
    { '<leader>od', function() require('opencode').prompt('Add documentation comments for @selection') end, desc = 'Document selection', mode = 'v', },
    { '<leader>ot', function() require('opencode').prompt('Add tests for @selection') end, desc = 'Test selection', mode = 'v', },
  },
}
```
</details>

<details>
<summary>NixOS/nixvim</summary>

```nix
  programs.nixvim = {
    extraPlugins = [
      pkgs.vimPlugins.opencode-nvim
    ];
    keymaps = [
      { key = "<leader>oa"; action = "<cmd>lua require('opencode').ask()<CR>"; mode = ["n" "v"]; } 
      { key = "<leader>oA"; action = "<cmd>lua require('opencode').ask('@file ')<CR>"; mode = ["n" "v"]; }
      { key = "<leader>on"; action = "<cmd>lua require('opencode').create_session()<CR>"; }
      { key = "<leader>oe"; action = "<cmd>lua require('opencode').prompt('Explain @cursor and its context')<CR>"; }
      { key = "<leader>or"; action = "<cmd>lua require('opencode').prompt('Review @file for correctness and readability')<CR>"; }
      { key = "<leader>of"; action = "<cmd>lua require('opencode').prompt('Fix these @diagnostics')<CR>"; }
      { key = "<leader>oo"; action = "<cmd>lua require('opencode').prompt('Optimize @selection for performance and readability')<CR>"; mode = "v"; }
      { key = "<leader>od"; action = "<cmd>lua require('opencode').prompt('Add documentation comments for @selection')<CR>"; mode = "v"; }
      { key = "<leader>ot"; action = "<cmd>lua require('opencode').prompt('Add tests for @selection')<CR>"; mode = "v"; }
    ];
  };
```
</details>

> [!TIP]
> `opencode.nvim` offers a flexible API — customize keymaps to fit your workflow!

> [!IMPORTANT]
> If using the embedded terminal, set your [opencode theme](https://opencode.ai/docs/themes/) to `system` — see https://github.com/sst/opencode/issues/445.

## ⚙️ Configuration

Default settings:

```lua
---@type opencode.Config
{
  provider_id = "github-copilot",  -- Provider to use for opencode requests
  model_id = "gpt-4.1",            -- Model to use for opencode requests
  port = nil,                      -- The port opencode is running on — use `opencode --port <port>`. If `nil`, tries to find a running instance in or under Neovim's CWD.
  auto_reload = false,             -- Automatically reload buffers edited by opencode
  context = {                      -- Context to inject in prompts
    ["@file"] = require("opencode.context").file,
    ["@files"] = require("opencode.context").files,
    ["@cursor"] = require("opencode.context").cursor_position,
    ["@selection"] = require("opencode.context").visual_selection,
    ["@diagnostic"] = function()
      return require("opencode.context").diagnostics(true)
    end,
    ["@diagnostics"] = require("opencode.context").diagnostics,
    ["@quickfix"] = require("opencode.context").quickfix,
    ["@diff"] = require("opencode.context").git_diff,
  },
}
```

## 🕵️‍♂️ Context

When your prompt contains placeholders, the plugin will replace them with context before sending:

| Placeholder | Context |
| - | - |
| `@file` | Current file |
| `@files` | Open files |
| `@cursor` | Cursor position |
| `@selection` | Selected text |
| `@diagnostic` | Current line diagnostics |
| `@diagnostics` | Current buffer diagnostics |
| `@quickfix` | Quickfix list |
| `@diff` | Git diff |

> [!TIP] 
> Press `<Tab>` in the `ask` input to trigger placeholder completion.

Add custom contexts via `opts.context`. The below replaces `@grapple` with files tracked by [grapple.nvim](https://github.com/cbochs/grapple.nvim):

```lua
---@type opencode.Config
{
  context = {
    ---@return string|nil
    ['@grapple'] = function()
      local tags = require('grapple').tags()
      if not tags or #tags == 0 then
        return nil
      end

      local paths = {}
      for _, tag in ipairs(tags) do
        table.insert(paths, tag.path)
      end
      return table.concat(paths, ', ')
    end,
  }
}
```


## 🙏 Acknowledgments

- Inspired by (and partially based on) [nvim-aider](https://github.com/GeorgesAlkhouri/nvim-aider) and later [neopencode.nvim](https://github.com/loukotal/neopencode.nvim).
- This plugin uses opencode's familiar TUI for simplicity — see [sudo-tee/opencode.nvim](https://github.com/sudo-tee/opencode.nvim) for a Neovim frontend.
- [mcp-neovim-server](https://github.com/bigcodegen/mcp-neovim-server) may better suit you, but it lacks customization and tool calls are slow and unreliable.
