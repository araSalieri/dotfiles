return {
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
      "TmuxNavigatorProcessList",
    },
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
      { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
      -- exit terminal mode first, then navigate (crosses into tmux panes at edges)
      { "<c-h>", "<C-\\><C-n><cmd>TmuxNavigateLeft<cr>", mode = "t" },
      { "<c-j>", "<C-\\><C-n><cmd>TmuxNavigateDown<cr>", mode = "t" },
      { "<c-k>", "<C-\\><C-n><cmd>TmuxNavigateUp<cr>", mode = "t" },
      { "<c-l>", "<C-\\><C-n><cmd>TmuxNavigateRight<cr>", mode = "t" },
    },
  },
}
