return {
  "folke/snacks.nvim",
  opts = {
    dashboard = {
      enabled = false,
      preset = {
        keys = {
          { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
        },
      },
      sections = {
        {
          section = "terminal",
          cmd = "/opt/homebrew/bin/chafa ~/Pictures/chill-guy.png --format symbols --size 50x50; sleep .1",
          height = 30,
        },
        {
          section = "terminal",
          cmd = "printf 'I am just a ChillGuy'",
        },
        {
          pane = 2,
          icon = " ",
          title = "Shortcuts",
          section = "keys",
          indent = 2,
          gap = 1,
          padding = 1,
        },
        {
          pane = 2,
          icon = " ",
          title = "Recent Files",
          section = "recent_files",
          limit = 10,
          indent = 2,
        },
        { section = "startup" },
      },
      width = 50,
    },
    scroll = { enabled = false },
    scope = { enabled = false },
    dim = { enabled = false },
    zen = { enabled = false },

    keys = {
      {
        "<leader>U",
        function()
          Snacks.picker.undo()
        end,
        desc = "Undo History",
      },
    },
  },
}
