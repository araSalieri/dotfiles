return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main", -- master is deprecated and crashes on nvim 0.11+ (see git log)
    lazy = false,
    build = ":TSUpdate",
    config = function()
      -- parsers to keep installed (async; :wait bootstraps on first run)
      local parsers = {
        "lua", "python", "typescript", "javascript", "rust", "go", "sql",
        "markdown", "markdown_inline", "html",
      }
      require("nvim-treesitter").install(parsers)

      -- highlight + indent are opt-in per buffer on the main branch
      local filetypes = { "lua", "python", "typescript", "javascript", "rust", "go", "sql", "markdown", "html" }
      vim.api.nvim_create_autocmd("FileType", {
        pattern = filetypes,
        callback = function()
          pcall(vim.treesitter.start)
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
}
