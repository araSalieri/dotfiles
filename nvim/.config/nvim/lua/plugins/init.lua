return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night",
        transparent = false,
        styles = { sidebars = "dark", floats = "dark" },
        on_highlights = function(hl, c)
          hl.Normal = { bg = "#000000", fg = c.fg }
          hl.NormalNC = { bg = "#000000" }
          hl.NormalFloat = { bg = "#000000" }
          hl.SignColumn = { bg = "#000000" }
          hl.CursorLine = { bg = "#0d0d0d" }
          hl.StatusLine = { bg = "#000000" }
          hl.StatusLineNC = { bg = "#000000" }
          hl.TabLine = { bg = "#000000" }
          hl.TabLineFill = { bg = "#000000" }
          hl.WinSeparator = { fg = "#333333", bg = "#000000" }
          hl.LineNr = { bg = "#000000" }
          hl.CursorLineNr = { bg = "#000000" }
          hl.EndOfBuffer = { bg = "#000000" }
          hl.Pmenu = { bg = "#0d0d0d" }
          hl.PmenuSel = { bg = "#1a1a1a" }
          hl.TelescopeNormal = { bg = "#000000" }
          hl.TelescopeBorder = { bg = "#000000", fg = "#333333" }
          hl.NeoTreeNormal = { bg = "#000000" }
          hl.NeoTreeNormalNC = { bg = "#000000" }
        end,
      })
      vim.cmd("colorscheme tokyonight-night")
    end,
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "File Explorer" },
    },
  },

  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.6",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",  desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",    desc = "Buffers" },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      ensure_installed = { "lua", "python", "typescript", "javascript", "rust", "go" },
      highlight = { enable = true },
      indent = { enable = true },
    },
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "pyright", "ts_ls", "rust_analyzer", "gopls" },
        automatic_installation = true,
      })
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = {
            normal   = { c = { fg = "#abb2bf", bg = "#000000" } },
            inactive = { c = { fg = "#555555", bg = "#000000" } },
          },
          component_separators = "",
          section_separators = "",
        },
      })
    end,
  },

  { "windwp/nvim-autopairs", event = "InsertEnter", config = true },
  { "numToStr/Comment.nvim", event = "BufEnter", config = true },
  { "lewis6991/gitsigns.nvim", config = true },
  { "folke/which-key.nvim", event = "VeryLazy", config = true },
}
