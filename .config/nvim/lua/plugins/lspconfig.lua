-- https://github.com/27medkamal/LazyVim/blob/391a6f97b51c24cdf2355f75d5180d016017c532/lua/lazyvim/plugins/extras/linting/eslint.lua
if lazyvim_docs then
  -- Set to false to disable auto format
  vim.g.lazyvim_eslint_auto_format = true
end

local auto_format = vim.g.lazyvim_eslint_auto_format == nil or vim.g.lazyvim_eslint_auto_format

return {
  "neovim/nvim-lspconfig",
  init = function()
    local keys = require("lazyvim.plugins.lsp.keymaps").get()
    keys[#keys + 1] = { "<leader>rn", vim.lsp.buf.rename, desc = "Rename" }
    keys[#keys + 1] = {
      "<leader>gi",
      function()
        require("telescope.builtin").lsp_implementations({ reuse_win = true })
      end,
      desc = "Goto Implementation",
    }
  end,
  opts = {
    inlay_hints = {
      enabled = false,
    },
    servers = {
      vtsls = {
        settings = {
          typescript = {
            preferences = {
              importModuleSpecifier = "non-relative",
            },
          },
        },
      },
    },
    setup = {
      eslint = function()
        if not auto_format then
          return
        end
      end,
    },
  },
}
