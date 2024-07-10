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
  },
}
