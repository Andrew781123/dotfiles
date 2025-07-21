return {
  "nvim-pack/nvim-spectre",
  opts = {
    is_insert_mode = true,
  },
  keys = {
    { "<leader>rsr", "<cmd>lua require('spectre').resume_last_search()<CR>", desc = "Repeat last search" },
    {
      "<leader>stu",
      "<cmd>lua require('spectre').toggle_live_update()<CR>",
      desc = "Toggle live update",
    },
    {
      "<leader>sti",
      "<cmd>lua require('spectre').change_options('ignore-case')<CR>",
      desc = "Toggle ignore case",
    },
  },
}
