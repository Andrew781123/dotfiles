return {
  "nvimdev/dashboard-nvim",
  theme = "hyper",
  opts = function(_, opts)
    return {
      hide = {
        statusline = false,
      },
      config = {
        week_header = {
          enable = true,
        },
        project = { enable = false },
        shortcut = {
          { desc = "󰊳 Update", group = "@property", action = "Lazy update", key = "u" },
        },
      },
    }
  end,
}
