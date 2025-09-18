return {
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    enabled = false,
    dependencies = {
      "stevearc/dressing.nvim",
      "ibhagwan/fzf-lua",
    },
    opts = {
      -- Default configuration
      hints = { enabled = false },

      provider = "azure",
      -- provider = "openrouter",
      providers = {
        azure = {
          endpoint = "https://andrewmakeapp1123.openai.azure.com/",
          deployment = "o3-mini", -- The deployment name you created in Azure OpenAI Studio
          api_version = "2024-12-01-preview", -- Use your Azure OpenAI API version
          model = "o3-mini", -- Or whatever model you deployed
          -- extra_request_body = {
          --   temperature = 0.7,
          --   max_tokens = 4096,
          -- },
        },
        deepseek = {
          __inherited_from = "openai",
          api_key_name = "DEEPSEEK_API_KEY",
          endpoint = "https://api.deepseek.com",
          model = "deepseek-coder",
        },
        openrouter = {
          __inherited_from = "openai",
          endpoint = "https://openrouter.ai/api/v1",
          model = "openai/o3-mini",
          api_key_name = "OPENROUTER_API_KEY", -- you can define this in your environment
          -- extra_headers = {
          --   ["HTTP-Referer"] = "https://yourdomain.com", -- replace with your actual website or GitHub repo
          --   ["X-Title"] = "MyNeovimAvanteSetup", -- optional, but recommended
          -- },
        },
      },
      -- File selector configuration
      --- @alias FileSelectorProvider "native" | "fzf" | "mini.pick" | "snacks" | "telescope" | string
      file_selector = {
        provider = "fzf", -- Avoid native provider issues
        provider_opts = {},
      },
    },
    build = LazyVim.is_win() and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" or "make",
  },
  -- {
  --   "MeanderingProgrammer/render-markdown.nvim",
  --   optional = true,
  --   ft = function(_, ft)
  --     vim.list_extend(ft, { "Avante" })
  --   end,
  --   opts = function(_, opts)
  --     opts.file_types = vim.list_extend(opts.file_types or {}, { "Avante" })
  --   end,
  -- },
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>a", group = "ai" },
      },
    },
  },
}
