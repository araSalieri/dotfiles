# dotfiles

Personal Neovim configuration managed with [stow](https://www.gnu.org/software/stow/).

## Structure

```
dotfiles/
└── nvim/
    └── .config/
        └── nvim/
            ├── init.lua
            └── lua/
                ├── config/
                │   ├── autocmds.lua
                │   ├── keymaps.lua
                │   └── options.lua
                └── plugins/
                    └── init.lua
```

## Plugins

| Plugin | Purpose |
|--------|---------|
| [tokyonight.nvim](https://github.com/folke/tokyonight.nvim) | Colorscheme (night, pure black bg) |
| [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim) | File explorer |
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Fuzzy finder |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax highlighting & indent |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) + [mason.nvim](https://github.com/williamboman/mason.nvim) | LSP support |
| [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) | Autocompletion |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | Statusline |
| [nvim-autopairs](https://github.com/windwp/nvim-autopairs) | Auto bracket pairs |
| [Comment.nvim](https://github.com/numToStr/Comment.nvim) | Easy commenting |
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Git decorations |
| [which-key.nvim](https://github.com/folke/which-key.nvim) | Keybinding hints |

## LSP / Treesitter

Mason auto-installs the following language servers:

- `lua_ls` — Lua
- `pyright` — Python
- `ts_ls` — TypeScript / JavaScript
- `rust_analyzer` — Rust
- `gopls` — Go

Treesitter parsers: `lua`, `python`, `typescript`, `javascript`, `rust`, `go`

## Features

- Format on save (via LSP)
- Highlight on yank
- Trim trailing whitespace on save
- Restore last cursor position on file open
- Auto resize splits on window resize

## Installation

```bash
git clone https://github.com/<you>/dotfiles ~/.dotfiles
cd ~/.dotfiles
stow nvim
```
