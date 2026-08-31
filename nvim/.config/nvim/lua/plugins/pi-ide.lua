-- pi-ide: two-way bridge between omp and Neovim over a loopback WebSocket MCP
-- server. omp side: extension at omp/.omp/agent/extensions/omp-ide/ (lock dir
-- ~/.pi/ide — "pi" there is upstream naming).
--
-- omp auto-connects when nvim is open in the same cwd. While connected:
--   * omp always sees your current file, cursor, and selection (ambient context)
--   * every omp write/edit opens as a two-pane diff — edit freely, `:w` to
--     accept, close the window to reject
--   * ghost-text suggestions served by the connected omp session
--   * omp can read your LSP diagnostics and open buffers
--   * nvim queues file:line refs for omp via <leader>ca/cA/cx (config/pi-queue.lua)
return {
  {
    "ldelossa/pi-ide.nvim",
    lazy = false,
    config = function()
      require("pi-ide").setup({
        auto_start = true,
        suggestion = {
          auto_trigger = true,
          default_keys = false, -- <Tab> belongs to nvim-cmp; bound below instead
          model = "opencode-go/deepseek-v4-flash",
        },
      })
      -- Copilot-style keys, with <Tab> left to nvim-cmp.
      vim.keymap.set("i", "<M-\\>", "<Plug>(PiSuggest)", { remap = true, desc = "pi-ide: trigger suggestion" })
      vim.keymap.set("i", "<M-]>", "<Plug>(PiSuggestNext)", { remap = true, desc = "pi-ide: next suggestion" })
      vim.keymap.set("i", "<M-[>", "<Plug>(PiSuggestPrev)", { remap = true, desc = "pi-ide: previous suggestion" })
      vim.keymap.set("i", "<C-l>", "<Plug>(PiSuggestAccept)", { remap = true, desc = "pi-ide: accept suggestion" })
      vim.keymap.set("i", "<C-]>", "<Plug>(PiSuggestDismiss)", { remap = true, desc = "pi-ide: dismiss suggestion" })
    end,
  },
}
