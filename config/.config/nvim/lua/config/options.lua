-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.colorcolumn = "80" -- Set the line length to 80 characters

-- If running locally and not in an ssh session, use the unnamedplus clipboard.
if vim.fn.empty(vim.env.SSH_TTY) == 1 then -- Running locally (no SSH_TTY)
  vim.opt.clipboard = "unnamedplus"
end

-- Always use the current working directory as the root.
vim.g.root_spec = { "cwd" }
