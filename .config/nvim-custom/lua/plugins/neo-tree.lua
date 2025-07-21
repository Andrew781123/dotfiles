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
        local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
        git_root = vim.trim(git_root or "")
        local root_dir = git_root ~= "" and git_root or vim.fn.getcwd()
        require("neo-tree.command").execute({ toggle = true, dir = root_dir })
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
