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

    opts.diagnostics = {
      underline = true,
      update_in_insert = false,
      virtual_text = {
        spacing = 4,
        source = "if_many",
        prefix = "●",
        -- this will set set the prefix to a function that returns the diagnostics icon based on the severity
        -- this only works on a recent 0.10.0 build. Will be set to "●" when not supported
        -- prefix = "icons",
      },
      severity_sort = true,
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = LazyVim.config.icons.diagnostics.Error,
          [vim.diagnostic.severity.WARN] = LazyVim.config.icons.diagnostics.Warn,
          [vim.diagnostic.severity.HINT] = LazyVim.config.icons.diagnostics.Hint,
          [vim.diagnostic.severity.INFO] = LazyVim.config.icons.diagnostics.Info,
        },
      },
    }

    opts.inlay_hints = {
      enabled = false,
    }
    opts.servers = {
      tailwindcss = {
        -- exclude a filetype from the default_config
        filetypes_exclude = { "markdown" },
        -- add additional filetypes to the default_config
        filetypes_include = {},
        -- to fully override the default_config, change the below
        -- filetypes = {}
      },
      vtsls = {
        settings = {
          typescript = {
            preferences = {
              importModuleSpecifier = "non-relative",
              includePackageJsonAutoImports = "off",
              -- useAliasesForRenames = false,
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
        init_options = {
          codeAction = {
            preferred = { "quickfix", "source", "refactor" },
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
      typos_lsp = {
        init_options = {
          diagnosticSeverity = "Error",
        },
        filetypes = { "*" },
        on_attach = function(client, bufnr)
          -- Tell typos-lsp that everything is just text
          client.server_capabilities.semanticTokensProvider = nil
        end,
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

      tailwindcss = function(_, opts)
        local tw = LazyVim.lsp.get_raw_config("tailwindcss")
        opts.filetypes = opts.filetypes or {}

        -- Add default filetypes
        vim.list_extend(opts.filetypes, tw.default_config.filetypes)

        -- Remove excluded filetypes
        --- @param ft string
        opts.filetypes = vim.tbl_filter(function(ft)
          return not vim.tbl_contains(opts.filetypes_exclude or {}, ft)
        end, opts.filetypes)

        -- Additional settings for Phoenix projects
        opts.settings = {
          tailwindCSS = {
            experimental = {
              -- https://github.com/paolotiu/tailwind-intellisense-regex-list?tab=readme-ov-file#plain-javascript-object
              classRegex = {
                { "classes\\s*=\\s*\\{{([\\s\\S]*?)\\}}", "['\"`]([^'\"`]*)['\"`]" },
                { ":\\s*?[\"'`]([^\"'`]*).*?," },
              },
            },
            includeLanguages = {
              elixir = "html-eex",
              eelixir = "html-eex",
              heex = "html-eex",
            },
          },
        }

        -- Add additional filetypes
        vim.list_extend(opts.filetypes, opts.filetypes_include or {})
      end,
    }
  end,
}
