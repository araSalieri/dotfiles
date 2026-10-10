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

-- Copy a file ref to the clipboard, e.g. "@src/app.ts:12" or
-- "@src/app.ts:12-18" in visual mode (@refs work in pi and most agents).
local function rel_path()
  local path = vim.fn.expand("%:p")
  if path == "" then return nil end
  local cwd = vim.fn.getcwd()
  if vim.startswith(path, cwd .. "/") then path = path:sub(#cwd + 2) end
  return path
end
local function copy(str, what)
  vim.fn.setreg("+", str)
  vim.notify(str, vim.log.levels.INFO, { title = "Copied " .. what })
end
local function copy_append(str, what)
  -- External clipboard content often ends with a newline/space; trim before joining
  local cur = vim.fn.getreg("+"):gsub("%s+$", "")
  vim.fn.setreg("+", (cur ~= "" and cur .. " " or "") .. str)
  vim.notify(str, vim.log.levels.INFO, { title = "Appended " .. what })
end
local function current_ref()
  local path = rel_path()
  if not path then return nil end
  local line1 = vim.fn.line("v")
  local line2 = vim.fn.line(".")
  if line1 > line2 then line1, line2 = line2, line1 end
  return line1 == line2
    and string.format("@%s:%d", path, line1)
    or string.format("@%s:%d-%d", path, line1, line2)
end
map("n", "<leader>ca", function()
  local ref = current_ref()
  if ref then copy(ref, "ref") end
end, { desc = "Copy @file:line ref to clipboard" })
map("v", "<leader>ca", function()
  local ref = current_ref()
  if ref then copy(ref, "ref") end
end, { desc = "Copy @file:line range to clipboard" })
map("n", "<leader>cA", function()
  local ref = current_ref()
  if ref then copy_append(ref, "ref") end
end, { desc = "Append @file:line ref to clipboard" })
map("v", "<leader>cA", function()
  local ref = current_ref()
  if ref then copy_append(ref, "ref") end
end, { desc = "Append @file:line range to clipboard" })
map("n", "<leader>cP", function()
  local path = rel_path()
  if path then copy_append("@" .. path, "ref") end
end, { desc = "Append @file path to clipboard" })
map("n", "<leader>cp", function()
  local path = rel_path()
  if path then copy("@" .. path, "ref") end
end, { desc = "Copy @file path to clipboard" })

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<cr>")

-- Exit terminal mode
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
