return {
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
          external_terminal_cmd = "foot fish -ic %s",
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
}
