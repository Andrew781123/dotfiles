return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{ "mason-org/mason.nvim", opts = {} },
		"mason-org/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		-- Useful status updates for LSP.
		{ "j-hui/fidget.nvim", opts = {} },
		-- Allows extra capabilities provided by blink.cmp
		"saghen/blink.cmp",
	},
	config = function()
		local map = vim.keymap.set

		map("n", "gd", "<cmd>FzfLua lsp_definitions jump1=true ignore_current_line=true<cr>", {
			desc = "Goto Definition",
		})
		map("n", "gr", "<cmd>FzfLua lsp_references jump1=true ignore_current_line=true<cr>", {
			desc = "References",
			nowait = true,
		})
		map("n", "gI", "<cmd>FzfLua lsp_implementations jump1=true ignore_current_line=true<cr>", {
			desc = "Goto Implementation",
		})
		map("n", "gy", "<cmd>FzfLua lsp_typedefs jump1=true ignore_current_line=true<cr>", {
			desc = "Goto T[y]pe Definition",
		})

		-- Additional LSP keymaps
		map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })

		map("n", "<leader>cu", function()
			vim.lsp.buf.code_action({
				apply = true,
				context = {
					only = { "source.removeUnused.ts" },
					diagnostics = {},
				},
			})
		end, { desc = "Remove Unused Imports" })

		map("n", "<leader>ci", function()
			vim.lsp.buf.code_action({
				apply = true,
				context = {
					only = { "source.fixAll.eslint" },
					diagnostics = {},
				},
			})
		end, { desc = "Fix All ESLint Issues" })

		vim.diagnostic.config({
			severity_sort = true,
			float = { border = "rounded", source = "if_many" },
			underline = { severity = vim.diagnostic.severity.ERROR },
			signs = vim.g.have_nerd_font and {
				text = {
					[vim.diagnostic.severity.ERROR] = "󰅚 ",
					[vim.diagnostic.severity.WARN] = "󰀪 ",
					[vim.diagnostic.severity.INFO] = "󰋽 ",
					[vim.diagnostic.severity.HINT] = "󰌶 ",
				},
			} or {},
			virtual_text = {
				source = "if_many",
				spacing = 2,
				format = function(diagnostic)
					local diagnostic_message = {
						[vim.diagnostic.severity.ERROR] = diagnostic.message,
						[vim.diagnostic.severity.WARN] = diagnostic.message,
						[vim.diagnostic.severity.INFO] = diagnostic.message,
						[vim.diagnostic.severity.HINT] = diagnostic.message,
					}
					return diagnostic_message[diagnostic.severity]
				end,
			},
		})

		local capabilities = require("blink.cmp").get_lsp_capabilities()

		local servers = {
			lua_ls = {
				-- cmd = { ... },
				-- filetypes = { ... },
				-- capabilities = {},
				settings = {
					Lua = {
						completion = {
							callSnippet = "Replace",
						},
						-- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
						-- diagnostics = { disable = { 'missing-fields' } },
					},
				},
			},
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
			},
			eslint = {
				settings = {
					-- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
					workingDirectories = { mode = "auto" },
					format = auto_format,
				},
			},
		}

		local ensure_installed = vim.tbl_keys(servers or {})
		vim.list_extend(ensure_installed, {
			"stylua", -- Used to format Lua code
		})
		require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

		require("mason-lspconfig").setup({
			ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
			automatic_installation = false,
			handlers = {
				function(server_name)
					local server = servers[server_name] or {}
					-- This handles overriding only values explicitly passed
					-- by the server configuration above. Useful when disabling
					-- certain features of an LSP (for example, turning off formatting for ts_ls)
					server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
					require("lspconfig")[server_name].setup(server)
				end,
			},
		})
	end,
}
