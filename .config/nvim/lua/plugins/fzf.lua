return {
  "ibhagwan/fzf-lua",
  opts = function(_, opts)
    local fzf = require("fzf-lua")
    local config = fzf.config

    config.defaults.keymap.fzf["ctrl-b"] = "half-page-up"
    config.defaults.keymap.fzf["ctrl-f"] = "half-page-down"
    config.defaults.keymap.builtin["<c-b>"] = "half-page-up"
    config.defaults.keymap.builtin["<c-f>"] = "half-page-down"
    config.defaults.keymap.fzf["ctrl-d"] = "preview-page-down"
    config.defaults.keymap.fzf["ctrl-u"] = "preview-page-up"
    config.defaults.keymap.builtin["<c-d>"] = "preview-page-down"
    config.defaults.keymap.builtin["<c-u>"] = "preview-page-up"

    return {
      ui_select = function(fzf_opts, items)
        return vim.tbl_deep_extend("force", fzf_opts, {
          prompt = " ",
          winopts = {
            title = " " .. vim.trim((fzf_opts.prompt or "Select"):gsub("%s*:%s*$", "")) .. " ",
            title_pos = "center",
          },
        }, fzf_opts.kind == "codeaction" and {
          winopts = {
            layout = "vertical",
            -- height is number of items minus 15 lines for the preview, with a max of 80% screen height
            height = math.floor(math.min(vim.o.lines * 0.8 - 16, #items + 2) + 0.5) + 16,
            width = 0.5,
            preview = not vim.tbl_isempty(LazyVim.lsp.get_clients({ bufnr = 0, name = "vtsls" })) and {
              layout = "vertical",
              vertical = "down:15,border-top",
              hidden = "hidden",
            } or {
              layout = "vertical",
              vertical = "down:15,border-top",
            },
          },
        } or {
          winopts = {
            width = 0.5,
            -- height is number of items, with a max of 80% screen height
            height = math.floor(math.min(vim.o.lines * 0.8, #items + 2) + 0.5),
          },
        })
      end,
    }
  end,
  keys = {
    { "<leader>fF", LazyVim.pick("files"), desc = "Find Files (Root Dir)" },
    { "<leader>ff", LazyVim.pick("files", { root = false }), desc = "Find Files (cwd)" },
    { "<leader>rff", "<cmd>FzfLua resume<cr>", desc = "Resume" },
  },
}
