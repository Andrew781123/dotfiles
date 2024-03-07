return {
  "hrsh7th/nvim-cmp",
  opts = function(_, opts)
    local format_kinds = opts.formatting.format
    opts.formatting.format = function(entry, item)
      format_kinds(entry, item) -- add icons
      return require("tailwindcss-colorizer-cmp").formatter(entry, item)
    end

    local cmp = require("cmp")
    opts.completion = {
      completeopt = "menu,menuone,noinsert,noselect",
    }
    -- @todo refactor
    opts.mapping = cmp.mapping.preset.insert({
      ["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
      ["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
      ["<C-u>"] = cmp.mapping.scroll_docs(-4),
      ["<C-d>"] = cmp.mapping.scroll_docs(4),
      ["<C-n>"] = cmp.mapping.complete(),
      ["<C-e>"] = cmp.mapping.abort(),
      ["<CR>"] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
      ["<S-CR>"] = cmp.mapping.confirm({
        behavior = cmp.ConfirmBehavior.Replace,
        select = false,
      }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
      ["<C-CR>"] = function(fallback)
        cmp.abort()
        fallback()
      end,
      -- ["<Tab>"] = cmp.mapping(function(fallback)
      --   if require("copilot.suggestion").is_visible() then
      --     require("copilot.suggestion").accept()
      --   elseif cmp.visible() then
      --     cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
      --   elseif luasnip.expandable() then
      --     luasnip.expand()
      --   elseif has_words_before() then
      --     cmp.complete()
      --   else
      --     fallback()
      --   end
      -- end, {
      --   "i",
      --   "s",
      -- }),
    })
  end,
}
