return {
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
}
