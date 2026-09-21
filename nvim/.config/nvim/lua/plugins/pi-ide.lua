-- pi-ide: two-way bridge between the pi agent and Neovim over a loopback WebSocket MCP
-- server. Agent side: pi extension at pi/.pi/agent/extensions/pi-ide/ (lock dir ~/.pi/ide —
-- "pi" there is upstream naming).
--
-- The agent auto-connects when nvim is open in the same cwd. While connected:
--   * the agent always sees your current file, cursor, and selection (ambient context)
--   * every agent write/edit opens as a two-pane diff — edit freely, `:w` to
--     accept, close the window to reject
-- --   * the agent can read your LSP diagnostics and open buffers
--   * nvim queues file:line refs for the agent via <leader>ca/cA/cx (config/pi-queue.lua)
return {
  {
    "ldelossa/pi-ide.nvim",
    lazy = false,
    config = function()
      require("pi-ide").setup({
        auto_start = true,
        suggestion = { auto_trigger = false },
      })
    end,
  },
}
