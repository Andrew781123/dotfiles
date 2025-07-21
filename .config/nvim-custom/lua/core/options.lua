-- See `:help vim.o` for details on options
local opt = vim.opt

-- ┌────────────────────────────────────────────────────────────────────────┐
-- │ Appearance                                                             │
-- └────────────────────────────────────────────────────────────────────────┘
-- Enable 24-bit RGB color
opt.termguicolors = true

-- Line numbers
-- Show line numbers
opt.number = true
-- Show relative line numbers
opt.relativenumber = true

-- UI elements
-- Keep 8 lines of context around the cursor
opt.scrolloff = 8
-- Keep 8 columns of context around the cursor
opt.sidescrolloff = 8
-- Always show the sign column
opt.signcolumn = "yes"
-- Highlight the current line
opt.cursorline = true
-- Always show a global statusline
opt.laststatus = 3 -- global statusline
-- Do not show the mode in the command line
opt.showmode = false
-- Do not show the ruler
opt.ruler = false
-- Show invisible characters
opt.list = true -- Show some invisible characters
-- Set conceal level for markdown, etc.
opt.conceallevel = 2
-- Set transparency for the popup menu
opt.pumblend = 10
-- Set the height of the popup menu
opt.pumheight = 10
-- Set the minimum width of a window
opt.winminwidth = 5
-- Set characters for various UI elements
opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}

-- Wrapping and display
-- Enable line wrapping
opt.wrap = true
-- Wrap lines at word boundaries
opt.linebreak = true -- Wrap lines at convenient points

-- ┌────────────────────────────────────────────────────────────────────────┐
-- │ Behavior                                                               │
-- └────────────────────────────────────────────────────────────────────────┘
-- Searching
-- Do not highlight search results by default
opt.hlsearch = false
-- Show incremental search results
opt.incsearch = true
-- Ignore case when searching
opt.ignorecase = true
-- Use smart case when searching
opt.smartcase = true

-- File handling
-- Automatically read a file when it has been changed outside of Vim
opt.autoread = true
-- Automatically write a file when leaving a buffer
opt.autowrite = true
-- Do not create a swap file
opt.swapfile = false
-- Do not create a backup file
opt.backup = false
-- Enable persistent undo
opt.undofile = true
-- Set the directory for undo files
opt.undodir = vim.fn.stdpath("data") .. "/undodir"
-- Set the number of undo levels
opt.undolevels = 10000
-- Confirm to save changes before exiting
opt.confirm = true -- Confirm to save changes before exiting

-- Clipboard
-- Use the system clipboard
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"

-- Window management
-- Split windows below the current window
opt.splitbelow = true
-- Split windows to the right of the current window
opt.splitright = true
-- Keep the screen when splitting
opt.splitkeep = "screen"

-- Other behaviors
-- Enable mouse support
opt.mouse = "a"
-- Set completion options
opt.completeopt = "menu,menuone,noselect"
-- Set the command for incremental commands
opt.inccommand = "nosplit"
-- Set jump options
opt.jumpoptions = "view"
-- Set session options
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
-- Set short message options
opt.shortmess:append({ W = true, I = true, c = true, C = true })
-- Allow the cursor to move into virtual space in block mode
opt.virtualedit = "block"
-- Set wild mode options
opt.wildmode = "longest:full,full"
-- Set the program to use for grep
opt.grepprg = "rg --vimgrep"
-- Set the format for grep
opt.grepformat = "%f:%l:%c:%m"
-- Set the spell language
opt.spelllang = { "en" }

-- ┌────────────────────────────────────────────────────────────────────────┐
-- │ Indentation and Tabs                                                   │
-- └────────────────────────────────────────────────────────────────────────┘
-- Set the number of spaces for a tab
opt.tabstop = 2
-- Set the number of spaces for indentation
opt.shiftwidth = 2
-- Use spaces instead of tabs
opt.expandtab = true
-- Enable auto-indentation
opt.autoindent = true
-- Enable smart indentation
opt.smartindent = true
-- Round indentation to the nearest shiftwidth
opt.shiftround = true
-- Set format options
opt.formatoptions = "jcroqlnt"

-- ┌────────────────────────────────────────────────────────────────────────┐
-- │ Folding                                                                │
-- └────────────────────────────────────────────────────────────────────────┘
-- Set the fold method to use an expression
opt.foldmethod = "expr"
-- Set the fold expression to use treesitter
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
-- Set the fold level
opt.foldlevel = 99

-- ┌────────────────────────────────────────────────────────────────────────┐
-- │ Diagnostics, LSP, and Formatting                                       │
-- └────────────────────────────────────────────────────────────────────────┘
-- Disable virtual text for diagnostics
vim.diagnostic.config({ virtual_text = false })
-- Set the log level for LSP to off
vim.lsp.set_log_level("off")
-- Set the recommended style for markdown
vim.g.markdown_recommended_style = 0

-- ┌────────────────────────────────────────────────────────────────────────┐
-- │ Performance                                                            │
-- └────────────────────────────────────────────────────────────────────────┘
-- Set the timeout length for key codes
opt.timeoutlen = 300
-- Set the update time for CursorHold
opt.updatetime = 200
