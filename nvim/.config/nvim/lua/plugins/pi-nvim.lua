-- pi-nvim: socket bridge between pi and Neovim (the omp.nvim equivalent).
-- Pi side: `pi install npm:pi-nvim` (already listed in pi/.pi/agent/settings.json).
-- `:Pi` (default <leader>p in normal/visual mode) sends the current file name,
-- the visual selection (with line range), and an optional prompt to pi.
return {
  {
    "carderne/pi-nvim",
    lazy = false,
    config = function()
      require("pi-nvim").setup({ set_default_keymaps = false })
      require("config.pi-multi").setup()
    end,
  },
}
