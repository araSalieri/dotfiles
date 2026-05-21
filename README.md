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
└── claude/
    └── .claude/
        ├── settings.json
        ├── statusline-command.sh  # status line: cwd, branch, model, ctx%, 5h/7d rate limits
        ├── commands/
        │   └── commit.md      # /commit — caveman-style conventional commit (via caveman-commit skill)
        └── skills/
            └── grill-me/
                └── SKILL.md   # /grill-me — stress-test a plan or design
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
| [nvim-dap-go](https://github.com/leoluz/nvim-dap-go) | Go DAP adapter |
| [nvim-dap-python](https://github.com/mfussenegger/nvim-dap-python) | Python DAP adapter |
| [neotest](https://github.com/nvim-neotest/neotest) + [neotest-rust](https://github.com/rouge8/neotest-rust), [neotest-golang](https://github.com/fredrikaverpil/neotest-golang), [neotest-python](https://github.com/nvim-neotest/neotest-python) | Test runner (Rust, Go, Python). Output panel opens as 20% vsplit |
| [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) | Toggleable terminal (vertical split) |
| [flash.nvim](https://github.com/folke/flash.nvim) | Jump navigation with labels |
| [nvim-surround](https://github.com/kylechui/nvim-surround) | Surround motions |
| [snacks.nvim](https://github.com/folke/snacks.nvim) | Lazygit integration |
| [nvim-dap-envfile](https://github.com/ravsii/nvim-dap-envfile) | Auto-load `.env` into DAP configs |
| [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) | Rendered markdown in buffer |
| [claudecode.nvim](https://github.com/coder/claudecode.nvim) | Claude Code integration |
| [claude-fzf.nvim](https://github.com/pittcat/claude-fzf.nvim) | fzf-powered file/grep context for Claude |
| [claude-fzf-history.nvim](https://github.com/pittcat/claude-fzf-history.nvim) | Browse and add Claude history via fzf |
| [conform.nvim](https://github.com/stevearc/conform.nvim) | Code formatter (Python via ruff_format, SQL, JS/TS via eslint_d + prettier) |
| [auto-session](https://github.com/rmagatti/auto-session) | Automatic session management |
| [mini.bufremove](https://github.com/echasnovski/mini.bufremove) | Smart buffer deletion (retain splits) |

## LSP / Treesitter

Mason auto-installs the following language servers:

- `lua_ls` — Lua
- `pyright` — Python (auto-detects `.venv`/`venv` and sets `pythonPath`)
- `ts_ls` — TypeScript / JavaScript
- `eslint` — JavaScript / TypeScript linting
- `rust_analyzer` — Rust
- `gopls` — Go

Treesitter parsers: `lua`, `python`, `typescript`, `javascript`, `rust`, `go`, `sql`

## LSP / Debug servers

Mason auto-installs:

- `codelldb` — Rust debugger
- `delve` — Go debugger
- `debugpy` — Python debugger

## Neovim Keymaps

| Group | Key | Action |
|-------|-----|--------|
| File | `<leader>w` | Save file |
| File | `<leader>q` | Quit window |
| File | `<leader>Q` | Quit all (force) |
| Explorer | `<leader>e` | Toggle file explorer |
| Explorer | `<leader>E` | Focus file explorer |
| Explorer | `<C-x>` (in tree) | Open file in horizontal split |
| Explorer | `<C-v>` (in tree) | Open file in vertical split |
| Fuzzy Finder | `<leader>ff` | Find files |
| Fuzzy Finder | `<leader>fg` | Live grep |
| Fuzzy Finder | `<leader>fb` | Buffers |
| Fuzzy Finder | `<leader>ft` | Tabs |
| Fuzzy Finder | `<leader>fk` | Keymaps |
| Buffer | `<leader>bn` | Next buffer |
| Buffer | `<leader>bp` | Prev buffer |
| Buffer | `<leader>bd` | Delete buffer (retain split) |
| Window | `Ctrl+hjkl` | Navigate windows |
| Window | `<leader>sv` | Split vertical |
| Window | `<leader>sh` | Split horizontal |
| Editing | `<` (visual) | Indent left (keep selection) |
| Editing | `>` (visual) | Indent right (keep selection) |
| Editing | `J` (visual) | Move line down |
| Editing | `K` (visual) | Move line up |
| Testing | `<leader>Tr` | Run nearest test |
| Testing | `<leader>Tf` | Run file tests |
| Testing | `<leader>Ts` | Toggle test summary |
| Testing | `<leader>To` | Toggle test output |
| Testing | `<leader>Td` | Debug nearest test |
| Testing | `<leader>TS` | Stop test |
| Debugger | `<leader>db` | Toggle breakpoint |
| Debugger | `<leader>dc` | Continue / start debugger |
| Debugger | `<leader>di` | Step into |
| Debugger | `<leader>do` | Step over |
| Debugger | `<leader>dO` | Step out |
| Debugger | `<leader>dt` | Terminate debugger |
| Debugger | `<leader>du` | Toggle DAP UI |
| Claude | `<leader>ac` | Toggle Claude terminal |
| Claude | `<leader>af` | Focus Claude |
| Claude | `<leader>ar` | Resume Claude session |
| Claude | `<leader>aC` | Continue Claude session |
| Claude | `<leader>am` | Select Claude model |
| Claude | `<leader>ab` | Add current buffer to Claude |
| Claude | `<leader>as` | Send selection to Claude (visual) / Add file from tree (in neo-tree) |
| Claude (fzf) | `<leader>cf` | Add files to Claude via fzf |
| Claude (fzf) | `<leader>cg` | Search and add files to Claude |
| Claude (fzf) | `<leader>cb` | Add buffers to Claude via fzf |
| Claude (fzf) | `<leader>cd` | Add directory files to Claude |
| Claude (fzf) | `<leader>ch` | Add Claude history via fzf |
| Flash | `s` | Jump with labels |
| Flash | `S` (normal/op-pending) | Treesitter jump |
| Flash | `r` (operator-pending) | Remote flash |
| Flash | `R` (operator-pending/visual) | Treesitter search |
| Flash | `<C-s>` (command) | Toggle flash search |
| Surround | `ys{motion}{char}` | Add surround (e.g. `ysiw"`) |
| Surround | `ds{char}` | Delete surround (e.g. `ds"`) |
| Surround | `cs{old}{new}` | Change surround (e.g. `cs"'`) |
| Surround | `S{char}` (visual) | Surround selection |
| Format | `<leader>fm` | Format buffer |
| LSP | `<leader>ca` | Code actions |
| LSP | `<leader>rn` | Rename symbol |
| LSP | `gd` | Go to definition |
| LSP | `gr` | Go to references |
| LSP | `gD` | Go to declaration |
| LSP | `gi` | Go to implementation |
| LSP | `K` / `gh` | Hover documentation |
| Git | `<leader>gg` | Open Lazygit |
| Git | `<leader>gc` | Git branches |
| Session | `<leader>ss` | Search sessions |
| Refresh | `<leader>rr` | Refresh file explorer |
| Refresh | `<leader>rb` | Refresh current buffer |
| Terminal | `<leader>tt` | Toggle terminal |
| Terminal | `Esc` (terminal mode) | Exit terminal mode |
| Terminal | `Ctrl+hjkl` (terminal mode) | Navigate windows from terminal |

## Neovim Features

- Format on save (via LSP)
- Highlight on yank
- Trim trailing whitespace on save
- Restore last cursor position on file open
- Auto resize splits on window resize
- Neo-tree opens automatically on startup
- Hidden files visible in file explorer
- Pyright auto-detects project venv (`.venv` or `venv`) and sets `pythonPath`
- Neotest output panel opens as 20% vertical split on the right

## Claude Code

- Custom status line (`claude/.claude/statusline-command.sh`): cwd, git branch, model, context %, plus 5h/7d `rate_limits.used_percentage` (Pro/Max only, segments skipped when field absent)
- `/commit` slash command routes through caveman-commit skill for terse Conventional Commits

## Prerequisites

| Tool | Purpose | Install |
|------|---------|---------|
| [stow](https://www.gnu.org/software/stow/) | Symlink manager | `sudo pacman -S stow` |
| [neovim](https://neovim.io/) >= 0.10 | Editor | `sudo pacman -S neovim` |
| [ghostty](https://ghostty.org/) | Terminal emulator | `sudo pacman -S ghostty` |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder | `sudo pacman -S fzf` |
| [bat](https://github.com/sharkdp/bat) | fzf file preview | `sudo pacman -S bat` |
| [fd](https://github.com/sharkdp/fd) | fzf repo search (Alt+C) | `sudo pacman -S fd` |
| [tree](http://mama.indstate.edu/users/ice/tree/) | fzf directory preview | `sudo pacman -S tree` |
| [mise](https://mise.jdx.dev/) | Runtime version manager | `sudo pacman -S mise` |
| [starship](https://starship.rs/) | Shell prompt | `sudo pacman -S starship` |
| [FiraCode Nerd Font](https://www.nerdfonts.com/) | Terminal font | `sudo pacman -S ttf-firacode-nerd` |
| [lazygit](https://github.com/jesseduffield/lazygit) | Git TUI | `sudo pacman -S lazygit` |
| [Claude Code](https://claude.ai/code) | AI coding assistant CLI | `npm install -g @anthropic-ai/claude-code` |
| [tree-sitter](https://github.com/tree-sitter/tree-sitter) | CLI for Treesitter parser compilation | `cargo install tree-sitter-cli` |

## Installation

```bash
git clone https://github.com/<you>/dotfiles ~/dotfiles
cd ~/dotfiles
stow --target=$HOME bashrc
stow ghostty
stow nvim
stow starship
stow claude
```
