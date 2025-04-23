return {
  "nvimdev/dashboard-nvim",
  event = "VimEnter",
  enabled = false,
  opts = {
    theme = "hyper",
    hide = { statusline = false },
    config = {
      week_header = { enable = true },
      project = { enable = false },
      shortcut = {
        { desc = "󰊳 Update", group = "@property", action = "Lazy update", key = "u" },
      },
    },
  },
  dependencies = { "nvim-tree/nvim-web-devicons" },
}
