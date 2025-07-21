-- Add the configuration directory to the runtime path.
vim.opt.rtp:prepend(vim.fn.expand("<sfile>:p:h"))

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load core configuration
require("core.options")
require("core.keymaps")

-- Load plugin manager
require("config.lazy")
