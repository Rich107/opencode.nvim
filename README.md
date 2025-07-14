# opencode.nvim

Neovim plugin to conveniently interface with [opencode](https://github.com/sst/opencode).

> [!WARNING]  
> This plugin is in initial development. Expect breaking changes and rough edges. 

## ✨ Features

- Toggle an `opencode` terminal window within Neovim
- Send prompts to the window
- Map re-usable prompts
- Send selected visual mode text
- Prompt placeholders - `@file` to reference the current file
- Auto-reload buffers edited by `opencode`
- Configurable terminal behavior and window style

## 📦 Setup

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "NickvanDyke/opencode.nvim",
  dependencies = {
    'folke/snacks.nvim',
  },
  opts = {
    -- Configuration, if any
  },
  -- Example keymaps
  keys = {
    {
      '<leader>ot',
      function()
        require('opencode').toggle()
      end,
      desc = 'Toggle opencode',
    },
    {
      '<leader>oa',
      function()
        require('opencode').ask()
      end,
      desc = 'Ask opencode',
      mode = { 'n', 'v' },
    },
    -- Example re-usable prompts
    {
      '<leader>oe',
      function()
        require('opencode').ask('Explain this code')
      end,
      desc = 'Explain selected code',
      mode = 'v'
    },
    {
      '<leader>oc',
      function()
        require('opencode').ask('Critique @file for correctness and readability')
      end,
      desc = 'Critique current file',
    },
  },
}
```

> [!IMPORTANT]
> Set your [opencode theme](https://opencode.ai/docs/themes/) to `system` - other themes currently have [visual bugs in embedded terminals](https://github.com/sst/opencode/issues/445).

## ⚙️ Configuration

Default options:

```lua
{
  auto_reload = true,   -- Automatically reload buffers changed by opencode
  auto_focus = true,    -- Focus the terminal after sending text
  command = "opencode", -- Command to launch opencode
  win = {
    position = "right", -- Window position
  },
}
```

The config object extends [snacks.terminal](https://github.com/folke/snacks.nvim/blob/main/docs/terminal.md) options, including [snacks.win](https://github.com/folke/snacks.nvim/blob/main/docs/win.md) - use those to customize behavior and appearance.
