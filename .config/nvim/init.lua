-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.lsp.set_log_level("debug")

local should_profile = os.getenv("NVIM_PROFILE")
if should_profile then
  require("profile").instrument_autocmds()
  if should_profile:lower():match("^start") then
    require("profile").start("*")
  else
    require("profile").instrument("*")
  end
end

local function toggle_profile()
  local prof = require("profile")
  if prof.is_recording() then
    prof.stop()
    vim.ui.input({ prompt = "Save profile to:", completion = "file", default = "profile.json" }, function(filename)
      if filename then
        prof.export(filename)
        vim.notify(string.format("Wrote %s", filename))
      end
    end)
  else
    prof.start("*")
  end
end
vim.keymap.set("", "<f1>", toggle_profile)

vim.api.nvim_set_hl(0, "DiffAdd", {
  bg = "#203b28", -- soft green background (similar to GitHub's #e6ffed)
})

vim.api.nvim_set_hl(0, "DiffDelete", {
  bg = "#3b2628", -- soft red background (similar to GitHub's #ffeef0)
})

vim.api.nvim_set_hl(0, "DiffChange", {
  bg = "#2e2f22", -- soft yellowish background (like GitHub's #fff5b1)
})

vim.api.nvim_set_hl(0, "DiffText", {
  bg = "#394b70", -- strong blue highlight for changed lines (similar to GitHub inline diffs)
})

vim.api.nvim_set_hl(0, "DiffAdded", { fg = "#8cc85f", bold = true }) -- green
vim.api.nvim_set_hl(0, "DiffRemoved", { fg = "#ff5d5d", bold = true }) -- red
vim.api.nvim_set_hl(0, "DiffChanged", { fg = "#e3c78a", bold = true }) -- yellow

vim.api.nvim_set_hl(0, "DiffviewWinSeparator", { fg = "#949494" }) -- bright black (gray)
vim.api.nvim_set_hl(0, "DiffviewDiffDelete", { bg = "#3b2628" }) -- same gray

vim.api.nvim_set_hl(0, "DiffviewFilePanelSelected", { fg = "#cf87e8" }) -- purple

vim.api.nvim_set_hl(0, "DiffviewStatusAdded", { fg = "#8cc85f", bold = true })
vim.api.nvim_set_hl(0, "DiffviewStatusUntracked", { fg = "#c6c6c6", bold = true }) -- white
vim.api.nvim_set_hl(0, "DiffviewStatusModified", { fg = "#e3c78a", bold = true }) -- yellow
vim.api.nvim_set_hl(0, "DiffviewStatusRenamed", { fg = "#8cc85f", bold = true }) -- green
vim.api.nvim_set_hl(0, "DiffviewStatusDeleted", { fg = "#ff5d5d", bold = true }) -- red
vim.api.nvim_set_hl(0, "DiffviewStatusIgnored", { fg = "#949494", bold = true }) -- gray

vim.keymap.set("n", "<leader>fp", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
  print("Copied full path: " .. vim.fn.expand("%:p"))
end, { noremap = true, silent = true, desc = "Copy Full Path" })
