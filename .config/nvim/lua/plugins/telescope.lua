return {
  "nvim-telescope/telescope.nvim",
  opts = function()
    local actions = require("telescope.actions")
    return {
      defaults = {
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous, -- move to prev result
            ["<C-j>"] = actions.move_selection_next, -- move to next result
          },
          n = {
            ["q"] = actions.close,
          },
        },
      },
    }
  end,
  keys = function()
    local Util = require("lazyvim.util")

    return {
      { "<leader>fS", Util.telescope("live_grep"), desc = "Grep (root dir)" },
      { "<leader>fs", Util.telescope("live_grep", { cwd = false }), desc = "Grep (cwd)" },
      { "<leader>rff", "<cmd>Telescope resume<cr>", desc = "Resume" },
      { "<leader>fF", Util.telescope("files"), desc = "Find Files (root dir)" },
      { "<leader>ff", Util.telescope("files", { cwd = false }), desc = "Find Files (cwd)" },
      { "<leader>fw", Util.telescope("grep_string", { word_match = "-w" }), desc = "Word (root dir)" },
      -- git
      { "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "commits" },
      { "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "status" },
      -- others
      { "<leader>uC", Util.telescope("colorscheme", { enable_preview = true }), desc = "Colorscheme with preview" },
    }
  end,
}
