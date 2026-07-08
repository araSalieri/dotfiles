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
    opts = function()
      return {
        winopts = {
          border  = "single",
          preview = { border = "single" },
        },
        actions = {
          files = {
            ["enter"]  = require("fzf-lua").actions.file_edit_or_qf,
            ["ctrl-x"] = require("fzf-lua").actions.file_split,
            ["ctrl-v"] = require("fzf-lua").actions.file_vsplit,
            ["ctrl-t"] = require("fzf-lua").actions.file_tabedit,
          },
        },
      }
    end,
  },
}
