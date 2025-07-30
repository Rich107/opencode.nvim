# opencode.nvim

Send editor-aware prompts to the powerful [opencode AI](https://github.com/sst/opencode) from Neovim.

https://github.com/user-attachments/assets/331271d7-e590-4e30-a161-5c643909a922

> [!NOTE]
> Uses opencode's currently undocumented, likely unstable [API](https://github.com/sst/opencode/blob/dev/packages/opencode/src/server/server.ts).
> 
> Latest tested opencode version: `v0.3.76`

## ✨ Features

- Toggle an embedded `opencode` terminal or auto-find any `opencode` process running inside Neovim's CWD
- Send customizable prompts to its active session
- Inject customizable editor context
- Write prompts quickly with completion integration
- Auto-reload edited buffers

> Please use the opencode TUI to manage its active session until [the plugin can do so](https://github.com/sst/opencode/issues/1255).

## 📦 Setup

<details>
<summary><a href="https://github.com/folke/lazy.nvim">lazy.nvim</a></summary>

```lua
{
  'NickvanDyke/opencode.nvim',
  dependencies = {
    'folke/snacks.nvim',
    {
      -- Optional blink.cmp integration for context placeholders
      'saghen/blink.cmp',
      opts = {
        sources = {
          providers = {
            opencode = {
              module = 'opencode.cmp.blink',
            },
          },
          per_filetype = {
            opencode_ask = { 'opencode', 'buffer' },
          },
        },
      },
    },
  },
  ---@type opencode.Config
  opts = {
    -- Set these according to https://models.dev/
    provider_id = ...,
    model_id = ...,
  },
  -- stylua: ignore
  keys = {
    { '<leader>ot', function() require('opencode').toggle() end, desc = 'Toggle embedded opencode', },
    { '<leader>oa', function() require('opencode').ask() end, desc = 'Ask opencode', mode = 'n', },
    { '<leader>oa', function() require('opencode').ask('@selection: ') end, desc = 'Ask opencode about selection', mode = 'v', },
    { '<leader>op', function() require('opencode').select_prompt() end, desc = 'Select opencode prompt', mode = { 'n', 'v', }, },
    { '<leader>on', function() require('opencode').create_session() end, desc = 'New session', },
  },
}
```
</details>

<details>
<summary><a href="https://github.com/nix-community/nixvim">nixvim</a></summary>

```nix
programs.nixvim = {
  extraPlugins = [
    pkgs.vimPlugins.opencode-nvim
  ];
  keymaps = [
    { key = "<leader>ot"; action = "<cmd>lua require('opencode').toggle()<CR>"; } 
    { key = "<leader>oa"; action = "<cmd>lua require('opencode').ask()<CR>"; mode = "n"; } 
    { key = "<leader>oa"; action = "<cmd>lua require('opencode').ask('@selection: ')<CR>"; mode = "v"; } 
    { key = "<leader>on"; action = "<cmd>lua require('opencode').create_session()<CR>"; }
    { key = "<leader>oe"; action = "<cmd>lua require('opencode').select_prompt()<CR>"; mode = ["n", "v"]; }
  ];
};
```
</details>

> [!IMPORTANT]
> If using the embedded terminal, set your [opencode theme](https://opencode.ai/docs/themes/) to `system` — see https://github.com/sst/opencode/issues/445.

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
> If not using `blink.cmp`, press `<Tab>` to trigger built-in completion of placeholders.

## ⚙️ Configuration

See all the available options and their defaults [here](./lua/opencode/config.lua#L12).

> [!TIP]
> `opencode.nvim` offers a flexible API — customize prompts, contexts, and keymaps to fit your workflow!

### Prompts

Add custom selectable prompts to `opts.prompts`:

```lua
{
  prompts = {
    joke = {
      description = 'Tell me a cat joke',
      prompt = 'Tell me a joke about cats. Make it funny, but not too funny.',
      -- Map it to a key if you really like it!
      key = '<leader>oj',
    },
  },
}
```

Add keymaps to [built-in prompts](./lua/opencode/config.lua#L17):

```lua
{
  prompts = {
    explain = {
      key = '<leader>oe',
    },
  },
}
```

### Contexts

Add custom contexts to `opts.context`. The below replaces `@grapple` with files tracked by [grapple.nvim](https://github.com/cbochs/grapple.nvim):

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

## 👀 Events

| Event | Description |
| - | - |
| `OpencodePromptResponse` | `opencode` has responded to a prompt |

## 🙏 Acknowledgments

- Inspired by (and partially based on) [nvim-aider](https://github.com/GeorgesAlkhouri/nvim-aider) and later [neopencode.nvim](https://github.com/loukotal/neopencode.nvim).
- This plugin uses opencode's familiar TUI for simplicity — see [sudo-tee/opencode.nvim](https://github.com/sudo-tee/opencode.nvim) for a Neovim frontend.
- [mcp-neovim-server](https://github.com/bigcodegen/mcp-neovim-server) may better suit you, but it lacks customization and tool calls are slow and unreliable.
