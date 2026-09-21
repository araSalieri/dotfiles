-- pi-ide: two-way bridge between the pi agent and Neovim over a loopback WebSocket MCP
-- server. Agent side: pi extension at pi/.pi/agent/extensions/pi-ide/ (lock dir ~/.pi/ide —
-- "pi" there is upstream naming).
--
-- The agent auto-connects when nvim is open in the same cwd. While connected:
--   * the agent always sees your current file, cursor, and selection (ambient context)
--   * every agent write/edit opens as a two-pane diff — edit freely, `:w` to
--     accept, close the window to reject
--   * ghost-text suggestions served by the connected agent session
--   * the agent can read your LSP diagnostics and open buffers
--   * nvim queues file:line refs for the agent via <leader>ca/cA/cx (config/pi-queue.lua)
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
          -- Must exist in the connected agent's model registry;
          -- non-thinking models work best for inline completion.
          model = "openrouter/openai/gpt-5-nano",
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
