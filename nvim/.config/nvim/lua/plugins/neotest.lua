return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "rouge8/neotest-rust",
      "fredrikaverpil/neotest-golang",
      "nvim-neotest/neotest-python",
    },
    keys = {
      { "<leader>tr", function() require("neotest").run.run() require("neotest").output_panel.open() end,                   desc = "Run nearest test" },
      { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) require("neotest").output_panel.open() end, desc = "Run file tests" },
      { "<leader>ts", function() require("neotest").summary.toggle() end,              desc = "Toggle test summary" },
      { "<leader>to", function() require("neotest").output_panel.toggle() end,         desc = "Toggle test output" },
      { "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Debug nearest test" },
      { "<leader>tS", function() require("neotest").run.stop() end,                    desc = "Stop test" },
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-rust")({ args = { "--no-capture" } }),
          require("neotest-golang")({}),
          require("neotest-python"),
        },
        output_panel = {
          open = function()
            vim.cmd("botright split")
            vim.cmd("resize " .. math.floor(vim.o.lines * 0.2))
          end,
        },
      })
    end,
  },
}
