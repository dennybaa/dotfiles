-- Servers LazyVim has no extra for. mason = false: mise/nix own the binaries,
-- so LazyVim enables them straight from PATH.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tombi = { mason = false },
      },
    },
  },
}
