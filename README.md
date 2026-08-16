# dotfiles

Personal configuration managed with [stow](https://www.gnu.org/software/stow/).

## Structure

```
dotfiles/
├── KEYMAPS.md                # Neovim keymap reference
├── caelestia/
│   └── .config/
│       └── caelestia/
│           ├── hypr-user.lua  # Hyprland user overrides
│           └── hypr-vars.lua  # Hyprland variables
├── caelestia-schemes/        # NOT a stow package - backup of custom colour schemes
│   └── pureblack/
│       └── default/
│           └── dark.txt
├── lazygit/
│   └── .config/
│       └── lazygit/
│           └── config.yml
├── fish/
│   └── .config/
│       └── fish/
│           └── config.fish
├── foot/
│   └── .config/
│       └── foot/
│           └── foot.ini      # terminal: opaque pureblack bg, JetBrains Mono
├── swappy/
│   └── .config/
│       └── swappy/
│           └── config          # screenshot annotation: no panel, early exit, saves to ~/pictures/screenshots
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
│                   ├── neo-tree.lua
│                   ├── fzf.lua
│                   ├── treesitter.lua
│                   ├── lsp.lua
│                   ├── completion.lua
│                   ├── lualine.lua
│                   ├── dap.lua
│                   ├── neotest.lua
│                   ├── snacks.lua
│                   ├── markdown.lua
│                   ├── formatting.lua
│                   └── editor.lua
└── omp/
│   └── .omp/
│       └── agent/
│           ├── AGENTS.md      # global agent instructions
│           └── config.yaml    # agent config (models, theme, etc.)
```


## Prerequisites

| Tool | Purpose | Install |
|------|---------|---------|
| [stow](https://www.gnu.org/software/stow/) | Symlink manager | `sudo pacman -S stow` |
| [neovim](https://neovim.io/) >= 0.10 | Editor | `sudo pacman -S neovim` |
| [fish](https://fishshell.com/) | Shell | `sudo pacman -S fish` |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder | `sudo pacman -S fzf` |
| [bat](https://github.com/sharkdp/bat) | fzf file preview | `sudo pacman -S bat` |
| [fd](https://github.com/sharkdp/fd) | fzf repo search (Alt+C) | `sudo pacman -S fd` |
| [tree](http://mama.indstate.edu/users/ice/tree/) | fzf directory preview | `sudo pacman -S tree` |
| [eza](https://github.com/eza-community/eza) | `ls` replacement | `sudo pacman -S eza` |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smarter `cd` | `sudo pacman -S zoxide` |
| [direnv](https://direnv.net/) | Per-directory env | `sudo pacman -S direnv` |
| [starship](https://starship.rs/) | Shell prompt | `sudo pacman -S starship` |
| [mise](https://mise.jdx.dev/) | Runtime version manager | `sudo pacman -S mise` |
| [JetBrainsMono Nerd Font](https://www.nerdfonts.com/) | Terminal font | `sudo pacman -S ttf-jetbrains-mono-nerd` |
| [lazygit](https://github.com/jesseduffield/lazygit) | Git TUI | `sudo pacman -S lazygit` |
| [foot](https://codeberg.org/dnkl/foot) | Terminal emulator | `sudo pacman -S foot` |
| [swappy](https://github.com/jtheoof/swappy) | Screenshot annotation | `sudo pacman -S swappy` |
| [paru](https://github.com/Morganamilo/paru) | AUR helper | `sudo pacman -S --needed base-devel && git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si` |
| [omp (Oh My Pi)](https://github.com/can1357/oh-my-pi) | AI coding assistant CLI | `paru -S omp-bin` |
| [tree-sitter](https://github.com/tree-sitter/tree-sitter) | CLI for Treesitter parser compilation | `cargo install tree-sitter-cli` |
| [cargo-nextest](https://nexte.st/) | Rust test runner (required by neotest-rust) | `sudo pacman -S cargo-nextest` |

## Installation

```bash
git clone https://github.com/<you>/dotfiles ~/dotfiles
cd ~/dotfiles
stow fish
stow nvim
stow caelestia
stow lazygit
stow foot
stow swappy
stow omp
```

## OMP (Oh My Pi)

Agent config (`~/.omp/agent/AGENTS.md`, `config.yaml`) is stowed from `omp/.omp/agent/`.

Plugin code lives in `~/.omp/plugins/{node_modules,cache}` — fetched from source, not committed.
Only the install declaration is durable; restore with:

```bash
omp plugin marketplace add DietrichGebert/ponytail
omp plugin install ponytail@ponytail
omp plugin install omp.nvim
```

`omp plugin list` should then show `ponytail@ponytail` and `omp.nvim`. Enablement/feature/settings state lives in
`~/.omp/plugins/omp-plugins.lock.json` (machine-independent); stow it too if you want that state versioned.

## Neovim Plugins

| Plugin | Purpose |
|--------|---------|
| [catppuccin/nvim](https://github.com/catppuccin/nvim) | Colorscheme (mocha, pure black bg — palette from `caelestia-schemes/pureblack`) |
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
