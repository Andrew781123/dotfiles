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

    local function get_lsp_clients(filter)
      filter = filter or {}
      local bufnr = filter.bufnr or 0
      local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
      if filter.name then
        return vim.tbl_filter(function(client)
          return client.name == filter.name
        end, clients)
      end
      return clients
    end

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
            preview = not vim.tbl_isempty(get_lsp_clients({ bufnr = 0, name = "vtsls" })) and {
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
    {
      "<leader>fF",
      function()
        require("fzf-lua").files()
      end,
      desc = "Find Files (Root Dir)",
    },
    {
      "<leader>ff",
      function()
        require("fzf-lua").files({ cmd = "echo .env && fd --type f --hidden", hidden = true })
      end,
      desc = "Find Files (cwd, custom cmd)",
    },
    {
      "<leader>fS",
      function()
        require("fzf-lua").live_grep()
      end,
      desc = "Grep (root dir)",
    },
    {
      "<leader>fs",
      function()
        require("fzf-lua").live_grep({ cwd = vim.fn.getcwd() })
      end,
      desc = "Grep (cwd)",
    },
    { "<leader>rff", "<cmd>FzfLua resume<cr>", desc = "Resume" },
    {
      "<leader>gb",
      function()
        require("fzf-lua").git_branches({
          cmd = "git for-each-ref --sort=-committerdate refs/heads/ --format='%(refname:short)'",
          actions = {
            ["default"] = function(selected)
              vim.cmd("Git checkout " .. selected[1])
            end,
          },
        })
      end,
      desc = "Checkout Git branch (sorted by recent commit)",
    },
  },
}