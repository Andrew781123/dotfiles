-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt
opt.wrap = true

opt.hlsearch = false
opt.incsearch = true
opt.autoread = true
opt.relativenumber = true
vim.diagnostic.config({ virtual_text = false })
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldmethod = "expr"

opt.spell = true
opt.spelllang = "en_us"
opt.spelloptions = "camel"

opt.swapfile = false
opt.backup = false
opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
opt.undofile = true

opt.scrolloff = 8

vim.fn.setreg("l", 'yoconsole.log({"^[p^[lli: ^[p^[A;^[hhi, q<80>kb^[')

vim.g.moonflyCursorColor = true
vim.g.moonflyItalics = true
vim.g.moonflyTransparent = true
vim.g.moonflyVirtualTextColor = true
opt.termguicolors = true
