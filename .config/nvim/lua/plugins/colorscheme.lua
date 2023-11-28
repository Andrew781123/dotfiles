return {
  {
    "rose-pine/neovim",
    lazy = true,
    name = "rose-pine",
  },
  { "ellisonleao/gruvbox.nvim", lazy = true },
  {
    "catppuccin/nvim",
    lazy = true,
    name = "catppuccin",
    opts = {
      no_bold = true,
      no_italic = true,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
