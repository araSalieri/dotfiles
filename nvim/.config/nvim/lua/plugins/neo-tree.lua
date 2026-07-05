return {
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
}
