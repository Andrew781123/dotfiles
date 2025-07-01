return {
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
  },
  opts = {
    integrations = {
      diffview = true,
    },
  },
  keys = {
    {
      "<leader>gg",
      function()
        require("neogit").open()
      end,
      desc = "Neogit: Open Status",
    },
  },
}
