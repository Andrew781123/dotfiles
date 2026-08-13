return {
  "andymass/vim-matchup",
  event = { "BufReadPost", "BufNewFile" },
  init = function()
    vim.g.matchup_matchparen_enabled = 0 -- disable highlight
    vim.g.matchup_matchparen_fallback = 0 -- disable fallback highlight
  end,
  ---@type matchup.Config
}
