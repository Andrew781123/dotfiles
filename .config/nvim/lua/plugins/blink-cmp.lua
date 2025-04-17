return {
  "saghen/blink.cmp",
  opts = function(_, opts)
    opts.signature = { enabled = true }
    opts.keymap = {
      ["<C-j>"] = { "select_next", "fallback" },
      ["<C-k>"] = { "select_prev", "fallback" },
      ["<C-n>"] = { "show", "show_documentation", "hide_documentation" },
      ["<CR>"] = { "accept", "fallback" },
    }
    opts.completion = {
      menu = {
        auto_show = function(ctx)
          return ctx.mode ~= "cmdline"
        end,
        draw = {
          columns = { { "kind_icon" }, { "label", "label_description", gap = 1 } },
        },
      },
    }
    opts.sources = {
      default = { "lsp", "path" },
      compat = { "supermaven" },
      providers = {
        supermaven = {
          kind = "Supermaven",
          score_offset = 100,
          async = true,
        },
      },
    }

    -- opts.completion = {
    --   debounce_delay = 20,
    -- }

    opts.appearance = {
      -- Blink does not expose its default kind icons so you must copy them all (or set your custom ones) and add Copilot
      kind_icons = {
        Copilot = "",
        Text = "󰉿",
        Method = "󰊕",
        Function = "󰊕",
        Constructor = "󰒓",

        Field = "󰜢",
        Variable = "󰆦",
        Property = "󰖷",

        Class = "󱡠",
        Interface = "󱡠",
        Struct = "󱡠",
        Module = "󰅩",

        Unit = "󰪚",
        Value = "󰦨",
        Enum = "󰦨",
        EnumMember = "󰦨",

        Keyword = "󰻾",
        Constant = "󰏿",

        Snippet = "󱄽",
        Color = "󰏘",
        File = "󰈔",
        Reference = "󰬲",
        Folder = "󰉋",
        Event = "󱐋",
        Operator = "󰪚",
        TypeParameter = "󰬛",
      },
    }
  end,
}
