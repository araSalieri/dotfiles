# Neovim Keymaps

| Group | Key | Action |
|-------|-----|--------|
| File | `<leader>w` | Save file |
| File | `<leader>W` | Save without format-on-save autocmds |
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
| Fuzzy Finder | `<CR>` (in picker) | Open file (or send to quickfix) |
| Fuzzy Finder | `<C-x>` (in picker) | Open file in horizontal split |
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
| LSP | `<leader>ca` | Code actions (normal mode, LSP-attached buffers) |
| LSP | `<leader>rn` | Rename symbol |
| LSP | `gd` | Go to definition |
| LSP | `gr` | Go to references |
| LSP | `gD` | Go to declaration |
| LSP | `gi` | Go to implementation |
| LSP | `K` / `gh` | Hover documentation |
| pi | `<leader>ca` (visual) | Queue the selection as an `@path:lines` ref in pi's editor input |
| pi | `<leader>cf` | Queue snacks-picker file(s) or the current buffer as refs in pi's input |
| pi | `<leader>pi` | Ping the running pi session |
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
| Markdown | `<leader>mp` | Markdown preview (markdown buffers) |
| Markdown | `<leader>mr` | Markdown preview refresh (markdown buffers) |
| Markdown | `<leader>ms` | Markdown preview stop (markdown buffers) |
| Refresh | `<leader>rr` | Refresh file explorer |
| Refresh | `<leader>rb` | Refresh current buffer |
| Terminal | `<leader>tt` | Open foot terminal at file's directory |
| Terminal | `Esc` (terminal mode) | Exit terminal mode |
| Terminal | `Ctrl+hjkl` (terminal mode) | Navigate windows from terminal |

Notes:

- `<leader>ca` coexists by mode: normal-mode is LSP code actions (buffer-local, LSP-attached buffers); visual-mode queues the selection as a ref for the running pi session. Queued refs accumulate in pi's editor input and are read by the model when the message is sent; immediate sends stay on the `:PiSendSelection`/`:PiSendFile`/`:PiSendBuffer`/`:PiPrompt` commands.
