return {
  {
    "folke/snacks.nvim",
    lazy = false,
    priority = 900,
    opts = {
      lazygit = {
        enabled = true,
        win = { border = true }, -- outer border like other snacks floats; honors vim.o.winborder
        theme = {
          activeBorderColor          = { fg = "FloatBorder", bold = true },
          inactiveBorderColor        = { fg = "LazygitInactiveBorder" },
          searchingActiveBorderColor = { fg = "FloatBorder", bold = true },
          optionsTextColor           = { fg = "Function" },
          selectedLineBgColor        = { bg = "Visual" },
          defaultFgColor             = { fg = "Normal" },
          unstagedChangesColor       = { fg = "DiagnosticError" },
          cherryPickedCommitFgColor  = { fg = "Function" },
          cherryPickedCommitBgColor  = { fg = "Identifier" },
        },
      },
      explorer = {
        replace_netrw = true, -- default; explicit because it changes nvim <dir> behavior
        trash = true,         -- default; CachyOS has gio
      },
      picker = {
        sources = {
          explorer = {
            hidden = true,   -- old neo-tree had hide_dotfiles = false
            ignored = true,  -- old neo-tree had hide_gitignored = false
            jump = { close = true }, -- float closes when a file is opened
            layout = { preset = "default", preview = true },
          },
          files = {
            hidden = true, -- fd --hidden: dot-dirs (.config, .omp, ...) included; .git still excluded
          },
          grep = {
            hidden = true, -- rg --hidden: dot-dirs searched; .git still excluded via --glob=!.git
          },
        },
      },
    },
    keys = {
      { "<leader>gg", function() require("snacks").lazygit() end, desc = "Lazygit" },
      { "<leader>e", function() require("snacks").explorer() end, desc = "File Explorer" },
      { "<leader>E", function() require("snacks").explorer.reveal() end, desc = "Reveal File in Explorer" },
      { "<leader>ff", function() require("snacks").picker.files() end, desc = "Find files" },
      { "<leader>fg", function() require("snacks").picker.grep() end, desc = "Live grep" },
      { "<leader>fb", function() require("snacks").picker.buffers() end, desc = "Buffers" },
      { "<leader>fk", function() require("snacks").picker.keymaps() end, desc = "Keymaps" },
      { "<leader>gc", function() require("snacks").picker.git_branches() end, desc = "Git branches" },
    },
  },
}
