return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  opts = {
    ensure_installed = { "http", "json" },
    auto_install = true,
    ignore_install = { "prisma" },
    highlight = {
      disable = { "prisma" },
    },
  },
}
