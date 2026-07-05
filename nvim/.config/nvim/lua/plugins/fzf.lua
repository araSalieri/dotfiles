return {
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>ff", "<cmd>FzfLua files<cr>",        desc = "Find files" },
      { "<leader>fg", "<cmd>FzfLua live_grep<cr>",    desc = "Live grep" },
      { "<leader>fb", "<cmd>FzfLua buffers<cr>",      desc = "Buffers" },
      { "<leader>ft", "<cmd>FzfLua tabs<cr>",         desc = "Tabs" },
      { "<leader>fk", "<cmd>FzfLua keymaps<cr>",      desc = "Keymaps" },
      { "<leader>gc", "<cmd>FzfLua git_branches<cr>", desc = "Git branches" },
    },
    opts = {
      winopts = {
        border  = "single",
        preview = { border = "single" },
      },
    },
  },
}
