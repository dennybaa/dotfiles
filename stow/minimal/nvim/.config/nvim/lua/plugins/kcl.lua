return {
  {
    "neovim/nvim-lspconfig",
    init = function()
      -- Make Neovim recognize .k / .kcl files as `kcl` filetype
      vim.filetype.add({
        extension = { k = "kcl", kcl = "kcl" },
      })

      -- Don't even register the server unless the binary exists on $PATH
      if vim.fn.exepath("kcl-language-server") == "" then
        return
      end

      vim.lsp.config("kcl", {
        cmd = { "kcl-language-server" },
        filetypes = { "kcl" },
        root_dir = function(bufnr, on_dir)
          local root = vim.fs.root(bufnr, { "kcl.mod", ".git" })
          if root then
            on_dir(root)
          end
        end,
        single_file_support = false,
      })

      vim.lsp.enable("kcl")
    end,
  },
}
