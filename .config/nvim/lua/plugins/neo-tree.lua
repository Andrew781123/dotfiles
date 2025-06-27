return {
  "nvim-neo-tree/neo-tree.nvim",
  lazy = true,
  enabled = false,
  opts = {
    filesystem = {
      bind_to_cwd = true,
      filtered_items = {
        hide_dotfiles = false,
        hide_gitignored = false,
      },
    },
    default_component_configs = {
      expander_collapsed = "›",
      expander_expanded = "‹",
    },
  },
  keys = {
    {
      "<leader>nE",
      function()
        local Util = require("lazyvim.util")
        require("neo-tree.command").execute({ toggle = true, dir = Util.root() })
      end,
      desc = "Explorer NeoTree (root dir)",
    },
    {
      "<leader>ne",
      function()
        require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() })
      end,
      desc = "Explorer NeoTree (cwd)",
    },
  },
}
