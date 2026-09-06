return {
  {
    "rmagatti/auto-session",
    lazy = false,
    opts = {
      suppressed_dirs = { "~/", "~/Downloads", "/" },
      pre_save_cmds = {
        function()
          local strip = {
            ["neo-tree"] = true,
            ["snacks_picker_list"] = true,
            ["snacks_picker_input"] = true,
            ["neotest-output-panel"] = true,
            ["neotest-summary"] = true,
            ["dapui_scopes"] = true,
            ["dapui_breakpoints"] = true,
            ["dapui_stacks"] = true,
            ["dapui_watches"] = true,
            ["dapui_console"] = true,
            ["dap-repl"] = true,
          }
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local ft = vim.bo[buf].filetype
            if strip[ft] and #vim.api.nvim_list_wins() > 1 then
              pcall(vim.api.nvim_win_close, win, true)
            end
          end
        end,
      },
    },
    keys = {
      { "<leader>ss", "<cmd>AutoSession search<cr>", desc = "Search sessions" },
    },
  },

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    keys = {
      { "s",     function() require("flash").jump() end,              mode = { "n", "x", "o" }, desc = "Flash" },
      { "S",     function() require("flash").treesitter() end,        mode = { "n", "o" },      desc = "Flash Treesitter" },
      { "r",     function() require("flash").remote() end,            mode = "o",               desc = "Remote Flash" },
      { "R",     function() require("flash").treesitter_search() end, mode = { "o", "x" },      desc = "Treesitter Search" },
      { "<c-s>", function() require("flash").toggle() end,            mode = "c",               desc = "Toggle Flash Search" },
    },
  },

  { "windwp/nvim-autopairs",      event = "InsertEnter", config = true },
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = true,
  },
  {
    "lewis6991/gitsigns.nvim",
    config = true,
    event = { "BufReadPre", "BufNewFile" },
    keys = {
      { "<leader>gd", "<cmd>Gitsigns diffthis HEAD~1<cr>", desc = "Diff vs prev commit" },
      { "<leader>gD", "<cmd>Gitsigns diffthis<cr>",        desc = "Diff vs index" },
      { "<leader>gb", "<cmd>Gitsigns blame_line<cr>",      desc = "Blame line" },
      { "<leader>gB", "<cmd>Gitsigns blame<cr>",           desc = "Blame buffer" },
    },
  },
  { "folke/which-key.nvim",       event = "VeryLazy",    config = true },
  { "echasnovski/mini.bufremove", config = true },
}
