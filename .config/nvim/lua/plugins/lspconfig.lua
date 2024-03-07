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
    servers = {
      tailwindcss = {
        filetypes_exclude = { "markdown" },
      },
      tsserver = {
        keys = {
          {
            "<leader>co",
            function()
              vim.lsp.buf.code_action({
                apply = true,
                context = {
                  only = { "source.organizeImports.ts" },
                  diagnostics = {},
                },
              })
            end,
            desc = "Organize Imports",
          },
          {
            "<leader>cR",
            function()
              vim.lsp.buf.code_action({
                apply = true,
                context = {
                  only = { "source.removeUnused.ts" },
                  diagnostics = {},
                },
              })
            end,
            desc = "Remove Unused Imports",
          },
        },
        init_options = {
          preferences = {
            importModuleSpecifierPreference = "non-relative",
          },
        },
      },
    },
    setup = {
      tailwindcss = function(_, opts)
        local tw = require("lspconfig.server_configurations.tailwindcss")
        opts.filetypes = opts.filetypes or {}

        -- Add default filetypes
        vim.list_extend(opts.filetypes, tw.default_config.filetypes)

        -- Remove excluded filetypes
        --- @param ft string
        opts.filetypes = vim.tbl_filter(function(ft)
          return not vim.tbl_contains(opts.filetypes_exclude or {}, ft)
        end, opts.filetypes)

        -- Add additional filetypes
        vim.list_extend(opts.filetypes, opts.filetypes_include or {})
      end,
    },
  },
}
