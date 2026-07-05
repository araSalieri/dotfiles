return {
  {
    "rmagatti/auto-session",
    lazy = false,
    opts = {
      suppressed_dirs = { "~/", "~/Downloads", "/" },
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
