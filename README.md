# opencode.nvim

Neovim plugin to conveniently interact with [opencode](https://github.com/sst/opencode). Send prompts and code directly from your editor, with support for visual selections, placeholders, and automatic buffer reloading.

> [!WARNING]  
> This plugin is in initial development. Expect breaking changes and rough edges. 

## ✨ Features

- Toggle an `opencode` terminal window within Neovim
- Send prompts and commands to `opencode`
- Prompt placeholders - `@file` to reference the current file
- Visual mode support: send selected text
- Auto-reload buffers edited by `opencode`
- Configurable terminal behavior and window style

## 📦 Setup

[lazy.nvim](https://github.com/folke/lazy.nvim):

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
  cmd = "opencode",     -- Command to launch opencode
  win = {
    position = "right", -- Window position
  },
}
```

The config object extends [snacks.terminal](https://github.com/folke/snacks.nvim/blob/main/docs/terminal.md) options, including [snacks.win](https://github.com/folke/snacks.nvim/blob/main/docs/win.md) - use those to customize behavior and appearance.

## 📚 API

- `require("opencode").setup(opts)`: Set up the plugin.
- `require("opencode").toggle()`: Toggle the `opencode` terminal window.
- `require("opencode").ask()`: Prompt for input and send to `opencode`. Includes visual mode selection. Replaces `@file` with current file's path.
- `require("opencode").send("your text")`: Send arbitrary text to the `opencode` terminal.
- `require("opencode").command("/your_command")`: Send a command (e.g., `/new`) to `opencode`.
    * **WIP**
