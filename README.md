# opencode.nvim

This plugin provides a simple, convenient bridge between Neovim and the [opencode](https://github.com/sst/opencode) AI assistant.

<table>
  <tr>
    <td>
      <img alt="prompting" src="https://github.com/user-attachments/assets/ce1b97e4-225d-4813-b576-88858c5f554b" />
    </td>
    <td>
      ➡️
    </td>
    <td>
      <img alt="result" src="https://github.com/user-attachments/assets/7613551a-0b53-43c6-ad11-a49d9669b694" />
    </td>
  </tr>
</table>

> [!WARNING]  
> This plugin is in initial development. Expect breaking changes and rough edges. 

## ✨ Features

- Toggle an `opencode` terminal window within Neovim
- Send prompts and commands to the window
- Automatically include editor context
- Auto-reload edited buffers
- Configurable terminal behavior and window style

## 🕵️‍♂️ Context

The following editor context is automatically captured and included in each prompt for your convenience.

- Current file
- Cursor position
- Visual mode selection

You can disable these and/or add your own contexts via the `context` option.

## 📦 Setup

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
    -- Default configuration — only include any that you wish to change
    auto_reload = false,  -- Automatically reload buffers changed by opencode
    auto_focus = true,    -- Focus the opencode window after sending text
    command = "opencode", -- Command to launch opencode
    context = {           -- Context added to every prompt
      file = require('opencode.context').file,
      cursor = require("opencode.context").cursor_position,
      selection = require("opencode.context").visual_selection,
    },
    win = {
      position = "right",
      -- See https://github.com/folke/snacks.nvim/blob/main/docs/win.md for more window options
    },
    -- See https://github.com/folke/snacks.nvim/blob/main/docs/terminal.md for more terminal options
  },
  -- stylua: ignore
  keys = {
    -- Example keymaps
    { '<leader>ot', function() require('opencode').toggle() end, desc = 'Toggle opencode', },
    { '<leader>oa', function() require('opencode').ask() end, desc = 'Ask opencode', mode = { 'n', 'v' }, },
    -- Example commands
    { '<leader>on', function() require('opencode').command('/new') end, desc = 'New opencode session', },
    -- Example prompts
    { '<leader>oe', function() require('opencode').send('Explain this code') end, desc = 'Explain selected code', mode = 'v', },
    { '<leader>oc', function() require('opencode').send('Critique this file for correctness and readability') end, desc = 'Critique current file', },
  },
}
```

## 🙏 Acknowledgments

- Inspired by (and partially based on) [nvim-aider](https://github.com/GeorgesAlkhouri/nvim-aider)
- This plugin uses opencode's familiar interface to minimize cognitive load across tools. For advanced features and a native Neovim UI, see [sudo-tee/opencode.nvim](https://github.com/sudo-tee/opencode.nvim).
