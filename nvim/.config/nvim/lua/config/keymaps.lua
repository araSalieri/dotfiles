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
map("n", "<leader>ft", "<cmd>FormatToggle<cr>", { desc = "Toggle format on save (buffer)" })
map("n", "<leader>fT", "<cmd>FormatToggle!<cr>", { desc = "Toggle format on save (global)" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })

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

-- Refresh neo-tree and current buffer
map("n", "<leader>rr", function() require("neo-tree.sources.manager").refresh("filesystem") end,
  { desc = "Refresh file explorer" })
map("n", "<leader>rb", "<cmd>edit!<cr>", { desc = "Refresh buffer" })

-- Open external foot terminal at current file's directory
map("n", "<leader>tt", function()
  local dir = vim.fn.expand("%:p:h")
  if dir == "" then dir = vim.fn.getcwd() end
  vim.fn.jobstart({ "foot", "-D", dir }, { detach = true })
end, { desc = "Open foot terminal here" })

-- Open pi in a new foot terminal (git project root when available, else cwd)
map("n", "<leader>cc", function()
  local dir = vim.fn.getcwd()
  local root = vim.fn.systemlist("git -C " .. vim.fn.shellescape(dir) .. " rev-parse --show-toplevel 2>/dev/null")
  if root[1] and root[1] ~= "" then dir = root[1] end
  vim.fn.jobstart({ "foot", "-D", dir, "pi" }, { detach = true })
end, { desc = "Open pi (foot terminal)" })

-- Open omp in a new foot terminal (git project root when available, else cwd)
map("n", "<leader>co", function()
  local dir = vim.fn.getcwd()
  local root = vim.fn.systemlist("git -C " .. vim.fn.shellescape(dir) .. " rev-parse --show-toplevel 2>/dev/null")
  if root[1] and root[1] ~= "" then dir = root[1] end
  vim.fn.jobstart({ "foot", "-D", dir, "omp" }, { detach = true })
end, { desc = "Open omp (foot terminal)" })

-- pi-ide: send selection/line refs to a connected omp session (prefix "c")
local piq = require("config.pi-queue")
map("v", "<leader>ca", piq.add_ref, { desc = "Send selection as ref to omp" })
map("n", "<leader>cA", piq.add_ref, { desc = "Send current line as ref to omp" })
map("n", "<leader>cx", piq.clear, { desc = "Clear queued refs in omp" })

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<cr>")

-- Exit terminal mode
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Navigate windows from terminal mode
map("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Move to left window" })
map("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Move to right window" })
map("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Move to bottom window" })
map("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Move to top window" })
