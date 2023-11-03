local status, catppuccin = pcall(require, "catppuccin")
if not status then
	print("Colorscheme not found!") -- print error if colorscheme not installed
	return
end

catppuccin.setup({
	term_colors = true,
	no_italic = true,
	integrations = {
		cmp = true,
		gitsigns = true,
		nvimtree = true,
		treesitter = true,
		notify = false,
		mini = {
			enabled = true,
			indentscope_color = "",
		},
		-- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
	},
})

local status, _ = pcall(vim.cmd, "colorscheme catppuccin")

if not status then
	print("Colorscheme not found!") -- print error if colorscheme not installed
	return
end
