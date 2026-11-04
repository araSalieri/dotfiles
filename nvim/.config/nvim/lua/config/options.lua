local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Tabs & indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true

-- Line wrapping
opt.wrap = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Appearance
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 8
opt.cmdheight = 0
opt.laststatus = 3
opt.fillchars = {
  eob = " ",
  horiz = "─",
  horizup = "┴",
  horizdown = "┬",
  vert = "│",
  vertleft = "┤",
  vertright = "├",
  verthoriz =
  "┼"
}

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#4a4a4a", bg = "NONE" })
  end,
})

-- Disable intro / startup message
opt.shortmess:append("I")

-- Clipboard
opt.clipboard = "unnamedplus"
-- over SSH there is no wl-copy, so copy through the terminal (OSC 52).
-- Paste reads nvim's own register: foot can't answer OSC 52 reads, so `p` would hang.
if os.getenv("SSH_CONNECTION") or os.getenv("SSH_TTY") then
  local osc52 = require("vim.ui.clipboard.osc52")
  local function paste()
    return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
  end
  vim.g.clipboard = {
    name = "OSC 52",
    copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
    paste = { ["+"] = paste, ["*"] = paste },
  }
end

-- Split windows
opt.splitright = true
opt.splitbelow = true

-- Backups / swap
opt.swapfile = false
opt.backup = false
opt.undofile = true
