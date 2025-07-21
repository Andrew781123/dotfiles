local map = LazyVim.safe_keymap_set
local keymap = vim.keymap

-- ┌────────────────────────────────────────────────────────────────────────┐
-- │ Editor Navigation                                                      │
-- └────────────────────────────────────────────────────────────────────────┘

-- better up/down
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- Center screen on half-page jumps
keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true })
keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true })

-- Center screen on search next/previous
keymap.set("n", "n", "nzzzv")
keymap.set("n", "N", "Nzzzv")

-- ┌────────────────────────────────────────────────────────────────────────┐
-- │ Window Management                                                      │
-- └────────────────────────────────────────────────────────────────────────┘

-- Move to window using the <ctrl> hjkl keys
map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- Window splitting
keymap.set("n", "<leader>sv", "<C-w>v") -- split window vertically
keymap.set("n", "<leader>se", "<C-w>=") -- make split windows equal width & height
keymap.set("n", "<leader>sx", ":close<CR>") -- close current split window

-- ┌────────────────────────────────────────────────────────────────────────┐
-- │ Text Manipulation                                                      │
-- └────────────────────────────────────────────────────────────────────────┘

-- delete single character without copying into register
keymap.set("n", "x", "\"_x")

-- greatest remap ever
keymap.set("x", "<leader>p", [["_dP]])

-- Move selected lines up/down in visual mode
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Replace all occurrences of the word under the cursor
keymap.set("n", "<leader>S", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- ┌────────────────────────────────────────────────────────────────────────┐
-- │ Folds                                                                  │
-- └────────────────────────────────────────────────────────────────────────┘

-- Toggle fold
keymap.set("n", "zf", "za", { noremap = true, silent = true })

-- ┌────────────────────────────────────────────────────────────────────────┐
-- │ Terminal                                                               │
-- └────────────────────────────────────────────────────────────────────────┘

-- Terminal toggle keybinding
keymap.set("n", "<leader>t", function()
	local term_buf = vim.tbl_get(vim.b, "terminal_buf")
	if
		term_buf
		and vim.api.nvim_buf_is_valid(term_buf)
		and vim.api.nvim_buf_get_option(term_buf, "buftype") == "terminal"
	then
		vim.api.nvim_set_current_buf(term_buf)
		vim.cmd("hide")
	else
		vim.cmd("vsplit | terminal")
		vim.b.terminal_buf = vim.api.nvim_get_current_buf()
	end
end, { noremap = true, silent = true, desc = "Toggle terminal" })

-- Switch to normal mode in terminal
keymap.set("t", "<leader>N", "<C-\\><C-N>", { noremap = true, silent = true })

-- ┌────────────────────────────────────────────────────────────────────────┐
-- │ Plugins                                                                │
-- └────────────────────────────────────────────────────────────────────────┘

-- lazy
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- Clear search and stop snippet on escape
map({ "i", "n", "s" }, "<esc>", function()
	vim.cmd("noh")
	LazyVim.cmp.actions.snippet_stop()
	return "<esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })

-- ┌────────────────────────────────────────────────────────────────────────┐
-- │ Diagnostics & Quickfix                                                 │
-- └────────────────────────────────────────────────────────────────────────┘

-- quickfix list
map("n", "<leader>xq", function()
	local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
	if not success and err then
		vim.notify(err, vim.log.levels.ERROR)
	end
end, { desc = "Quickfix List" })

map("n", "[q", vim.cmd.cprev, { desc = "Previous Quickfix" })
map("n", "]q", vim.cmd.cnext, { desc = "Next Quickfix" })

-- diagnostic
local diagnostic_goto = function(next, severity)
	local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
	severity = severity and vim.diagnostic.severity[severity] or nil
	return function()
		go({ severity = severity })
	end
end
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
map("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })