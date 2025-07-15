# opencode.nvim

Neovim plugin to conveniently interface with the [opencode](https://github.com/sst/opencode) AI assistant.

<img alt="opencode.nvim in action" src="https://github.com/user-attachments/assets/aa0dcddb-aa85-433f-9e49-7721b5a74948" />

> [!WARNING]  
> This plugin is in initial development. Expect breaking changes and rough edges. 

## ✨ Features

- Toggle an `opencode` terminal window within Neovim
- Send prompts, commands and selected text to the window
- Map re-usable and dynamic prompts
- Flexible prompt placeholders - e.g. `@file` to reference the current file
- Auto-reload buffers edited by `opencode`
- Configurable terminal behavior and window style

## 📦 Setup

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'NickvanDyke/opencode.nvim',
  dependencies = {
    'folke/snacks.nvim',
  },
  ---@type opencode.Config
  opts = {
    -- Configuration, if any
  },
  keys = {
    -- Example keymaps
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
    -- Example commands
    {
      '<leader>on',
      function()
        require('opencode').command('/new')
      end,
      desc = 'New opencode session',
    },
    -- Example re-usable prompts
    {
      '<leader>oe',
      function()
        require('opencode').send('Explain this code')
      end,
      desc = 'Explain selected code',
      mode = 'v'
    },
    {
      '<leader>oc',
      function()
        require('opencode').send('Critique @file for correctness and readability')
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
  auto_reload = false,  -- Automatically reload buffers changed by opencode
  auto_focus = true,    -- Focus the terminal after sending text
  command = "opencode", -- Command to launch opencode
  win = {
    position = "right", -- Window position
  },
  expansions = {
    ["@file"] = function()
      return "@" .. vim.fn.expand("%:.")
    end,
  },
}
```

The config object extends [snacks.terminal](https://github.com/folke/snacks.nvim/blob/main/docs/terminal.md) options, including [snacks.win](https://github.com/folke/snacks.nvim/blob/main/docs/win.md) - use those to customize behavior and appearance.
