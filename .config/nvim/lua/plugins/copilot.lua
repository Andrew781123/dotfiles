return {
  "zbirenbaum/copilot.lua",
  build = ":Copilot auth",
  opts = {
    suggestion = { enabled = true },
    panel = { enabled = true },
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
}
