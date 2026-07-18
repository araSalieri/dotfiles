return {
  {
    "NickvanDyke/opencode.nvim",
    version = "*",
    dependencies = { "folke/snacks.nvim" },
    init = function()
      -- required for events.reload to pick up opencode's edits
      vim.o.autoread = true
    end,
    config = function()
      vim.g.opencode_opts = {
        server = {
          -- launch the TUI in a separate foot window instead of a nvim split;
          -- the plugin discovers it via `pgrep opencode.*--port` + lsof
          start = function()
            vim.system({ "foot", "opencode", "--port", "0" }, { cwd = vim.fn.getcwd(), detach = true })
          end,
        },
      }
    end,
    keys = {
      { "<leader>oa", function() require("opencode").ask("@this: ") end,               mode = { "n", "v" },          desc = "Ask opencode about this" },
      { "<leader>oA", function() require("opencode").ask() end,                        mode = { "n", "v" },          desc = "Ask opencode" },
      { "<leader>os", function() require("opencode").select() end,                     mode = { "n", "v" },          desc = "Select opencode prompt/command" },
      { "<leader>on", function() require("opencode").command("session.new") end,       desc = "New opencode session" },
      { "<leader>oi", function() require("opencode").command("session.interrupt") end, desc = "Interrupt opencode" },
      { "<leader>ot", function() require("opencode.config").opts.server.start() end,   desc = "Open opencode terminal" },
      { "<leader>oe", function() require("opencode").prompt("Explain @this") end,      desc = "Explain this" },
      { "<leader>of", function() require("opencode").prompt("Fix @diagnostics") end,   desc = "Fix diagnostics" },
    },
  },
}
