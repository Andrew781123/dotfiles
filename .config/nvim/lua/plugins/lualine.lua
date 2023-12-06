return {
  "nvim-lualine/lualine.nvim",
  opts = function()
    local icons = require("lazyvim.config").icons
    return {
      options = {
        always_divide_middle = false,
        globalstatus = true,
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          { "filename" },
          {
            "diff",
            symbols = {
              added = icons.git.added,
              modified = icons.git.modified,
              removed = icons.git.removed,
            },
            source = function()
              local gitsigns = vim.b.gitsigns_status_dict
              if gitsigns then
                return {
                  added = gitsigns.added,
                  modified = gitsigns.changed,
                  removed = gitsigns.removed,
                }
              end
            end,
          },
        },
        lualine_c = {},
        lualine_x = {},
        lualine_y = {
          {
            "diagnostics",
            always_visible = true,
            sources = { "nvim_lsp" },
            sections = { "error", "warn" },
          },
        },
        lualine_z = { "location" },
      },
    }
  end,
}
