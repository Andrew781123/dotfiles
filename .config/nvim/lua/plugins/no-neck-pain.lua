return {
  {
    "shortcuts/no-neck-pain.nvim",
    opts = {
      -- The width of the focused window that will be centered. When the terminal width is less than the `width` option, the side buffers won't be created.
      ---@type integer|"textwidth"|"colorcolumn"
      width = 130,
      ---@type table
      autocmds = {
        -- When `true`, enables the plugin when you start Neovim.
        -- If the main window is  a side tree (e.g. NvimTree) or a dashboard, the command is delayed until it finds a valid window.
        -- The command is cleaned once it has successfuly ran once.
        ---@type boolean
        enableOnVimEnter = true,
      },
      mappings = {
        enabled = true,
      },
      -- Supported integrations that might clash with `no-neck-pain.nvim`'s behavior.
      --
      -- The `position` is used when the plugin scans the layout in order to compute the width that should be added
      -- on each side. For example, if you were supposed to have a padding of 100 columns on each side, but an
      -- integration takes 42, only 58 will be added so your layout is still centered.
      --
      -- If `reopen` is set to `false`, we won't account the width but close the integration when encountered.
      ---@type table
      integrations = {
        -- this is a generic field to hint no-neck-pain that you use a dashboard plugin.
        -- you can find the filetype list of natively supported dashboards here: https://github.com/shortcuts/no-neck-pain.nvim/blob/main/lua/no-neck-pain/util/constants.lua#L82-L85
        -- if a dashboard that you use isn't supported, either set `dashboard.filetype` to the expected file type, or open a pull-request with the edited list.
        dashboard = {
          -- When `true`, debounce will be applied to the init method, leaving time for the dashboard to open.
          enabled = true,
          -- if a dashboard that you use isn't supported, you can use this field to set a matching filetype, also don't hesitate to open a pull-request with the edited list (DASHBOARDS) found in lua/no-neck-pain/util/constants.lua.
          ---@type string[]|nil
          filetypes = {},
        },
      },
    },
  },
}
