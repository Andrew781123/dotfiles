return {
	"saghen/blink.cmp",
	lazy = true,
	dependencies = { "saghen/blink.compat", "supermaven-inc/supermaven-nvim" },
	event = "InsertEnter",
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
		appearance = {
			-- sets the fallback highlight groups to nvim-cmp's highlight groups
			-- useful for when your theme doesn't support blink.cmp
			-- will be removed in a future release, assuming themes add support
			use_nvim_cmp_as_default = false,
			-- set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
			-- adjusts spacing to ensure icons are aligned
			nerd_font_variant = "mono",
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
				auto_brackets = {
					enabled = true,
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
			default = { "lsp", "path", "snippets", "buffer" },
			providers = {
				dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
				supermaven = {
					kind = "Supermaven",
					module = "supermaven-nvim",
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
