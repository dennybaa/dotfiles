-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- opts.rocks.enabled = false

local opt = vim.opt

-- OSC 52 is disabled for ssh sessions by default, enable it
--opt.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus" -- Sync with system clipboard
opt.clipboard = "unnamedplus" -- Sync with system clipboard
