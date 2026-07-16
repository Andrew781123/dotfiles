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

    -- Remap fzf-lua files toggles to avoid Alt-* conflict with Aerospace
    config.defaults.actions.files["ctrl-h"] = config.defaults.actions.files["alt-h"]
    config.defaults.actions.files["ctrl-i"] = config.defaults.actions.files["alt-i"]
    config.defaults.actions.files["alt-h"] = false
    config.defaults.actions.files["alt-i"] = false

    return {
      ui_select = function(fzf_opts, items)
        return vim.tbl_deep_extend("force", fzf_opts, {
          prompt = " ",
          winopts = {
            fullscreen = false,
            title = " " .. vim.trim((fzf_opts.prompt or "Select"):gsub("%s*:%s*$", "")) .. " ",
            title_pos = "center",
          },
        }, fzf_opts.kind == "codeaction" and {
          winopts = {
            layout = "vertical",
            -- height is number of items minus 15 lines for the preview, with a max of 80% screen height
            height = math.floor(math.min(vim.o.lines * 0.8 - 16, #items + 2) + 0.5) + 16,
            width = 0.5,
            preview = not vim.tbl_isempty(vim.lsp.get_clients({ bufnr = 0, name = "vtsls" })) and {
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
      files = {
        cwd_prompt = false,
        hidden = true,
        fd_opts = "--color=never --type f --hidden --exclude .git",
      },
      git_status = {
        previewer = false, -- Disable preview to avoid assertion error
      },
      grep = {
        rg_opts = "--color=never --column --line-number --no-heading --smart-case --hidden --glob '!.git'",
      },
      winopts = {
        fullscreen = true,
        preview = {
          wrap = true,
          horizontal = "right:50%",
          flip_columns = 100,
        },
      },
    }
  end,
  keys = {
    { "<leader>fF", LazyVim.pick("files", { root = true }), desc = "Find Files (Root Dir)" },
    {
      "<leader>ff",
      function()
        require("fzf-lua").files({ cwd = vim.loop.cwd() })
      end,
      desc = "Find Files (cwd)",
    },
    { "<leader>fS", LazyVim.pick("live_grep"), desc = "Grep (root dir)" },
    { "<leader>fs", LazyVim.pick("live_grep", { root = false }), desc = "Grep (cwd)" },
    { "<leader>rff", "<cmd>FzfLua resume<cr>", desc = "Resume" },
    {
      "<leader>gb",
      function()
        require("fzf-lua").git_branches({
          cmd = "git branch --sort=-committerdate",
        })
      end,
      desc = "Checkout Git branch (sorted by recent commit)",
    },
  },
}
