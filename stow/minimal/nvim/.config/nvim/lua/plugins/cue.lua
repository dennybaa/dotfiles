return {
  -- Add CUE Treesitter parser for syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "cue" })
      end
    end,
  },

  -- Configure CUE Language Server
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        cuelsp = {
          cmd = { "cue", "lsp", "serve" },
          filetypes = { "cue" },
          root_dir = require("lspconfig.util").root_pattern("cue.mod", ".git"),
        },
      },
    },
  },
}
