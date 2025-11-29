-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.colorcolumn = "80" -- Set the line length to 80 characters

-- Setup clipboard based on environment

-- Define OSC 52 clipboard configuration
local osc52_clipboard = {
  name = "OSC 52",
  copy = {
    ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
    ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
  },
  paste = {
    ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
    ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
  },
}

-- Get the value of the DEVCONTAINER environment variable
local is_devcontainer = os.getenv("DEVCONTAINER")

if vim.fn.empty(vim.env.SSH_TTY) == 1 and is_devcontainer ~= "true" then
  -- Running locally (no SSH_TTY and not in devcontainer)
  vim.opt.clipboard = "unnamedplus"
else
  -- Either in SSH session or in devcontainer - use OSC 52
  vim.g.clipboard = osc52_clipboard
end

-- Always use the current working directory as the root.
vim.g.root_spec = { "cwd" }