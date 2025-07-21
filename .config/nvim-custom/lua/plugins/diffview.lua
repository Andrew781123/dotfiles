return {
  "sindrets/diffview.nvim",
  keys = {
    { "<leader>dvo", ":DiffviewOpen ", desc = "Diffview Open" },
    { "<leader>dvc", ":DiffviewClose <CR>", desc = "Diffview Close" },
    { "<leader>dvh", ":DiffviewFileHistory % <CR>", desc = "Diffview History (File)" },
    { "<leader>dvH", ":DiffviewFileHistory <CR>", desc = "Diffview History (Branch)" },
  },
}
