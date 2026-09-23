-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local keymap = vim.keymap

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>")

-- git blame (moved from LazyVim default <leader>gb to free that for fzf git_branches)
keymap.set("n", "<leader>gB", function()
  require("gitsigns").blame_line({ full = true })
end, { desc = "Git Blame Line" })

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

-- copy file path / file:line range, for pasting into agents
local function yank_to_clipboard(text)
  if text == "" then
    return vim.notify("No file name", vim.log.levels.WARN)
  end
  vim.fn.setreg("+", text)
  vim.notify("Copied " .. text)
end

local function relpath()
  return vim.fn.expand("%:.")
end

keymap.set("n", "<leader>yp", function()
  yank_to_clipboard(relpath())
end, { desc = "Copy relative file path" })

keymap.set("x", "<leader>yl", function()
  local a, b = vim.fn.line("v"), vim.fn.line(".")
  if a > b then
    a, b = b, a
  end
  yank_to_clipboard(relpath() .. ":" .. (a == b and a or a .. "-" .. b))
end, { desc = "Copy relative file path:line range" })

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
