# dotfiles

Personal configuration managed with [stow](https://www.gnu.org/software/stow/).

## Structure

```
dotfiles/
├── bashrc/
│   └── .bashrc
├── ghostty/
│   └── .config/
│       └── ghostty/
│           ├── config.ghostty
│           └── themes/
│               └── tokyonight-night
├── nvim/
│   └── .config/
│       └── nvim/
│           ├── init.lua
│           └── lua/
│               ├── config/
│               │   ├── autocmds.lua
│               │   ├── keymaps.lua
│               │   └── options.lua
│               └── plugins/
│                   └── init.lua
├── starship/
│   └── .config/
│       └── starship.toml
```

## Neovim Plugins

| Plugin | Purpose |
|--------|---------|
| [tokyonight.nvim](https://github.com/folke/tokyonight.nvim) | Colorscheme (night, pure black bg) |
| [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim) | File explorer |
| [fzf-lua](https://github.com/ibhagwan/fzf-lua) | Fuzzy finder (fzf-powered) |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax highlighting & indent |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) + [mason.nvim](https://github.com/williamboman/mason.nvim) | LSP support |
| [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) | Autocompletion |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | Statusline |
| [nvim-autopairs](https://github.com/windwp/nvim-autopairs) | Auto bracket pairs |
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Git decorations |
| [which-key.nvim](https://github.com/folke/which-key.nvim) | Keybinding hints |
| [nvim-dap](https://github.com/mfussenegger/nvim-dap) + [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui) | Debugger (DAP) |
| [claudecode.nvim](https://github.com/coder/claudecode.nvim) | Claude Code integration |

## LSP / Treesitter

Mason auto-installs the following language servers:

- `lua_ls` — Lua
- `pyright` — Python
- `ts_ls` — TypeScript / JavaScript
- `rust_analyzer` — Rust
- `gopls` — Go

Treesitter parsers: `lua`, `python`, `typescript`, `javascript`, `rust`, `go`

## LSP / Debug servers

Mason auto-installs:

- `codelldb` — Rust debugger

## Neovim Keymaps

| Key | Action |
|-----|--------|
| `<leader>e` | Toggle file explorer |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Continue / start debugger |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>dO` | Step out |
| `<leader>dt` | Terminate debugger |
| `<leader>du` | Toggle DAP UI |
| `Ctrl+hjkl` | Navigate windows |
| `<leader>ac` | Toggle Claude terminal |
| `<leader>af` | Focus Claude |
| `<leader>as` | Send selection to Claude |
| `<leader>aa` | Accept Claude diff |
| `<leader>ad` | Deny Claude diff |
| `gd` | Go to definition |
| `gr` | Go to references |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `K` | Hover documentation |
| `Esc` (terminal mode) | Exit terminal mode |

## Neovim Features

- Format on save (via LSP)
- Highlight on yank
- Trim trailing whitespace on save
- Restore last cursor position on file open
- Auto resize splits on window resize
- Neo-tree opens automatically on startup
- Hidden files visible in file explorer

## Prerequisites

| Tool | Purpose | Install |
|------|---------|---------|
| [stow](https://www.gnu.org/software/stow/) | Symlink manager | `sudo dnf install stow` |
| [neovim](https://neovim.io/) >= 0.10 | Editor | `sudo dnf install neovim` |
| [ghostty](https://ghostty.org/) | Terminal emulator | [ghostty.org](https://ghostty.org/) |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder | `sudo dnf install fzf` |
| [bat](https://github.com/sharkdp/bat) | fzf file preview | `sudo dnf install bat` |
| [fd](https://github.com/sharkdp/fd) | fzf repo search (Alt+C) | `sudo dnf install fd-find` |
| [tree](http://mama.indstate.edu/users/ice/tree/) | fzf directory preview | `sudo dnf install tree` |
| [mise](https://mise.jdx.dev/) | Runtime version manager | [mise.jdx.dev](https://mise.jdx.dev/) |
| [starship](https://starship.rs/) | Shell prompt | `curl -sS https://starship.rs/install.sh \| sh` |
| [FiraCode Nerd Font](https://www.nerdfonts.com/) | Terminal font | [nerdfonts.com](https://www.nerdfonts.com/) |
| [Claude Code](https://claude.ai/code) | AI coding assistant CLI | `npm install -g @anthropic-ai/claude-code` |

## Installation

```bash
git clone https://github.com/<you>/dotfiles ~/dotfiles
cd ~/dotfiles
stow --target=$HOME bashrc
stow ghostty
stow nvim
stow starship
```
