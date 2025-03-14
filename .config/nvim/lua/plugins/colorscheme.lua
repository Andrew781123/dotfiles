return {
  {
    "catppuccin/nvim",
    lazy = true,
    name = "catppuccin",
    opts = {
      flavour = "mocha", -- latte, frappe, macchiato, mocha
      no_bold = true,
      no_italic = true,
      integrations = {
        blink_cmp = true,
        harpoon = true,
        snacks = true,
        mason = true,
        nvim_surround = true,
        which_key = true,
        lsp_trouble = true,
      },
    },
  },
  {
    "bluz71/vim-moonfly-colors",
    name = "moonfly",
    lazy = true,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "moonfly",
    },
  },
}
