local map = vim.keymap.set

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Save & quit
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
map("n", "<leader>Q", "<cmd>qa!<cr>", { desc = "Quit all" })

-- Save without running format-on-save autocmds
map("n", "<leader>W", "<cmd>noautocmd w<cr>", { desc = "Save file (no format)" })

-- Format on save toggles
map("n", "<leader>uf", "<cmd>FormatToggle<cr>", { desc = "Toggle format on save (buffer)" })
map("n", "<leader>uF", "<cmd>FormatToggle!<cr>", { desc = "Toggle format on save (global)" })

-- Window navigation: handled by vim-tmux-navigator (plugins/tmux-navigator.lua)

-- Window splits
map("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "Split vertical" })
map("n", "<leader>sh", "<cmd>split<cr>", { desc = "Split horizontal" })

-- Buffer navigation
map('n', '<leader>bn', ':bnext<CR>', { desc = "Next buffer" })
map('n', '<leader>bp', ':bprevious<CR>', { desc = "Prev buffer" })
map("n", "<leader>bd", function()
  local buf = vim.api.nvim_get_current_buf()
  if #vim.fn.win_findbuf(buf) > 1 then
    vim.cmd("close")
  else
    require("mini.bufremove").delete(0, false)
  end
end, { desc = "Delete Buffer" })

-- Indenting in visual mode (keep selection)
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Move lines up/down
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move line down" })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move line up" })

map("n", "<leader>rb", "<cmd>edit!<cr>", { desc = "Refresh buffer" })

-- Open external foot terminal at current file's directory
map("n", "<leader>tt", function()
  local dir = vim.fn.expand("%:p:h")
  if dir == "" then dir = vim.fn.getcwd() end
  vim.fn.jobstart({ "foot", "-D", dir }, { detach = true })
end, { desc = "Open foot terminal here" })

-- pi-ide: send selection/file refs to the connected agent session (prefix "c")
local piq = require("config.pi-queue")
map("v", "<leader>ca", piq.add_ref, { desc = "Send selection as ref to agent" })
map("n", "<leader>cf", piq.file_ref, { desc = "Send selected file(s) as ref to agent" })

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<cr>")

-- Exit terminal mode
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
