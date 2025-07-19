# opencode.nvim

Bring the powerful [opencode](https://github.com/sst/opencode) AI to Neovim — editor-aware research, reviews, and refactors, all in one place.

https://github.com/user-attachments/assets/331271d7-e590-4e30-a161-5c643909a922

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
    ["@quickfix"] = require("opencode.context").quickfix,
    ["@diff"] = require("opencode.context").git_diff,
  },
  win = {
    position = "right",
    enter = false,      -- Do not enter the opencode window after opening it
    -- See https://github.com/folke/snacks.nvim/blob/main/docs/win.md for more window options
  },
  -- See https://github.com/folke/snacks.nvim/blob/main/docs/terminal.md for more terminal options
}
```

## 🕵️‍♂️ Context

When your prompt contains placeholders, the plugin will replace it with context before sending:

| Placeholder | Context |
| - | - |
| `@file` | Current file |
| `@files` | Open files |
| `@cursor` | Cursor position |
| `@selection` | Selected text |
| `@diagnostics` | Current buffer diagnostics |
| `@quickfix` | Quickfix list |
| `@diff` | Git diff |

You can add custom contexts via `opts.context`. This example replaces `@grapple` with files tracked by [grapple.nvim](https://github.com/cbochs/grapple.nvim):

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

## 💻 Events

You can prompt opencode on Neovim events. This example prompts opencode to fix diagnostics whenever they change in the current buffer:

```lua
vim.api.nvim_create_autocmd('DiagnosticChanged', {
  callback = function(args)
    local diagnostics = vim.diagnostic.get(args.buf)
    if #diagnostics > 0 then
      require('opencode').prompt('Fix these @diagnostics')
    end
  end,
})
```

It's kind of annoying and should at least debounce, but just to show what's possible.

## 🙏 Acknowledgments

- Inspired by (and partially based on) [nvim-aider](https://github.com/GeorgesAlkhouri/nvim-aider).
- This plugin uses opencode's familiar interface to reduce cognitive load. See [sudo-tee/opencode.nvim](https://github.com/sudo-tee/opencode.nvim) for a Neovim frontend.
- [mcp-neovim-server](https://github.com/bigcodegen/mcp-neovim-server) may better suit your workflow, although it lacks custom contexts and tool calls are slow and unreliable.
