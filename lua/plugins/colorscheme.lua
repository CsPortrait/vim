return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    opts = {
      transparent = true,
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd([[colorscheme tokyonight-storm]])
    end,
  },
}
