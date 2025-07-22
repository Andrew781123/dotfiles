return {
	"saghen/blink.cmp",
	lazy = true,
	dependencies = { "saghen/blink.compat", "supermaven-nvim" },
	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		fuzzy = {
			implementation = "lua",
		},
		snippets = {
			expand = function(snippet, _)
				return require("luasnip").lsp_expand(snippet.body)
			end,
		},
		completion = {
			menu = {
				auto_show = function(ctx)
					return ctx.mode ~= "cmdline"
				end,
				draw = {
					columns = { { "kind_icon" }, { "label", "label_description", gap = 1 } },
					treesitter = { "lsp" },
				},
			},
			accept = {
				auto_brackets = {
					enabled = false,
					kind_resolution = {
						enabled = false,
					},
					semantic_token_resolution = {
						enabled = false,
					},
				},
			},
			ghost_text = {
				enabled = vim.g.ai_cmp,
			},
		},

		-- experimental signature help support
		-- signature = { enabled = true },

		sources = {
			-- adding any nvim-cmp sources here will enable them
			-- with blink.compat
			compat = { "supermaven" },
			default = { "lsp", "path", "snippets", "buffer", "supermaven" },
			providers = {
				dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
				supermaven = {
					kind = "Supermaven",
					score_offset = 100,
					async = true,
				},
			},
		},

		cmdline = {
			enabled = false,
		},

		keymap = {
			preset = "enter",
			["<C-y>"] = { "select_and_accept" },
			["<C-j>"] = { "select_next", "fallback" },
			["<C-k>"] = { "select_prev", "fallback" },
			["<C-n>"] = { "show", "show_documentation", "hide_documentation" },
			["<CR>"] = { "accept", "fallback" },
		},

		appearance = {
			nerd_font_variant = "mono",
			kind_icons = {
				Copilot = "",
				Text = "󰉿",
				Method = "󰊕",
				Function = "󰊕",
				Constructor = "󰒓",
				Field = "󰜢",
				Variable = "󰆦",
				Property = "󰖷",
				Class = "󱡠",
				Interface = "󱡠",
				Struct = "󱡠",
				Module = "󰅩",
				Unit = "󰪚",
				Value = "󰦨",
				Enum = "󰦨",
				EnumMember = "󰦨",
				Keyword = "󰻾",
				Constant = "󰏿",
				Snippet = "󱄽",
				Color = "󰏘",
				File = "󰈔",
				Reference = "󰬲",
				Folder = "󰉋",
				Event = "󱐋",
				Operator = "󰪚",
				TypeParameter = "󰬛",
			},
		},
	},
}
