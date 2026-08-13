-- Oh My Pi (OMP) <-> Neovim bridge. Tracks the active buffer, cursor line, and
-- visual selection and broadcasts them to a running OMP terminal session so the
-- agent always knows what you're looking at. The OMP-side extension must also be
-- installed: `omp plugin install omp.nvim`. Verify with `:checkhealth omp`.
return {
  {
    "rauls-kjarners/omp.nvim",
    lazy = false,
    config = function()
      require("omp").setup()
    end,
  },
}
