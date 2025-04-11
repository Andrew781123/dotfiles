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
      providers = {
        -- copilot = {
        --   name = "copilot",
        --   module = "blink-cmp-copilot",
        --   score_offset = 100,
        --   async = true,
        --   transform_items = function(_, items)
        --     local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
        --     local kind_idx = #CompletionItemKind + 1
        --     CompletionItemKind[kind_idx] = "Copilot"
        --     for _, item in ipairs(items) do
        --       item.kind = kind_idx
        --     end
        --     return items
        --   end,
        -- },
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
