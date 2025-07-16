# opencode.nvim

`opencode.nvim` provides a simple, customizable bridge between Neovim and the powerful [opencode](https://github.com/sst/opencode) AI assistant. Enrich AI-powered research, reviews, refactors, and documentation with editor context — using familiar tools, right inside Neovim.

<img alt="prompting" src="https://github.com/user-attachments/assets/694e3ec6-6237-49ab-a600-c22ee2664ab7" />
<img alt="result" src="https://github.com/user-attachments/assets/c760b1ce-e36a-48d8-95d9-2417e157eef9" />

## ✨ Features

- Toggle an `opencode` terminal window within Neovim
- Send prompts and commands
- Insert editor context
- Auto-reload edited buffers

## 📦 Installation

> [!IMPORTANT]
> Set your [opencode theme](https://opencode.ai/docs/themes/) to `system` — other themes currently have [visual bugs in embedded terminals](https://github.com/sst/opencode/issues/445).

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'NickvanDyke/opencode.nvim',
  dependencies = {
    'folke/snacks.nvim',
  },
  ---@type opencode.Config
  opts = {
    -- Your configuration, if any
  },
  -- stylua: ignore
  keys = {
    -- opencode.nvim exposes a general, flexible API — customize it to your workflow!
    -- But here are some examples to get you started :)
    { '<leader>ot', function() require('opencode').toggle() end, desc = 'Toggle opencode', },
    { '<leader>oa', function() require('opencode').ask() end, desc = 'Ask opencode', mode = { 'n', 'v' }, },
    { '<leader>oA', function() require('opencode').ask('@file ') end, desc = 'Ask opencode about current file', mode = { 'n', 'v' }, },
    { '<leader>on', function() require('opencode').command('/new') end, desc = 'New session', },
    { '<leader>oe', function() require('opencode').prompt('Explain @cursor and its context') end, desc = 'Explain code near cursor' },
    { '<leader>or', function() require('opencode').prompt('Review @file for correctness and readability') end, desc = 'Review file', },
    { '<leader>of', function() require('opencode').prompt('Fix these @diagnostics') end, desc = 'Fix errors', },
    { '<leader>oo', function() require('opencode').prompt('Optimize @selection for performance and readability') end, desc = 'Optimize selection', mode = 'v', },
    { '<leader>od', function() require('opencode').prompt('Add documentation comments for @selection') end, desc = 'Document selection', mode = 'v', },
    { '<leader>ot', function() require('opencode').prompt('Add tests for @selection') end, desc = 'Test selection', mode = 'v', },
  },
}
```

## ⚙️ Configuration

Default settings:

```lua
---@type opencode.Config
{
  auto_reload = false,  -- Automatically reload buffers edited by opencode
  auto_focus = false,   -- Focus the opencode window after prompting 
  command = "opencode", -- Command to launch opencode
  context = {           -- Context to inject in prompts
    ["@file"] = require("opencode.context").file,
    ["@files"] = require("opencode.context").files,
    ["@cursor"] = require("opencode.context").cursor_position,
    ["@selection"] = require("opencode.context").visual_selection,
    ["@diagnostics"] = require("opencode.context").diagnostics,
  },
  win = {
    position = "right",
    -- See https://github.com/folke/snacks.nvim/blob/main/docs/win.md for more window options
  },
  -- See https://github.com/folke/snacks.nvim/blob/main/docs/terminal.md for more terminal options
}
```

## 🕵️‍♂️ Context

When your prompt contains certain placeholder phrases, the plugin will replace it with appropriate context before sending:

| Placeholder | Context |
| - | - |
| `@file` | Current file |
| `@files` | Open files |
| `@cursor` | Cursor position |
| `@selection` | Selected text |
| `@diagnostics` | Current buffer diagnostics |

You can add custom contexts via `opts.context`. This example inserts all files tracked by [grapple.nvim](https://github.com/cbochs/grapple.nvim) when the prompt contains `@grapple`:

```lua
---@type opencode.Config
{
  context = {
    ---@return string|nil
    ['@grapple'] = function()
      local paths = {}
      for _, tag in ipairs(require('grapple').tags() or {}) do
        table.insert(paths, tag.path)
      end
      return table.concat(paths, ', ')
    end,
  }
}
```

## 🙏 Acknowledgments

- Inspired by (and partially based on) [nvim-aider](https://github.com/GeorgesAlkhouri/nvim-aider).
- This plugin uses opencode's familiar interface to minimize cognitive load across tools. For advanced Neovim integration, see [sudo-tee/opencode.nvim](https://github.com/sudo-tee/opencode.nvim).
- [mcp-neovim-server](https://github.com/bigcodegen/mcp-neovim-server) may better suit your workflow, but tool calls are slow and context customization is limited.
