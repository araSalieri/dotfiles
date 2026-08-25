-- pi-ide: two-way bridge between pi and Neovim over a loopback WebSocket MCP
-- server. Pi side: `npm:@ldelossa/pi-ide` (listed in pi/.pi/agent/settings.json).
--
-- pi auto-connects on start when nvim is open in the same cwd (or `/ide` in
-- pi to connect/switch/disconnect). While connected:
--   * pi always sees your current file, cursor, and selection (ambient context)
--   * every pi write/edit opens as a two-pane diff — edit freely, `:w` to
--     accept, close the window to reject
--   * ghost-text suggestions served by the connected pi session
--   * pi can read your LSP diagnostics and open buffers
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
