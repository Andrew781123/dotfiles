return {
  "mfussenegger/nvim-lint",
  enabled = false,
  optional = true,
  opts = {
    linters_by_ft = {
      javascript = { "eslint_d" },
      typescript = { "eslint_d" },
      typescriptreact = { "eslint_d" },
    },
  },
}
