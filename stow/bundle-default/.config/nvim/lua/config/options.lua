-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- opts.rocks.enabled = false

local opt = vim.opt

-- Disable clipboard for ssh sessions to enable OSC52 (+y) to work
opt.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus"
