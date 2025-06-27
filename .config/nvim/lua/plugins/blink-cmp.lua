return {
  "saghen/blink.cmp",
  lazy = true,
  dependencies = { "saghen/blink.compat" },
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
      accept = {
        auto_brackets = {
          enabled = false,
          kind_resolution = {
            enabled = false,
          },
          semantic_token_resolution = {
            enabled = false,
          },
        },
      },
    }
    opts.sources = {
      default = { "avante_commands", "avante_mentions", "avante_files", "lsp", "path", "snippets" },
      compat = { "avante_commands", "avante_mentions", "avante_files", "supermaven" },
      providers = {
        avante_commands = {
          name = "avante_commands",
          module = "blink.compat.source",
          score_offset = 90,
          opts = {},
        },
        avante_files = {
          name = "avante_files",
          module = "blink.compat.source",
          score_offset = 100,
          opts = {},
        },
        avante_mentions = {
          name = "avante_mentions",
          module = "blink.compat.source",
          score_offset = 1000,
          opts = {},
        },
        supermaven = {
          kind = "Supermaven",
          score_offset = 100,
          async = true,
        },
      },
    }
    opts.appearance = {
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
