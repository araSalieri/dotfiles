# dotfiles

Personal configuration managed with [stow](https://www.gnu.org/software/stow/).

## Structure

```
dotfiles/
├── KEYMAPS.md                # Neovim keymap reference
├── fish/
│   └── .config/
│       └── fish/
│           └── config.fish
├── foot/
│   └── .config/
│       └── foot/
│           └── foot.ini
├── hypr/
│   └── .config/
│       └── hypr/
│           ├── hyprland.lua      # Hyprland entry point
│           ├── user-config.lua   # User settings & variables
│           ├── user-keybinds.lua # User keybinds
│           └── user-rule.lua     # Window rules
├── lazygit/
│   └── .config/
│       └── lazygit/
│           └── config.yml
├── nvim/
│   └── .config/
│       └── nvim/
│           ├── init.lua
│           └── lua/
│               ├── config/
│               │   ├── autocmds.lua
│               │   ├── keymaps.lua
│               │   ├── options.lua
│               │   └── pi-queue.lua   # queues file refs for omp
│               └── plugins/       # one file per concern, lazy.nvim auto-imports the dir
│                   ├── colorscheme.lua
│                   ├── completion.lua
│                   ├── dap.lua
│                   ├── editor.lua
│                   ├── formatting.lua
│                   ├── fzf.lua
│                   ├── lsp.lua
│                   ├── lualine.lua
│                   ├── markdown.lua
│                   ├── neo-tree.lua
│                   ├── neotest.lua
│                   ├── pi-ide.lua
│                   ├── snacks.lua
│                   └── treesitter.lua
├── omp/
│   └── .omp/
│       └── agent/
│           ├── AGENTS.md
│           ├── config.yml
│           └── extensions/
│               └── omp-ide/       # nvim bridge extension
├── noctalia/
│   └── .config/
│       └── config.toml         # Noctalia shell config (bar, launcher, screenshots via satty)
└── tmux/
    └── .tmux.conf
```

## Prerequisites

| Tool | Purpose | Install |
|------|---------|---------|
| [fish](https://fishshell.com/) | Shell | `sudo pacman -S fish` |
| [stow](https://www.gnu.org/software/stow/) | Symlink manager | `sudo pacman -S stow` |
| [neovim](https://neovim.io/) >= 0.10 | Editor | `sudo pacman -S neovim` |
| [foot](https://codeberg.org/dnkl/foot) | Terminal launched by nvim `<leader>tt` / `<leader>co` | `sudo pacman -S foot` |
| [tmux](https://github.com/tmux/tmux) | Terminal multiplexer | `sudo pacman -S tmux` |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder | `sudo pacman -S fzf` |
| [tree](http://mama.indstate.edu/users/ice/tree/) | fzf directory preview | `sudo pacman -S tree` |
| [direnv](https://direnv.net/) | Per-directory env | `sudo pacman -S direnv` |
| [starship](https://starship.rs/) | Shell prompt | `sudo pacman -S starship` |
| [mise](https://mise.jdx.dev/) | Runtime version manager | `sudo pacman -S mise` |
| [JetBrainsMono Nerd Font](https://www.nerdfonts.com/) | Terminal font | `sudo pacman -S ttf-jetbrains-mono-nerd` |
| [lazygit](https://github.com/jesseduffield/lazygit) | Git TUI | `sudo pacman -S lazygit` |
| [paru](https://github.com/Morganamilo/paru) | AUR helper | `sudo pacman -S --needed base-devel && git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si` |
| [tree-sitter](https://github.com/tree-sitter/tree-sitter) | CLI for Treesitter parser compilation | `sudo pacman -S tree-sitter tree-sitter-cli` |
| [cargo-nextest](https://nexte.st/) | Rust test runner (required by neotest-rust) | `sudo pacman -S cargo-nextest` |

## Installation

```bash
git clone https://github.com/<you>/dotfiles ~/dotfiles
cd ~/dotfiles
stow fish
stow foot
stow nvim
stow lazygit
stow noctalia
stow tmux
stow omp
stow hypr
```

## omp-ide bridge

omp connects to Neovim over the loopback WebSocket MCP server served by the `pi-ide.nvim` plugin
(extension: `omp/.omp/agent/extensions/omp-ide/`, lock dir `~/.pi/ide`). It auto-connects when nvim
is open in the same cwd: omp sees your cursor and selection as ambient context, every write/edit
opens as a two-pane diff (accept with `:w`, reject by closing), and nvim gets ghost-text
suggestions. nvim queues `file:line` refs via `<leader>ca` / `<leader>cA` / `<leader>cx`.

## Neovim Plugins

| Plugin | Purpose |
|--------|---------|
| [catppuccin/nvim](https://github.com/catppuccin/nvim) | Colorscheme (mocha, pure black bg — palette overrides inline in `colorscheme.lua`) |
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
| [nvim-dap-go](https://github.com/leoluz/nvim-dap-go) | Go DAP adapter |
| [nvim-dap-python](https://github.com/mfussenegger/nvim-dap-python) | Python DAP adapter |
| [nvim-dap-virtual-text](https://github.com/theHamsta/nvim-dap-virtual-text) | Inline variable values while debugging |
| [neotest](https://github.com/nvim-neotest/neotest) + [neotest-rust](https://github.com/rouge8/neotest-rust), [neotest-golang](https://github.com/fredrikaverpil/neotest-golang), [neotest-python](https://github.com/nvim-neotest/neotest-python) | Test runner (Rust, Go, Python). Rust needs `cargo-nextest`. Output panel opens as 20% horizontal split |
| [flash.nvim](https://github.com/folke/flash.nvim) | Jump navigation with labels |
| [nvim-surround](https://github.com/kylechui/nvim-surround) | Surround motions |
| [snacks.nvim](https://github.com/folke/snacks.nvim) | Lazygit integration |
| [nvim-dap-envfile](https://github.com/ravsii/nvim-dap-envfile) | Auto-load `.env` into DAP configs |
| [markdown-preview.nvim](https://github.com/selimacerbas/markdown-preview.nvim) | Live browser markdown preview |
| [conform.nvim](https://github.com/stevearc/conform.nvim) | Code formatter (Python via ruff_format, SQL, JS/TS via eslint_d + prettier) |
| [auto-session](https://github.com/rmagatti/auto-session) | Automatic session management |
| [mini.bufremove](https://github.com/echasnovski/mini.bufremove) | Smart buffer deletion (retain splits) |
| [pi-ide.nvim](https://github.com/ldelossa/pi-ide.nvim) | Two-way agent bridge (omp): ambient context, interactive diffs, ghost-text suggestions |

## LSP / Treesitter

Mason auto-installs the following language servers:

- `lua_ls` — Lua
- `pyright` — Python (auto-detects `.venv`/`venv` and sets `pythonPath`)
- `ts_ls` — TypeScript / JavaScript
- `eslint` — JavaScript / TypeScript linting
- `rust_analyzer` — Rust
- `gopls` — Go

Treesitter parsers: `lua`, `python`, `typescript`, `javascript`, `rust`, `go`, `sql`, `markdown`, `markdown_inline`

## LSP / Debug servers

Mason auto-installs:

- `codelldb` — Rust debugger
- `delve` — Go debugger
- `debugpy` — Python debugger

## Neovim Keymaps

See [KEYMAPS.md](KEYMAPS.md).
