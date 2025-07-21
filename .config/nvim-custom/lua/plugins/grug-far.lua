return {
  "MagicDuck/grug-far.nvim",
  cmd = "GrugFar",
  keys = {
    {
      "<leader>sr",
      function()
        local grug = require("grug-far")
        local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")

        -- Get the Git root directory
        -- This command runs 'git rev-parse --show-toplevel' and captures its output.
        local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
        -- Trim any trailing newline or whitespace
        git_root = vim.trim(git_root or "")

        -- Fallback to current working directory if git_root is not found or empty
        local search_path = git_root ~= "" and git_root or vim.fn.getcwd()

        grug.open({
          transient = true,
          prefills = {
            -- Set the default search path to the determined Git root
            paths = search_path,
            filesFilter = ext and ext ~= "" and "*." .. ext or nil,
          },
        })
      end,
      mode = { "n", "v" },
      desc = "Search and Replace",
    },
  },
}
