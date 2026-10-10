# Neovim Keymaps

| Group | Key | Action |
|-------|-----|--------|
| File | `<leader>w` | Save file |
| File | `<leader>W` | Save without format-on-save autocmds |
| File | `<leader>q` | Quit window |
| File | `<leader>Q` | Quit all (force) |
| Explorer | `<leader>e` | Toggle file explorer |
| Explorer | `<leader>E` | Focus file explorer |
| Explorer | `<C-s>` (in tree) | Open file in horizontal split |
| Explorer | `<C-v>` (in tree) | Open file in vertical split |
| Fuzzy Finder | `<leader>ff` | Find files |
| Fuzzy Finder | `<leader>fg` | Live grep |
| Fuzzy Finder | `<leader>fb` | Buffers |
| Fuzzy Finder | `<leader>fk` | Keymaps |
| Fuzzy Finder | `<CR>` (in picker) | Open file (or send to quickfix) |
| Fuzzy Finder | `<C-s>` (in picker) | Open file in horizontal split |
| Fuzzy Finder | `<C-v>` (in picker) | Open file in vertical split |
| Fuzzy Finder | `<C-t>` (in picker) | Open file in new tab |
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
| Format | `<leader>uf` | Toggle format on save (buffer) |
| Format | `<leader>uF` | Toggle format on save (global) |
| Format | `<leader>fm` | Format buffer |
| LSP | `<leader>ca` | Code actions (LSP-attached buffers; see note below) |
| LSP | `<leader>rn` | Rename symbol |
| LSP | `gd` | Go to definition |
| LSP | `gr` | Go to references |
| LSP | `gD` | Go to declaration |
| LSP | `gi` | Go to implementation |
| LSP | `K` / `gh` | Hover documentation |
| Ref | `<leader>ca` | Copy `@path:line` (normal) or `@path:start-end` (visual; exits visual mode) to the clipboard |
| Ref | `<leader>cA` | Append `@path:line` (normal) or `@path:start-end` (visual; exits visual mode) to the clipboard (space-separated) |
| Ref | `<leader>cf` | Copy `@path` (relative to cwd) to the clipboard |
| Ref | `<leader>cF` | Append `@path` (relative to cwd) to the clipboard (space-separated) |
| Git | `<leader>gg` | Open Lazygit |
| Git | `<leader>gc` | Git branches |
| Git | `<leader>gd` | Diff vs previous commit |
| Git | `<leader>gD` | Diff vs index |
| Git | `<leader>gb` | Blame line |
| Git | `<leader>gB` | Blame buffer |
| Session | `<leader>ss` | Search sessions |
| Flash | `s` | Jump with labels |
| Flash | `S` (normal/op-pending) | Treesitter jump |
| Flash | `r` (operator-pending) | Remote flash |
| Flash | `R` (operator-pending/visual) | Treesitter search |
| Flash | `<C-s>` (command) | Toggle flash search |
| Surround | `ys{motion}{char}` | Add surround (e.g. `ysiw"`) |
| Surround | `ds{char}` | Delete surround (e.g. `ds"`) |
| Surround | `cs{old}{new}` | Change surround (e.g. `cs"'`) |
| Surround | `S{char}` (visual) | Surround selection |
| Testing | `<leader>tr` | Run nearest test |
| Testing | `<leader>tf` | Run file tests |
| Testing | `<leader>ts` | Toggle test summary |
| Testing | `<leader>to` | Toggle test output |
| Testing | `<leader>td` | Debug nearest test |
| Testing | `<leader>tS` | Stop test |
| Debugger | `<leader>db` | Toggle breakpoint |
| Debugger | `<leader>dB` | Conditional breakpoint |
| Debugger | `<leader>dc` | Continue / start debugger |
| Debugger | `<leader>di` | Step into |
| Debugger | `<leader>do` | Step over |
| Debugger | `<leader>dO` | Step out |
| Debugger | `<leader>dr` | Run last debug session |
| Debugger | `<leader>de` | Eval expression under cursor (normal/visual) |
| Debugger | `<leader>dt` | Terminate debugger |
| Debugger | `<leader>du` | Toggle DAP UI |
| Refresh | `<leader>rb` | Refresh current buffer |
| Terminal | `<leader>tt` | Open foot terminal at file's directory |
| Terminal | `Esc` (terminal mode) | Exit terminal mode |
| Terminal | `Ctrl+hjkl` (terminal mode) | Navigate windows from terminal |

Notes:

- `<leader>ca` in LSP-attached buffers: normal mode runs LSP code actions, visual mode copies the range ref. In buffers without LSP it copies the ref in both modes.
