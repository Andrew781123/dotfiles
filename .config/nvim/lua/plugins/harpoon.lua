return {
  "ThePrimeagen/harpoon",
  lazy = false,
  keys = {
    { "<leader>ha", "<cmd>lua require('harpoon.mark').add_file()<cr>", desc = "Mark file with harpoon" },
    { "<C-e>", "<cmd>lua require('harpoon.ui').toggle_quick_menu()<cr>", desc = "Show harpoon marks" },
    { "<C-n>", "<cmd>lua require('harpoon.ui').nav_next()<cr>", desc = "Go to next harpoon mark" },
    { "<C-p>", "<cmd>lua require('harpoon.ui').nav_prev()<cr>", desc = "Go to previous harpoon mark" },
    { "<leader>hh", "<cmd>lua require('harpoon.ui').nav_file(1)<cr>", desc = "Harpoon first file" },
    { "<leader>hj", "<cmd>lua require('harpoon.ui').nav_file(2)<cr>", desc = "Harpoon second file" },
    { "<leader>hk", "<cmd>lua require('harpoon.ui').nav_file(3)<cr>", desc = "Harpoon third file" },
    { "<leader>hl", "<cmd>lua require('harpoon.ui').nav_file(4)<cr>", desc = "Hapoon fourth file" },
  },
}
