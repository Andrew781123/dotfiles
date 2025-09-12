-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt
opt.wrap = true

opt.hlsearch = false
opt.incsearch = true
opt.autoread = true
opt.relativenumber = true
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldmethod = "expr"

opt.swapfile = false
opt.backup = false
opt.undodir = vim.fn.stdpath("data") .. "/undodir"
opt.undofile = true

opt.scrolloff = 8

vim.g.moonflyCursorColor = true
vim.g.moonflyItalics = true
vim.g.moonflyTransparent = true
vim.g.moonflyVirtualTextColor = true
opt.termguicolors = true

vim.lsp.set_log_level("off")

vim.diagnostic.config({
  virtual_text = false,
  severity_sort = true,
})
