return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	main = "nvim-treesitter.configs", -- Sets main module to use for opts
	---@type TSConfig
	---@diagnostic disable-next-line: missing-fields
	opts = {
		auto_install = true,
		highlight = { enable = true },
		indent = { enable = true },
		ensure_installed = {
			"bash",
			"c",
			"diff",
			"html",
			"http",
			"javascript",
			"jsdoc",
			"json",
			"jsonc",
			"lua",
			"luadoc",
			"luap",
			"markdown",
			"markdown_inline",
			"printf",
			"python",
			"query",
			"regex",
			"toml",
			"tsx",
			"typescript",
			"vim",
			"vimdoc",
			"xml",
			"yaml",
		},
	},
}
