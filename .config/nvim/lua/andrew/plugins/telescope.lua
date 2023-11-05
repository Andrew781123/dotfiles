-- import telescope plugin safely
local telescope_setup, telescope = pcall(require, "telescope")
if not telescope_setup then
	return
end

-- import telescope actions safely
local actions_setup, actions = pcall(require, "telescope.actions")
if not actions_setup then
	return
end

local builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>ff",function() builtin.find_files({ no_ignore = false }) end, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fs", builtin.live_grep, { desc = "Live Grep" })
-- vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = "Find Buffers"})
-- vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = "Find Help Tags"})
-- vim.keymap.set('n', '<leader>fs', builtin.lsp_document_symbols, { desc = "Find Symbols"})
-- vim.keymap.set('n', '<leader>fi', '<cmd>AdvancedGitSearch<CR>', { desc = "AdvancedGitSearch"})
vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Find Recent Files" })
vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "Find Word under Cursor" })
vim.keymap.set("n", "<leader>fgc", builtin.git_commits, { desc = "Search Git Commits" })
-- vim.keymap.set('n', '<leader>gb', builtin.git_bcommits, { desc = "Search Git Commits for Buffer"})

-- configure telescope
telescope.setup({
	-- configure custom mappings
	defaults = {
		file_ignore_patterns = {
			-- "node_modules",
			-- "generated",
		},
		mappings = {
			i = {
				["<C-k>"] = actions.move_selection_previous, -- move to prev result
				["<C-j>"] = actions.move_selection_next, -- move to next result
				["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist, -- send selected to quickfixlist
			},
		},
	},
})

telescope.load_extension("fzf")
