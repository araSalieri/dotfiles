return {
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
}
