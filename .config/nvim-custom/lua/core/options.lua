-- See `:help vim.o` for details on options
local opt = vim.opt

-- ┌────────────────────────────────────────────────────────────────────────┐
-- │ Appearance                                                             │
-- └────────────────────────────────────────────────────────────────────────┘
-- Set to true to have the moonfly theme handle cursor color
vim.g.moonflyCursorColor = true
vim.g.moonflyItalics = true
vim.g.moonflyTransparent = true
vim.g.moonflyVirtualTextColor = true
opt.termguicolors = true

-- Line numbers
opt.number = true
opt.relativenumber = true

-- UI elements
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.signcolumn = "yes"
opt.cursorline = true
opt.laststatus = 3 -- global statusline
opt.showmode = false
opt.ruler = false
opt.list = true -- Show some invisible characters
opt.conceallevel = 2
opt.pumblend = 10
opt.pumheight = 10
opt.winminwidth = 5
opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}

-- Wrapping and display
opt.wrap = true
opt.linebreak = true -- Wrap lines at convenient points

-- ┌────────────────────────────────────────────────────────────────────────┐
-- │ Behavior                                                               │
-- └────────────────────────────────────────────────────────────────────────┘
-- Searching
opt.hlsearch = false
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- File handling
opt.autoread = true
opt.autowrite = true
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undodir"
opt.undolevels = 10000
opt.confirm = true -- Confirm to save changes before exiting

-- Clipboard
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"

-- Window management
opt.splitbelow = true
opt.splitright = true
opt.splitkeep = "screen"

-- Other behaviors
opt.mouse = "a"
opt.completeopt = "menu,menuone,noselect"
opt.inccommand = "nosplit"
opt.jumpoptions = "view"
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.virtualedit = "block"
opt.wildmode = "longest:full,full"
opt.grepprg = "rg --vimgrep"
opt.grepformat = "%f:%l:%c:%m"
opt.spelllang = { "en" }

-- ┌────────────────────────────────────────────────────────────────────────┐
-- │ Indentation and Tabs                                                   │
-- └────────────────────────────────────────────────────────────────────────┘
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true
opt.shiftround = true
opt.formatoptions = "jcroqlnt"

-- ┌────────────────────────────────────────────────────────────────────────┐
-- │ Folding                                                                │
-- └────────────────────────────────────────────────────────────────────────┘
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99

-- ┌────────────────────────────────────────────────────────────────────────┐
-- │ Diagnostics, LSP, and Formatting                                       │
-- └────────────────────────────────────────────────────────────────────────┘
vim.diagnostic.config({ virtual_text = false })
vim.lsp.set_log_level("off")
vim.g.markdown_recommended_style = 0
-- This is a LazyVim-specific utility. You might need to implement your own
-- formatting function if you are not using LazyVim's utilities.
-- opt.formatexpr = "v:lua.require'lazyvim.util'.format.formatexpr()"

-- ┌────────────────────────────────────────────────────────────────────────┐
-- │ Performance                                                            │
-- └────────────────────────────────────────────────────────────────────────┘
opt.timeoutlen = 300
opt.updatetime = 200
