return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        debounce = 75,
        keymap = {
          accept = false,
          accept_word = false,
          accept_line = false,
          next = "<C-]>",
          prev = "<C-[>",
        },
      },
      filetypes = {
        typescript = true,
        javascript = true,
        typescriptreact = true,
        javascriptreact = true,
        html = true,
        css = true,
        graphql = true,
        json = true,
        markdown = true,
        help = true,
      },
    },
  },
}
