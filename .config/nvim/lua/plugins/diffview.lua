return {
  "sindrets/diffview.nvim",
  keys = {
    { "<leader>do", ":DiffviewOpen ", desc = "Diffview Open" },
    { "<leader>dc", ":DiffviewClose <CR>", desc = "Diffview Close" },
    { "<leader>dh", ":DiffviewFileHistory % <CR>", desc = "Diffview History (File)" },
    { "<leader>dH", ":DiffviewFileHistory <CR>", desc = "Diffview History (Branch)" },
  },
}
