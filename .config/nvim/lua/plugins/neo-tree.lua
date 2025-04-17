return {
  "nvim-neo-tree/neo-tree.nvim",
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
      "<leader>fE",
      function()
        local Util = require("lazyvim.util")
        require("neo-tree.command").execute({ toggle = true, dir = Util.root() })
      end,
      desc = "Explorer NeoTree (root dir)",
    },
    {
      "<leader>fe",
      function()
        require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() })
      end,
      desc = "Explorer NeoTree (cwd)",
    },
    { "<leader>E", "<leader>fE", desc = "Explorer NeoTree (root dir)", remap = true },
    { "<leader>e", "<leader>fe", desc = "Explorer NeoTree (cwd)", remap = true },
  },
}
