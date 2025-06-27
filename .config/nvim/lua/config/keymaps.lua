-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local keymap = vim.keymap

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>")

-- delete single character without copying into register
keymap.set("n", "x", '"_x')

keymap.set("n", "<leader>sv", "<C-w>v") -- split window vertically
keymap.set("n", "<leader>se", "<C-w>=") -- make split windows equal width & height
keymap.set("n", "<leader>sx", ":close<CR>") -- close current split window

keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true })
keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true })

keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")

keymap.set("n", "n", "nzzzv")
keymap.set("n", "N", "Nzzzv")

keymap.set("n", "zf", "za", { noremap = true, silent = true })

keymap.set("t", "<leader>N", "<C-\\><C-N>", { noremap = true, silent = true })

-- greatest remap ever
keymap.set("x", "<leader>p", [["_dP]])

keymap.set("n", "<leader>S", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- keymap.del("n", "<C-n>")
-- keymap.del("n", "<C-p>")

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
