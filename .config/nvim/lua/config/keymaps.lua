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
----
--vim.api.nvim_create_autocmd("TermOpen", {
--  pattern = "*",
--  callback = function()
--    vim.keymap.set("t", "<Esc>", "<C-\\><C-N>", { noremap = true, silent = true, buffer = 0 })
--  end,
--})

-- greatest remap ever
keymap.set("x", "<leader>p", [["_dP]])

keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- keymap.del("n", "<C-n>")
-- keymap.del("n", "<C-p>")

keymap.set("n", "<leader>mp", ":silent !prettier --stdin-filepath %<CR>", { silent = true })

keymap.set("i", "<Tab>", function()
  if require("copilot.suggestion").is_visible() then
    require("copilot.suggestion").accept()
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
  end
end, { desc = "Super Tab" })

-- Terminal toggle keybinding
keymap.set("n", "<leader>t", function()
  if vim.bo.buftype == "terminal" then
    vim.cmd("hide")
  else
    -- Find the most recent terminal buffer and open it in a vsplit
    local term_buf = nil
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.bo[buf].buftype == "terminal" and vim.fn.bufloaded(buf) == 1 then
        term_buf = buf
        break
      end
    end
    if term_buf then
      vim.cmd("vsplit | buffer " .. term_buf)
    else
      vim.cmd("vsplit | terminal")
    end
  end
end, { noremap = true, silent = true, desc = "Toggle terminal" })
