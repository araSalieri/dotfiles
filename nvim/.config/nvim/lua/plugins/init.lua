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
          hl.NeoTreeNormal = { bg = "NONE" }
          hl.NeoTreeNormalNC = { bg = "NONE" }
          hl.NeoTreeCursorLine = { bg = "#1a1a2e" }
          hl.SnacksLazygitNormal = { bg = "NONE" }
          hl.SnacksLazygitBorder = { bg = "NONE", fg = "#1a1a2e" }
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
      { "<leader>E", "<cmd>Neotree focus<cr>",  desc = "Focus File Explorer" },
    },
    config = function()
      local orig_autocmd = vim.api.nvim_create_autocmd
      vim.api.nvim_create_autocmd = function(evs, opts)
        local ok, err = pcall(orig_autocmd, evs, opts)
        if not ok then
          if type(err) == "string" and err:match("Invalid 'event'") then return end
          error(err, 2)
        end
      end
      require("neo-tree").setup({
        window = {
          position = "float",
          popup = {
            size = { height = "50%", width = "80%" },
            position = "50%",
            title = function() return "" end,
            border = { style = "rounded" },
          },
          mappings = {
            ["s"] = "none",
            ["S"] = "none",
            ["<space>"] = "none",
            ["<C-x>"] = "open_split",
            ["<C-v>"] = "open_vsplit",
          },
        },
        default_component_configs = {
          file_size = { enabled = false },
          type = { enabled = false },
          last_modified = { enabled = false },
          created = { enabled = false },
        },
        filesystem = {
          filtered_items = {
            visible = true,
            hide_dotfiles = false,
            hide_gitignored = false,
          },
          follow_current_file = { enabled = true },
          use_libuv_file_watcher = true,
        },
      })
    end,
  },

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

  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      ensure_installed = { "lua", "python", "typescript", "javascript", "rust", "go", "sql" },
      highlight = { enable = true },
      indent = { enable = true },
    },
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    config = function()
      require("mason").setup()
      require("mason-tool-installer").setup({
        ensure_installed = { "goimports", "prettier", "eslint_d" },
      })
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "pyright", "ts_ls", "rust_analyzer", "gopls", "eslint" },
        automatic_installation = true,
        handlers = {
          function(server_name)
            require("lspconfig")[server_name].setup({})
          end,
          ["pyright"] = function()
            require("lspconfig").pyright.setup({
              before_init = function(_, config)
                local venv = vim.fn.finddir(".venv", config.root_dir .. ";")
                if venv == "" then
                  venv = vim.fn.finddir("venv", config.root_dir .. ";")
                end
                if venv ~= "" then
                  config.settings = config.settings or {}
                  config.settings.python = config.settings.python or {}
                  config.settings.python.pythonPath = venv .. "/bin/python"
                end
              end,
            })
          end,
        },
      })

      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local map = function(key, fn, desc)
            vim.keymap.set("n", key, fn, { buffer = event.buf, desc = desc })
          end
          map("gd", vim.lsp.buf.definition, "Go to definition")
          map("gD", vim.lsp.buf.declaration, "Go to declaration")
          map("gr", vim.lsp.buf.references, "Go to references")
          map("gi", vim.lsp.buf.implementation, "Go to implementation")
          map("K", vim.lsp.buf.hover, "Hover documentation")
          map("gh", vim.lsp.buf.hover, "Hover documentation")
          map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          map("<leader>ca", vim.lsp.buf.code_action, "Code actions")
        end,
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
        bg       = 'NONE',
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
            n = colors.red,
            i = colors.green,
            v = colors.blue,
            [''] = colors.blue,
            V = colors.blue,
            c = colors.magenta,
            no = colors.red,
            s = colors.orange,
            S = colors.orange,
            [''] = colors.orange,
            ic = colors.yellow,
            R = colors.violet,
            Rv = colors.violet,
            cv = colors.red,
            ce = colors.red,
            r = colors.cyan,
            rm = colors.cyan,
            ['r?'] = colors.cyan,
            ['!'] = colors.red,
            t = colors.red,
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
      { "<leader>db", "<cmd>DapToggleBreakpoint<cr>",           desc = "Toggle breakpoint" },
      { "<leader>dc", "<cmd>DapContinue<cr>",                   desc = "Continue" },
      { "<leader>di", "<cmd>DapStepInto<cr>",                   desc = "Step into" },
      { "<leader>do", "<cmd>DapStepOver<cr>",                   desc = "Step over" },
      { "<leader>dO", "<cmd>DapStepOut<cr>",                    desc = "Step out" },
      { "<leader>dt", "<cmd>DapTerminate<cr>",                  desc = "Terminate" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      require("mason-nvim-dap").setup({
        ensure_installed = { "codelldb", "delve", "debugpy" },
        automatic_installation = true,
      })

      dapui.setup({
        layouts = {
          {
            elements = {
              { id = "scopes",      size = 0.25 },
              { id = "breakpoints", size = 0.15 },
              { id = "stacks",      size = 0.15 },
              { id = "watches",     size = 0.15 },
              { id = "console",     size = 0.15 },
              { id = "repl",        size = 0.15 },
            },
            size = 40,
            position = "right",
          },
        },
      })

      local codelldb_path                                   = vim.fn.stdpath("data") ..
          "/mason/packages/codelldb/extension/adapter/codelldb"

      dap.adapters.codelldb                                 = {
        type       = "server",
        port       = "${port}",
        executable = { command = codelldb_path, args = { "--port", "${port}" } },
      }

      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"]     = function() dapui.close() end

      dap.configurations.rust                               = {
        {
          name        = "Launch",
          type        = "codelldb",
          request     = "launch",
          program     = function()
            local cwd = vim.fn.getcwd()
            -- walk up to find Cargo.toml if we're in a subdirectory
            local root = vim.fs.root(0, "Cargo.toml") or cwd
            return vim.fn.input("Binary: ", root .. "/target/debug/", "file")
          end,
          cwd         = function() return vim.fs.root(0, "Cargo.toml") or vim.fn.getcwd() end,
          stopOnEntry = false,
        },
      }
    end,
  },

  {
    "ravsii/nvim-dap-envfile",
    version = "*",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("nvim-dap-envfile").setup({})
      local orig_notify = vim.notify
      vim.notify = function(msg, level, opts)
        if type(msg) == "string" and msg:find("Unexpected format", 1, true) then return end
        orig_notify(msg, level, opts)
      end
    end,
  },

  {
    "folke/snacks.nvim",
    lazy = false,
    priority = 900,
    opts = {
      lazygit = {
        enabled = true,
        win = { border = "rounded" },
        theme = {
          activeBorderColor          = { fg = "MatchParen", bold = true },
          inactiveBorderColor        = { fg = "FloatBorder" },
          searchingActiveBorderColor = { fg = "MatchParen", bold = true },
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

  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    keys = {
      { "<leader>ac", "<cmd>ClaudeCode<cr>",            desc = "Toggle Claude" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>",       desc = "Focus Claude" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>",   desc = "Resume Claude" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>",       desc = "Add current buffer to Claude" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>",        mode = "v",                           desc = "Send to Claude" },
      {
        "<leader>as",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file",
        ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
      },
    },
    opts = {
      terminal = {
        provider               = "external",
        provider_opts          = {
          external_terminal_cmd = "foot %s",
        },
        split_side             = "right",
        split_width_percentage = 0.2,
        auto_close             = true,
      },
      diff_opts = {
        layout = "vertical",
        keep_terminal_focus = true,
      },
    },
  },

  {
    "pittcat/claude-fzf.nvim",
    dependencies = {
      "ibhagwan/fzf-lua",
      "coder/claudecode.nvim"
    },
    opts = {
      logging = {
        level = "WARN",
        console_logging = true,
        file_logging = false,
      },
      notifications = {
        enabled = true,
        show_progress = false,
        show_success = false,
        show_errors = true,
        use_snacks = true,
      },
      auto_context = true,
      batch_size = 10,
      keymaps = {
        files = "<leader>cf",
        grep = "<leader>cg",
        buffers = "<leader>cb",
        git_files = "<leader>cgf",
        directory_files = "<leader>cd",
      },
      directory_search = {
        directories = {
          configs = {
            path = vim.fn.expand("~/.config"),
            extensions = { "lua", "vim", "json", "yaml" },
            description = "Config Files"
          },
          projects = {
            path = vim.fn.expand("~/projects"),
            extensions = { "md", "txt", "rst", "py", "js", "jsx", "ts", "tsx", "go", "rs" },
            description = "Projects "
          },
          obsidians = {
            path = vim.fn.expand("~/documents/obsidian"),
            extensions = { "md" },
            description = "Obsidian"
          }
        }
      },
    },
    cmd = { "ClaudeFzf", "ClaudeFzfFiles", "ClaudeFzfGrep", "ClaudeFzfBuffers", "ClaudeFzfGitFiles", "ClaudeFzfDirectory" },
    keys = {
      { "<leader>cf", "<cmd>ClaudeFzfFiles<cr>",     desc = "Claude: Add files" },
      { "<leader>cg", "<cmd>ClaudeFzfGrep<cr>",      desc = "Claude: Search and add" },
      { "<leader>cb", "<cmd>ClaudeFzfBuffers<cr>",   desc = "Claude: Add buffers" },
      { "<leader>cd", "<cmd>ClaudeFzfDirectory<cr>", desc = "Claude: Add directory files" },
    },
  },

  {
    'pittcat/claude-fzf-history.nvim',
    dependencies = { 'ibhagwan/fzf-lua' },
    config = function()
      require('claude-fzf-history').setup()
    end,
    cmd = { 'ClaudeHistory', 'ClaudeHistoryDebug' },
    keys = {
      { "<leader>ch", "<cmd>ClaudeHistory<cr>", desc = "Claude: Add history" },
    },
  },

  {
    "leoluz/nvim-dap-go",
    lazy = false,
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("dap-go").setup()
    end,
  },
  {
    "mfussenegger/nvim-dap-python",
    lazy = false,
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local mason_debugpy = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
      require("dap-python").setup(mason_debugpy)
      local dap = require("dap")
      dap.adapters.debugpy = dap.adapters.python
    end
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "rouge8/neotest-rust",
      "fredrikaverpil/neotest-golang",
      "nvim-neotest/neotest-python",
    },
    keys = {
      { "<leader>Tr", function() require("neotest").run.run() end,                     desc = "Run nearest test" },
      { "<leader>Tf", function() require("neotest").run.run(vim.fn.expand("%")) end,   desc = "Run file tests" },
      { "<leader>Ts", function() require("neotest").summary.toggle() end,              desc = "Toggle test summary" },
      { "<leader>To", function() require("neotest").output_panel.toggle() end,         desc = "Toggle test output" },
      { "<leader>Td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Debug nearest test" },
      { "<leader>TS", function() require("neotest").run.stop() end,                    desc = "Stop test" },
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-rust")({ args = { "--no-capture" } }),
          require("neotest-golang")({}),
          require("neotest-python"),
        },
        output_panel = {
          open = function()
            vim.cmd("botright vsplit")
            vim.cmd("vertical resize " .. math.floor(vim.o.columns * 0.2))
          end,
        },
      })
    end,
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = { "markdown", "Avante" },
    opts = {
      file_types = { "markdown", "Avante" },
    },
  },

  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      { "<leader>fm", function() require("conform").format({ async = true }) end, desc = "Format buffer" },
    },
    opts = {
      formatters_by_ft = {
        python          = { "ruff_format" },
        sql             = { "sql_formatter" },
        javascript      = { "eslint_d", "prettier" },
        typescript      = { "eslint_d", "prettier" },
        javascriptreact = { "eslint_d", "prettier" },
        typescriptreact = { "eslint_d", "prettier" },
        json            = { "prettier" },
        css             = { "prettier" },
        html            = { "prettier" },
      },
    },
  },

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
    },
  },
  { "folke/which-key.nvim",       event = "VeryLazy",    config = true },
  { "echasnovski/mini.bufremove", config = true },
}
