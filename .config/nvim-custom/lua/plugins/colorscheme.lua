return {
	{
		"catppuccin/nvim",
		lazy = true,
		name = "catppuccin",
		enabled = false,
		opts = {
			flavour = "mocha", -- latte, frappe, macchiato, mocha
			no_bold = true,
			no_italic = true,
			integrations = {
				blink_cmp = true,
				harpoon = true,
				snacks = true,
				mason = true,
				nvim_surround = true,
				which_key = true,
				lsp_trouble = true,
			},
		},
	},
	{
		"bluz71/vim-moonfly-colors",
		name = "moonfly",
		lazy = false,
		priority = 1000,
		config = function()
			-- Set to true to have the moonfly theme handle cursor color
			vim.g.moonflyCursorColor = true
			-- Enable italics for the moonfly theme
			vim.g.moonflyItalics = true
			-- Enable transparent background for the moonfly theme
			vim.g.moonflyTransparent = true
			-- Enable virtual text color for the moonfly theme
			vim.g.moonflyVirtualTextColor = true
			vim.cmd.colorscheme("moonfly")
		end,
	},
}
