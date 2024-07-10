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
