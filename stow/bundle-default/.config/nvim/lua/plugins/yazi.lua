return {
  {
    "mikavilpas/yazi.nvim",
    version = "*", -- use the latest stable version
    event = "VeryLazy",
    dependencies = {
      { "nvim-lua/plenary.nvim", lazy = true },
    },
    keys = {
      {
        "<leader>yy",
        mode = { "n", "v" },
        "<cmd>Yazi<cr>",
        desc = "Yazi jump to file",
      },
      {
        "<leader>yY",
        function()
          require("yazi").yazi(nil, LazyVim.root())
        end,
        desc = "Yazi (Root Dir)",
      },
      {
        "<leader>yc",
        "<cmd>Yazi cwd<cr>",
        desc = "Yazi (cwd)",
      },
    },
    opts = {
      -- if you want to open yazi instead of netrw, see below for more info
      open_for_directories = true,
      keymaps = {
        show_help = "<f1>",
      },
    },
  },
  -- lazy.nvim's `keys` spec cannot set a which-key group, so label <leader>y here.
  {
    "folke/which-key.nvim",
    opts = { spec = { { "<leader>y", group = "Yazi" } } },
  },
}
