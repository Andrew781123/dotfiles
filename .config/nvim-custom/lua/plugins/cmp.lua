return {
  "hrsh7th/nvim-cmp",
  enabled = false,
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
  end,
}
