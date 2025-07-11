return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    opts.formatters_by_ft = {
      javascript = { "prettierd", "prettier" },
      typescript = { "prettierd", "prettier" },
      javascriptreact = { "prettierd", "prettier" },
      typescriptreact = { "prettierd", "prettier" },
      svelte = { "prettierd", "prettier" },
      css = { "prettierd", "prettier" },
      html = { "prettierd", "prettier" },
      json = { "prettierd", "prettier" },
      yaml = { "prettierd", "prettier" },
      markdown = { "prettierd", "prettier" },
      graphql = { "prettierd", "prettier" },
      lua = { "stylua" },
      fish = { "fish_indent" },
      sh = { "shfmt" },
      prisma = { "prisma_format" },
    }

    opts.formatters = {
      prisma_format = {
        command = "npx",
        args = { "prisma", "format", "--schema", "$FILENAME" },
        stdin = false,
      },
    }

    opts.default_format_opts = { timeout_ms = 10000 }
  end,
}
