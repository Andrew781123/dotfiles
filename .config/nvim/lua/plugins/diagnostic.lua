return {
  "rachartier/tiny-inline-diagnostic.nvim",
  event = "VeryLazy",
  priority = 1000,
  config = function()
    require("tiny-inline-diagnostic").setup({
      preset = "minimal",
      signs = {
        left = "", -- Left border character
        right = "", -- Right border character
        diag = "●", -- Diagnostic indicator character
        arrow = "    ", -- Arrow pointing to diagnostic
        up_arrow = "    ", -- Upward arrow for multiline
        vertical = " │", -- Vertical line for multiline
        vertical_end = " └", -- End of vertical line for multiline
      },
      options = {
        show_all_diags_on_cursorline = false,
        multilines = {
          -- Enable multiline diagnostic messages
          enabled = true,

          -- Always show messages on all lines for multiline diagnostics
          always_show = true,

          -- Trim whitespaces from the start/end of each line
          trim_whitespaces = false,

          -- Replace tabs with this many spaces in multiline diagnostics
          tabstop = 4,
        },
      },
    })
    vim.diagnostic.config({ virtual_text = false }) -- Disable default virtual text
    -- for _, type in ipairs({ "Error", "Warn", "Hint", "Info" }) do
    --   local hl = "DiagnosticSign" .. type
    --   vim.fn.sign_define(hl, { text = "", texthl = hl, numhl = "" })
    -- end
  end,
}
