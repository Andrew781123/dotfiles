return {
  "folke/snacks.nvim",
  opts = {
    dashboard = { enabled = false },
    scroll = { enabled = false },
    scope = { enabled = false },
    dim = { enabled = false },
    zen = { enabled = false },
    image = { enabled = true },
  },
  keys = {
    {
      "<leader>su",
      function()
        require("snacks").picker.undo()
      end,
      desc = "Undo History",
    },
  },
}
