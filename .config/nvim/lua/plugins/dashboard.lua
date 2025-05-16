return {
  "nvimdev/dashboard-nvim",
  event = "VimEnter",
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
}
