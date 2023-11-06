-- import lualine plugin safely
local status, lualine = pcall(require, "lualine")
if not status then
	return
end

-- configure lualine with modified theme
lualine.setup({
	options = {
		theme = "catppuccin",
		always_divide_middle = false,
		globalstatus = true,
		section_separators = { left = "", right = "" },
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { { "filename", path = 3 }, "diff" },
		lualine_c = {},
		lualine_x = {},
		lualine_y = {
			{
				"diagnostics",
				always_visible = true,
				sources = { "nvim_lsp" },
				sections = { "error", "warn" },
			},
		},
		lualine_z = { "location" },
	},
	-- inactive_sections = {
	-- 	lualine_a = {},
	-- 	lualine_b = {},
	-- 	lualine_c = {},
	-- 	lualine_x = {},
	-- 	lualine_y = {},
	-- 	lualine_z = {},
	-- },
	-- tabline = {
	-- 	lualine_a = { { "tabs", mode = 2 } },
	-- 	lualine_b = {},
	-- 	lualine_c = {},
	-- 	lualine_x = {},
	-- 	lualine_y = {},
	-- 	lualine_z = {},
	-- },
})
