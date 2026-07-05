return {
  {
    "folke/snacks.nvim",
    lazy = false,
    priority = 900,
    opts = {
      lazygit = {
        enabled = true,
        win = { border = "rounded" },
        theme = {
          activeBorderColor          = { fg = "FloatBorder", bold = true },
          inactiveBorderColor        = { fg = "FloatBorder" },
          searchingActiveBorderColor = { fg = "FloatBorder", bold = true },
          optionsTextColor           = { fg = "Function" },
          selectedLineBgColor        = { bg = "Visual" },
          defaultFgColor             = { fg = "Normal" },
          unstagedChangesColor       = { fg = "DiagnosticError" },
          cherryPickedCommitFgColor  = { fg = "Function" },
          cherryPickedCommitBgColor  = { fg = "Identifier" },
        },
      },
    },
    keys = {
      { "<leader>gg", function() require("snacks").lazygit() end, desc = "Lazygit" },
    },
  },
}
