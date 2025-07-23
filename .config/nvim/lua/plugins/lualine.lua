return {
  "nvim-lualine/lualine.nvim",
  opts = function()
    local icons = require("lazyvim.config").icons
    return {
      options = {
        always_divide_middle = false,
        globalstatus = true,
        section_separators = "",
        component_separators = "",
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {},
        lualine_c = {
          {
            "filename",
            path = 1,
          },
        },
        lualine_x = {
          {
            "diagnostics",
            always_visible = true,
            sources = { "nvim_lsp" },
            sections = { "error", "warn" },
          },
          { "branch" },
        },
        lualine_y = {},
        lualine_z = {},
      },
    }
  end,
}
