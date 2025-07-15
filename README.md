# opencode.nvim

Neovim plugin to conveniently interface with the [opencode](https://github.com/sst/opencode) AI assistant.

<p>
  <img width="500" alt="prompting" src="https://github.com/user-attachments/assets/ce1b97e4-225d-4813-b576-88858c5f554b" />
  <img width="500" alt="result" src="https://github.com/user-attachments/assets/7613551a-0b53-43c6-ad11-a49d9669b694" />
</p>


> [!WARNING]  
> This plugin is in initial development. Expect breaking changes and rough edges. 

## ✨ Features

- Toggle an `opencode` terminal window within Neovim
- Send prompts, commands, and selected text to the window
- Map re-usable and dynamic prompts
- Flexible prompt expansions - e.g. `@file` to reference the current file
- Auto-reload edited buffers
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
    -- Example prompts
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
    position = "right",
    -- See https://github.com/folke/snacks.nvim/blob/main/docs/win.md for more window options
  },
  expansions = {        -- Prompt placeholder expansions
    ["@file"] = function()
      return "@" .. vim.fn.expand("%:.")
    end,
  },
  -- See https://github.com/folke/snacks.nvim/blob/main/docs/terminal.md for more terminal options
}
```
