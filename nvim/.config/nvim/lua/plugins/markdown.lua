return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = { "markdown", "Avante" },
    opts = {
      file_types = { "markdown", "Avante" },
      latex = { enabled = false }, -- needs external latex binary; injection crashes without it
    },
  },

  {
    "selimacerbas/markdown-preview.nvim",
    dependencies = { "selimacerbas/live-server.nvim" },
    ft = { "markdown" },
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreview<cr>",     ft = "markdown", desc = "Markdown Preview" },
      { "<leader>mr", "<cmd>MarkdownPreviewRefresh<cr>", ft = "markdown", desc = "Markdown Preview Refresh" },
      { "<leader>ms", "<cmd>MarkdownPreviewStop<cr>", ft = "markdown", desc = "Markdown Preview Stop" },
    },
    config = function()
      require("markdown_preview").setup({
        instance_mode = "takeover",
        port = 0,
        open_browser = true,
        default_theme = "dark",
        debounce_ms = 300,
      })
    end,
  },
}
