return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "jay-babu/mason-nvim-dap.nvim",
      "theHamsta/nvim-dap-virtual-text",
    },
    keys = {
      { "<leader>db", "<cmd>DapToggleBreakpoint<cr>",                              desc = "Toggle breakpoint" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end, desc = "Conditional breakpoint" },
      { "<leader>dc", "<cmd>DapContinue<cr>",                                      desc = "Continue" },
      { "<leader>di", "<cmd>DapStepInto<cr>",                                      desc = "Step into" },
      { "<leader>do", "<cmd>DapStepOver<cr>",                                      desc = "Step over" },
      { "<leader>dO", "<cmd>DapStepOut<cr>",                                       desc = "Step out" },
      { "<leader>dr", function() require("dap").run_last() end,                    desc = "Run last" },
      { "<leader>dt", "<cmd>DapTerminate<cr>",                                     desc = "Terminate" },
      { "<leader>de", function() require("dapui").eval() end,                      desc = "Eval", mode = { "n", "v" } },
      { "<leader>du", function() require("dapui").toggle() end,                    desc = "Toggle DAP UI" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      require("mason-nvim-dap").setup({
        ensure_installed = { "codelldb", "delve", "debugpy" },
        automatic_installation = true,
      })

      require("nvim-dap-virtual-text").setup({
        virt_text_pos = "eol",      -- value shown at end of line, not after the variable
        only_first_definition = true, -- annotate the definition, not every use
        all_references = false,     -- skip usage sites — kills the struct-dump spam
        display_callback = function(variable, _, _, _, options)
          local val = variable.value:gsub("%s+", " ")
          if #val > 40 then val = val:sub(1, 39) .. "…" end
          if options.virt_text_pos == "inline" then
            return " = " .. val
          end
          return variable.name .. " = " .. val
        end,
      })

      dapui.setup({
        -- icons/controls use dapui's built-in nerd defaults (render fine)
        controls = { enabled = true, element = "repl" },
        layouts = {
          {
            -- bottom tray: rest in columns, one short row-block
            elements = {
              { id = "watches",     size = 0.21 },
              { id = "stacks",      size = 0.26 },
              { id = "breakpoints", size = 0.18 },
              { id = "repl",        size = 0.35 },
            },
            size = 10,
            position = "bottom",
          },
          {
            -- bottom tray: scopes only (own row, on top)
            elements = {
              { id = "scopes", size = 1.0 },
            },
            size = 10,
            position = "bottom",
          },
        },
        floating = { border = "rounded", mappings = { close = { "q", "<Esc>" } } },
        expand_lines = true,
        render = { indent = 1, max_value_lines = 100 },
      })

      -- breakpoint gutter signs (UTF-8 byte escapes so glyphs survive edits)
      vim.fn.sign_define("DapBreakpoint",          { text = "\xe2\x97\x8f", texthl = "DiagnosticError", linehl = "", numhl = "" })       -- ●
      vim.fn.sign_define("DapBreakpointCondition", { text = "\xe2\x97\x86", texthl = "DiagnosticWarn",  linehl = "", numhl = "" })       -- ◆
      vim.fn.sign_define("DapBreakpointRejected",  { text = "\xe2\x97\x8b", texthl = "DiagnosticHint",  linehl = "", numhl = "" })       -- ○
      vim.fn.sign_define("DapLogPoint",            { text = "\xe2\x97\x87", texthl = "DiagnosticInfo",  linehl = "", numhl = "" })       -- ◇
      vim.fn.sign_define("DapStopped",             { text = "\xe2\x96\xb6", texthl = "DiagnosticOk",    linehl = "Visual", numhl = "" }) -- ▶

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
}
