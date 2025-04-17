return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    enabled = false,
    opts = {
      panel = {
        enabled = false,
        -- auto_refresh = false,
        -- keymap = {
        --   accept = "<CR>",
        --   jump_prev = "[[",
        --   jump_next = "]]",
        --   refresh = "gr",
        --   open = "<M-CR>",
        -- },
      },
      suggestion = {
        enabled = false,
        -- auto_trigger = true,
        -- debounce = 75,
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
