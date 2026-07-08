# Neovim Keymaps

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
| Testing | `<leader>tr` | Run nearest test |
| Testing | `<leader>tf` | Run file tests |
| Testing | `<leader>ts` | Toggle test summary |
| Testing | `<leader>to` | Toggle test output |
| Testing | `<leader>td` | Debug nearest test |
| Testing | `<leader>tS` | Stop test |
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
| Terminal | `<leader>tt` | Open foot terminal at file's directory |
| Terminal | `Esc` (terminal mode) | Exit terminal mode |
| Terminal | `Ctrl+hjkl` (terminal mode) | Navigate windows from terminal |
