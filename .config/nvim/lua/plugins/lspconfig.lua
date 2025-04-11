return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    local keys = require("lazyvim.plugins.lsp.keymaps").get()
    keys[#keys + 1] = { "<leader>rn", vim.lsp.buf.rename, desc = "Rename" }
    keys[#keys + 1] = {
      "<leader>cu",
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
    }
    keys[#keys + 1] = { "<c-k>", false, mode = "i" }

    keys[#keys + 1] = {
      "<leader>ci",
      function()
        vim.lsp.buf.code_action({
          apply = true,
          context = {
            only = { "source.fixAll.eslint" },
            diagnostics = {},
          },
        })
      end,
      desc = "Fix All ESLint Issues",
    }

    opts.inlay_hints = {
      enabled = false,
    }
    opts.servers = {
      vtsls = {
        settings = {
          typescript = {
            preferences = {
              importModuleSpecifier = "non-relative",
              includePackageJsonAutoImports = "off",
            },
            tsserver = {
              disableAutomaticTypingAcquisition = true, -- Skip fetching type defs for unused packages
              watchOptions = {
                watchFile = "useFsEvents", -- Faster file watching on supported systems
                watchDirectory = "useFsEvents",
                excludeDirectories = { "node_modules" }, -- Skip irrelevant dirs
              },
            },
            suggest = {
              maxCompletionCount = 50,
            },
          },
        },
      },
      eslint = {
        settings = {
          -- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
          workingDirectories = { mode = "auto" },
          format = auto_format,
        },
      },
    }

    opts.setup = {
      eslint = function()
        if not auto_format then
          return
        end

        local function get_client(buf)
          return LazyVim.lsp.get_clients({ name = "eslint", bufnr = buf })[1]
        end

        local formatter = LazyVim.lsp.formatter({
          name = "eslint: lsp",
          primary = false,
          priority = 200,
          filter = "eslint",
        })

        -- Use EslintFixAll on Neovim < 0.10.0
        if not pcall(require, "vim.lsp._dynamic") then
          formatter.name = "eslint: EslintFixAll"
          formatter.sources = function(buf)
            local client = get_client(buf)
            return client and { "eslint" } or {}
          end
          formatter.format = function(buf)
            local client = get_client(buf)
            client.flags = { allow_incremental_sync = false, debounce_text_changes = 1000, exit_timeout = 1500 }
            if client then
              local diag = vim.diagnostic.get(buf, { namespace = vim.lsp.diagnostic.get_namespace(client.id) })
              if #diag > 0 then
                vim.cmd("EslintFixAll")
              end
            end
          end
        end

        -- register the formatter with LazyVim
        LazyVim.format.register(formatter)
      end,
    }
  end,
}
