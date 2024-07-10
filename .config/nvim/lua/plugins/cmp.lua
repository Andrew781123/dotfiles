return {
  "hrsh7th/nvim-cmp",
  opts = function(_, opts)
    local cmp = require("cmp")
    opts.completion = {
      completeopt = "menu,menuone,noinsert,noselect",
    }

    local types = require("cmp.types")
    local function deprioritize_snippet(entry1, entry2)
      if entry1:get_kind() == types.lsp.CompletionItemKind.Snippet then
        return false
      end
      if entry2:get_kind() == types.lsp.CompletionItemKind.Snippet then
        return true
      end
    end

    -- https://www.reddit.com/r/neovim/comments/woih9n/comment/ikbd6iy/
    opts.sorting = {
      priority_weight = 2,
      comparators = {
        deprioritize_snippet,
        -- the rest of the comparators are pretty much the defaults
        cmp.config.compare.offset,
        cmp.config.compare.exact,
        cmp.config.compare.scopes,
        cmp.config.compare.score,
        cmp.config.compare.recently_used,
        cmp.config.compare.locality,
        cmp.config.compare.kind,
        cmp.config.compare.sort_text,
        cmp.config.compare.length,
        cmp.config.compare.order,
      },
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
