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
      { "<leader>Tr", function() require("neotest").run.run() end,                     desc = "Run nearest test" },
      { "<leader>Tf", function() require("neotest").run.run(vim.fn.expand("%")) end,   desc = "Run file tests" },
      { "<leader>Ts", function() require("neotest").summary.toggle() end,              desc = "Toggle test summary" },
      { "<leader>To", function() require("neotest").output_panel.toggle() end,         desc = "Toggle test output" },
      { "<leader>Td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Debug nearest test" },
      { "<leader>TS", function() require("neotest").run.stop() end,                    desc = "Stop test" },
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
            vim.cmd("botright vsplit")
            vim.cmd("vertical resize " .. math.floor(vim.o.columns * 0.2))
          end,
        },
      })
    end,
  },
}
