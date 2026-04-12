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
          hl.FzfLuaNormal = { bg = "#000000" }
          hl.FzfLuaBorder = { bg = "#000000", fg = "#333333" }
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
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "File Explorer" },
    },
    config = function()
      require("neo-tree").setup({
        filesystem = {
          filtered_items = {
            visible = true,
            hide_dotfiles = false,
            hide_gitignored = false,
          },
        },
      })
      if vim.fn.argc() == 0 then
        vim.cmd("Neotree show")
      end
    end,
  },

  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>ff", "<cmd>FzfLua files<cr>",      desc = "Find files" },
      { "<leader>fg", "<cmd>FzfLua live_grep<cr>",  desc = "Live grep" },
      { "<leader>fb", "<cmd>FzfLua buffers<cr>",    desc = "Buffers" },
    },
    opts = {
      winopts = {
        border  = "single",
        preview = { border = "single" },
      },
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
      local lualine = require('lualine')

      -- stylua: ignore
      local colors = {
        bg       = '#000000',
        fg       = '#bbc2cf',
        yellow   = '#ECBE7B',
        cyan     = '#008080',
        darkblue = '#081633',
        green    = '#98be65',
        orange   = '#FF8800',
        violet   = '#a9a1e1',
        magenta  = '#c678dd',
        blue     = '#51afef',
        red      = '#ec5f67',
      }

      local conditions = {
        buffer_not_empty = function()
          return vim.fn.empty(vim.fn.expand('%:t')) ~= 1
        end,
        hide_in_width = function()
          return vim.fn.winwidth(0) > 80
        end,
        check_git_workspace = function()
          local filepath = vim.fn.expand('%:p:h')
          local gitdir = vim.fn.finddir('.git', filepath .. ';')
          return gitdir and #gitdir > 0 and #gitdir < #filepath
        end,
      }

      local config = {
        options = {
          component_separators = '',
          section_separators = '',
          theme = {
            normal   = { c = { fg = colors.fg, bg = colors.bg } },
            inactive = { c = { fg = colors.fg, bg = colors.bg } },
          },
        },
        sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_y = {},
          lualine_z = {},
          lualine_c = {},
          lualine_x = {},
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_y = {},
          lualine_z = {},
          lualine_c = {},
          lualine_x = {},
        },
      }

      local function ins_left(component)
        table.insert(config.sections.lualine_c, component)
      end

      local function ins_right(component)
        table.insert(config.sections.lualine_x, component)
      end

      ins_left {
        function() return '▊' end,
        color = { fg = colors.blue },
        padding = { left = 0, right = 1 },
      }

      ins_left {
        function() return '' end,
        color = function()
          local mode_color = {
            n  = colors.red,    i  = colors.green,  v = colors.blue,
            [''] = colors.blue, V  = colors.blue,   c = colors.magenta,
            no = colors.red,   s  = colors.orange,  S = colors.orange,
            [''] = colors.orange, ic = colors.yellow, R = colors.violet,
            Rv = colors.violet, cv = colors.red,   ce = colors.red,
            r  = colors.cyan,  rm = colors.cyan, ['r?'] = colors.cyan,
            ['!'] = colors.red, t  = colors.red,
          }
          return { fg = mode_color[vim.fn.mode()] }
        end,
        padding = { right = 1 },
      }

      ins_left { 'filesize', cond = conditions.buffer_not_empty }

      ins_left {
        'filename',
        cond  = conditions.buffer_not_empty,
        color = { fg = colors.magenta, gui = 'bold' },
      }

      ins_left { 'location' }

      ins_left { 'progress', color = { fg = colors.fg, gui = 'bold' } }

      ins_left {
        'diagnostics',
        sources = { 'nvim_diagnostic' },
        symbols = { error = ' ', warn = ' ', info = ' ' },
        diagnostics_color = {
          error = { fg = colors.red },
          warn  = { fg = colors.yellow },
          info  = { fg = colors.cyan },
        },
      }

      ins_left { function() return '%=' end }

      ins_left {
        function()
          local msg = 'No Active Lsp'
          local buf_ft = vim.api.nvim_get_option_value('filetype', { buf = 0 })
          local clients = vim.lsp.get_clients()
          if next(clients) == nil then return msg end
          for _, client in ipairs(clients) do
            local filetypes = client.config.filetypes
            if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
              return client.name
            end
          end
          return msg
        end,
        icon  = ' LSP:',
        color = { fg = '#ffffff', gui = 'bold' },
      }

      ins_right {
        'o:encoding',
        fmt   = string.upper,
        cond  = conditions.hide_in_width,
        color = { fg = colors.green, gui = 'bold' },
      }

      ins_right {
        'fileformat',
        fmt           = string.upper,
        icons_enabled = false,
        color         = { fg = colors.green, gui = 'bold' },
      }

      ins_right {
        'branch',
        icon  = '',
        color = { fg = colors.violet, gui = 'bold' },
      }

      ins_right {
        'diff',
        symbols = { added = ' ', modified = '󰝤 ', removed = ' ' },
        diff_color = {
          added    = { fg = colors.green },
          modified = { fg = colors.orange },
          removed  = { fg = colors.red },
        },
        cond = conditions.hide_in_width,
      }

      ins_right {
        function() return '▊' end,
        color   = { fg = colors.blue },
        padding = { left = 1 },
      }

      lualine.setup(config)
    end,
  },

  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "jay-babu/mason-nvim-dap.nvim",
    },
    keys = {
      { "<leader>db", "<cmd>DapToggleBreakpoint<cr>", desc = "Toggle breakpoint" },
      { "<leader>dc", "<cmd>DapContinue<cr>",         desc = "Continue" },
      { "<leader>di", "<cmd>DapStepInto<cr>",         desc = "Step into" },
      { "<leader>do", "<cmd>DapStepOver<cr>",         desc = "Step over" },
      { "<leader>dO", "<cmd>DapStepOut<cr>",          desc = "Step out" },
      { "<leader>dt", "<cmd>DapTerminate<cr>",        desc = "Terminate" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      require("mason-nvim-dap").setup({
        ensure_installed = { "codelldb" },
        automatic_installation = true,
      })

      dapui.setup()

      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"]     = function() dapui.close() end

      local codelldb_path = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb"

      dap.adapters.codelldb = {
        type    = "server",
        port    = "${port}",
        executable = { command = codelldb_path, args = { "--port", "${port}" } },
      }

      dap.configurations.rust = {
        {
          name    = "Launch",
          type    = "codelldb",
          request = "launch",
          program = function()
            local cwd = vim.fn.getcwd()
            -- walk up to find Cargo.toml if we're in a subdirectory
            local root = vim.fs.root(0, "Cargo.toml") or cwd
            return vim.fn.input("Binary: ", root .. "/target/debug/", "file")
          end,
          cwd            = function() return vim.fs.root(0, "Cargo.toml") or vim.fn.getcwd() end,
          stopOnEntry    = false,
        },
      }
    end,
  },

  { "windwp/nvim-autopairs",   event = "InsertEnter", config = true },
  { "numToStr/Comment.nvim",   event = "BufEnter",    config = true },
  { "lewis6991/gitsigns.nvim", config = true },
  { "folke/which-key.nvim",    event = "VeryLazy",    config = true },
}
