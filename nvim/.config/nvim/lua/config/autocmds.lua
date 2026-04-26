local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Load .env from cwd into Neovim's environment so debug processes inherit it
local function load_dotenv()
  local path = vim.fn.getcwd() .. "/.env"
  local f = io.open(path, "r")
  if not f then return end
  for line in f:lines() do
    local key, val = line:match("^([A-Za-z_][A-Za-z0-9_]*)=(.*)$")
    if key then vim.fn.setenv(key, val) end
  end
  f:close()
end

augroup("LoadDotEnv", { clear = true })
autocmd({ "VimEnter", "DirChanged" }, {
  group = "LoadDotEnv",
  callback = load_dotenv,
})

-- Highlight on yank
augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
  group = "YankHighlight",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- Format on save via LSP
augroup("FormatOnSave", { clear = true })
autocmd("BufWritePre", {
  group = "FormatOnSave",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

-- Remove trailing whitespace on save
augroup("TrimWhitespace", { clear = true })
autocmd("BufWritePre", {
  group = "TrimWhitespace",
  pattern = "*",
  command = "%s/\\s\\+$//e",
})

-- Auto resize splits when window is resized
augroup("ResizeSplits", { clear = true })
autocmd("VimResized", {
  group = "ResizeSplits",
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})


-- Disable auto-comment on new line
augroup("NoAutoComment", { clear = true })
autocmd("BufEnter", {
  group = "NoAutoComment",
  callback = function()
    vim.opt_local.formatoptions:remove({ "r", "o" })
  end,
})

-- Return to last cursor position when opening a file
augroup("LastCursorPosition", { clear = true })
autocmd("BufReadPost", {
  group = "LastCursorPosition",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
