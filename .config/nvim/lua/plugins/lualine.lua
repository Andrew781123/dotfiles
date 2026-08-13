return {
  "nvim-lualine/lualine.nvim",
  opts = function()
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
          { "branch" },
          {
            "diagnostics",
            -- always_visible = true,
            sources = { "nvim_diagnostic" },
            sections = { "error", "warn" },
          },
          -- "filetype",
        },
        lualine_y = {},
        lualine_z = {},
      },
    }
  end,
}
