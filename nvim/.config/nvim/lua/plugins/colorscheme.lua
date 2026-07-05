return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night",
        transparent = true,
        styles = { sidebars = "transparent", floats = "transparent" },
        on_highlights = function(hl, c)
          hl.Normal = { bg = "NONE", fg = c.fg }
          hl.NormalNC = { bg = "NONE" }
          hl.NormalFloat = { bg = "NONE" }
          hl.SignColumn = { bg = "NONE" }
          hl.CursorLine = { bg = "#1a1b26" }
          hl.StatusLine = { bg = "NONE" }
          hl.StatusLineNC = { bg = "NONE" }
          hl.TabLine = { bg = "NONE" }
          hl.TabLineFill = { bg = "NONE" }
          hl.WinSeparator = { bg = "NONE", fg = "#1a1a2e" }
          hl.LineNr = { bg = "NONE" }
          hl.CursorLineNr = { bg = "NONE" }
          hl.EndOfBuffer = { bg = "NONE" }
          hl.Pmenu = { bg = "NONE" }
          hl.PmenuSel = { bg = "#1a1a1a" }
          hl.FzfLuaNormal = { bg = "NONE" }
          hl.FzfLuaBorder = { bg = "NONE", fg = "#1a1a2e" }
          hl.FloatBorder = { bg = "NONE", fg = "#9d7cd8" }
          hl.NeoTreeNormal = { bg = "NONE" }
          hl.NeoTreeNormalNC = { bg = "NONE" }
          hl.NeoTreeFloatBorder = { bg = "NONE", fg = "#9d7cd8" }
          hl.NeoTreeCursorLine = { bg = "#1a1a2e" }
          hl.SnacksLazygitNormal = { bg = "NONE" }
          hl.SnacksLazygitBorder = { bg = "NONE", fg = "#9d7cd8" }
        end,
      })
      vim.cmd("colorscheme tokyonight-night")
    end,
  },
}
