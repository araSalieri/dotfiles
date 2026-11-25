-- Catppuccin with the noctalia garnet palette on pure black (defined inline below).
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = true,
        color_overrides = {
          mocha = {
            base = "#000000",
            mantle = "#000000",
            crust = "#000000",
            surface0 = "#181616",
            surface1 = "#2a2424",
            surface2 = "#3a3a3a",
            overlay0 = "#4a4242",
            overlay1 = "#5a5050",
            overlay2 = "#6a6060",
            subtext0 = "#7a7070",
            subtext1 = "#c4bcbc",
            text = "#e8e0e0",
            rosewater = "#f5eeee",
            flamingo = "#d64545",
            pink = "#c97fa0",
            mauve = "#d64545",
            red = "#d64545",
            maroon = "#b30000",
            peach = "#c8962a",
            yellow = "#e6c14d",
            green = "#7fc77f",
            teal = "#6fcaca",
            sky = "#6fcaca",
            sapphire = "#4aa3a3",
            blue = "#6fa3d4",
            lavender = "#c4bcbc",
          },
        },
        integrations = {
          gitsigns = true,
          snacks = true,
          treesitter = true,
          native_lsp = { enabled = true },
        },
        custom_highlights = function(c)
          local border = "#990000" -- noctalia primary, herdr's ui.accent and popup border
          return {
            Normal = { bg = "NONE", fg = c.text },
            NormalNC = { bg = "NONE" },
            NormalFloat = { bg = "NONE" },
            SignColumn = { bg = "NONE" },
            CursorLine = { bg = c.surface0 },
            StatusLine = { bg = "NONE" },
            StatusLineNC = { bg = "NONE" },
            TabLine = { bg = "NONE" },
            TabLineFill = { bg = "NONE" },
            WinSeparator = { bg = "NONE", fg = "#3a3a3a" },
            LineNr = { bg = "NONE" },
            CursorLineNr = { bg = "NONE" },
            EndOfBuffer = { bg = "NONE" },
            Pmenu = { bg = "NONE" },
            -- popups use herdr's colors: #2a2424 selection, primary prompt, red matches, dim dividers
            PmenuSel = { bg = "#2a2424" },
            SnacksPickerListCursorLine = { bg = "#2a2424" },
            SnacksPickerPrompt = { fg = border },
            SnacksPickerMatch = { fg = c.red, bold = true },
            SnacksPickerInputBorder = { fg = "#3a3a3a" },
            SnacksPickerPreviewBorder = { fg = "#3a3a3a" },
            FloatBorder = { bg = "NONE", fg = border },
            SnacksLazygitNormal = { bg = "NONE" },
            SnacksLazygitBorder = { bg = "NONE", fg = border },
            LazygitInactiveBorder = { fg = "#3a3a3a" },
          }
        end,
      })
      vim.cmd("colorscheme catppuccin")
    end,
  },
}
