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
├── git/
│   └── git/
│       └── ignore                 # global gitignore (`.pi/hindsight/*`)
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
│               │   └── options.lua
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
│                   ├── snacks.lua
│                   └── treesitter.lua
├── pi/
│   └── .pi/
│       └── agent/
│           ├── APPEND_SYSTEM.md        # extra system-prompt rules
│           ├── hindsight.json          # pi-hindsight memory endpoint & banks
│           ├── settings.json           # model, packages (superpowers, pi-hindsight,
│           │                           #   pi-permission-system, pi-lens, …), subagent models
│           ├── themes/
│           │   └── dark-noborder.json  # borderless dark theme
│           ├── skills/
│           │   └── commit/SKILL.md     # git commit workflow skill
│           └── extensions/
│               ├── minimal-editor.ts   # borderless `>` input editor
│               └── pi-permission-system/
│                   └── config.json    # tool/permission rules (rm ask/deny, sudo ask, .env ask)
├── noctalia/
│   └── .config/
│       └── noctalia/
│           ├── config.toml      # Noctalia shell config (bar, launcher, screenshots via satty)
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
| [sesh](https://github.com/joshmedeski/sesh) | Session manager (tmux `prefix + T`) | `paru -S sesh-bin` |
| [fd](https://github.com/sharkdp/fd) | Directory search (sesh find fallback) | `sudo pacman -S fd` |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smarter `cd` in fish | `sudo pacman -S zoxide` |
| [tree](http://mama.indstate.edu/users/ice/tree/) | fzf directory preview | `sudo pacman -S tree` |
| [direnv](https://direnv.net/) | Per-directory env | `sudo pacman -S direnv` |
| [starship](https://starship.rs/) | Shell prompt | `sudo pacman -S starship` |
| [mise](https://mise.jdx.dev/) | Runtime version manager | `sudo pacman -S mise` |
| [JetBrainsMono Nerd Font](https://www.nerdfonts.com/) | Terminal font | `sudo pacman -S ttf-jetbrains-mono-nerd` |
| [paru](https://github.com/Morganamilo/paru) | AUR helper | `sudo pacman -S --needed base-devel && git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si` |
| [tree-sitter](https://github.com/tree-sitter/tree-sitter) | CLI for Treesitter parser compilation | `sudo pacman -S tree-sitter tree-sitter-cli` |
| [cargo-nextest](https://nexte.st/) | Rust test runner (required by neotest-rust) | `sudo pacman -S cargo-nextest` |
| [lazygit](https://github.com/jesseduffield/lazygit) | Git TUI | `sudo pacman -S lazygit` |
| [lazydocker](https://github.com/jesseduffield/lazydocker) | Docker TUI | `paru -S lazydocker` |
| [unimatrix](https://github.com/will8211/unimatrix) | Matrix terminal effect | `paru -S unimatrix-git` |

## Installation

```bash
git clone https://github.com/<you>/dotfiles ~/dotfiles
cd ~/dotfiles
stow fish
stow foot
stow git
stow nvim
stow lazygit
stow noctalia
stow tmux
stow pi
stow hypr
```

## File refs to the clipboard

`<leader>ca` copies an `@path:line` ref to the system clipboard — `@path:12` in normal mode,
`@path:12-18` in visual mode. Paths are relative to the cwd when possible. No socket, no running
agent required: paste the ref into pi, claude, or any terminal. In LSP-attached buffers, normal
mode keeps LSP code actions; visual mode still copies the ref.

## pi agent

`pi/.pi/agent/` (stowed to `~/.pi/agent/`) configures the [pi coding agent](https://github.com/earendil-works/pi):

- **`settings.json`** — default model/thinking level, pi packages (`pi-mcp-adapter`, `pi-web-access`,
  `pi-subagents`, `pi-lens`, `pi-fff`, `pi-simplify`, `pi-permission-system`, `pi-hindsight`, and
  `superpowers` from git), subagent model overrides, and the `dark-noborder` theme
- **`skills/commit/`** — local commit skill (stages and commits in one response); replaced the
  `@eamode/pi-commit` extension
- **`extensions/pi-permission-system/`** — permission rules: everything allowed by default,
  `rm -rf` denied, `rm`/`sudo`/`.env` writes ask (audit log gitignored)
- **`extensions/minimal-editor.ts`** — replaces pi's bordered input editor with a `>` prompt
- **`APPEND_SYSTEM.md`** — extra system-prompt rules (confirm big changes, write simply, en dashes)
- **`hindsight.json`** — points pi-hindsight at the memory server and the `memories` project bank

## fish

`fish/.config/fish/config.fish` sources the CachyOS fish config, then adds:

- zoxide init and `alias cd z`
- `alias vim nvim` / `alias vi nvim` / `alias yay paru`
- `FZF_CTRL_T_COMMAND` backed by `fd` (hidden files, node_modules/target/.git/.venv/dist excluded)

## tmux

`tmux/.tmux.conf` is managed by [tpm](https://github.com/tmux-plugins/tpm) (install with
`git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`, then `prefix + I`):

| Plugin | Purpose |
|--------|---------|
| [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible) | Sane defaults |
| [tmux-window-name](https://github.com/ofirgall/tmux-window-name) | Automatic window names |
| [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) + [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum) | Session save/restore (`@continuum-restore on`) |
| [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) | Vim-aware pane navigation |
| [tmux-copycat](https://github.com/tmux-plugins/tmux-copycat) | Search pane content |

Keybinds (prefix is `C-a`):

- `C-a S` / `C-a V` — main-horizontal / main-vertical layout
- `C-a x` — kill pane; sessions survive destruction (`detach-on-destroy off`)
- `C-a T` — sesh session picker (tmux, configs, zoxide dirs, directory find, kill session)
- `C-a r` — reload config
- vi copy mode: `v` to select, `y` to copy-and-cancel

Status bar: `· PREFIX` indicator on `C-a`, session/host/time on the right, heavy pane borders with
gruvbox colors.

## git

`git/git/ignore` is installed as the global gitignore via `core.excludesFile` and excludes
`.pi/hindsight/*` (pi-hindsight runtime state).

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
