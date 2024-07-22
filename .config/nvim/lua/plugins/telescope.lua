return {
  "nvim-telescope/telescope.nvim",
  commit = "29fddf76bc3b75224f8a974f15139627ffb435d5",
  opts = function()
    local actions = require("telescope.actions")
    return {
      pickers = {
        find_files = {
          hidden = true,
        },
      },
      defaults = {
        file_ignore_patterns = { "node_modules", "generated", ".git" },
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous, -- move to prev result
            ["<C-j>"] = actions.move_selection_next, -- move to next result
          },
          n = {
            ["q"] = actions.close,
          },
        },
      },
    }
  end,
  keys = function(event)
    local Util = require("lazyvim.util")

    return {
      { "<leader>fS", Util.pick("live_grep"), desc = "Grep (root dir)" },
      { "<leader>fs", Util.pick("live_grep", { root = false }), desc = "Grep (cwd)" },
      { "<leader>rff", "<cmd>Telescope resume<cr>", desc = "Resume" },
      { "<leader>fF", Util.pick("files", { hidden = true }), desc = "Find Files (root dir)" },
      { "<leader>ff", Util.pick("files", { root = false, hidden = true }), desc = "Find Files (cwd)" },
      { "<leader>fw", Util.pick("grep_string", { word_match = "-w" }), desc = "Word (root dir)" },
      { "<leader>fr", Util.pick("lsp_references"), desc = "Find Reference (root dir)" },
      -- git
      { "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "commits" },
      { "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "status" },
      { "<leader>gt", Util.pick("lsp_type_definitions"), desc = "Go to type definition" },
      -- others
      -- Fuzzy find all the symbols in your current document.
      { "<leader>ds", require("telescope.builtin").lsp_document_symbols, desc = "Document Symbols" },
      -- Fuzzy find all the symbols in your current workspace
      { "<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, desc = "Workspace Symbols" },
      {
        "<leader>/",
        function()
          -- You can pass additional configuration to telescope to change theme, layout, etc.
          require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
            winblend = 10,
            previewer = false,
          }))
        end,
        desc = "[/] Fuzzily search in current buffer",
      },
      { "<leader>uC", Util.pick("colorscheme", { enable_preview = true }), desc = "Colorscheme with preview" },
    }
  end,
}
