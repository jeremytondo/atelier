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


local is_ssh = vim.fn.empty(vim.env.SSH_TTY) == 0
local is_devcontainer = os.getenv("DEVCONTAINER") == "true"
local is_zellij = os.getenv("ZELLIJ") ~= nil
local is_tmux = os.getenv("TMUX") ~= nil

if is_ssh or is_devcontainer or is_zellij or is_tmux then
  -- In SSH, Devcontainer, or Zellij session - use the custom OSC 52 provider.
  -- Neovim requires custom providers to be assigned to vim.g.clipboard (global variable).
  vim.g.clipboard = osc52_clipboard
  -- Then, activate the provider by setting the option to either 'unnamed' or 'unnamedplus'.
  -- This tells Neovim to use the clipboard handler defined in vim.g.clipboard.
  vim.opt.clipboard = "unnamedplus"
else
  -- Running locally (no SSH_TTY, not in devcontainer, not in zellij)
  -- Use the default external provider (requires xclip/wl-copy/pbcopy).
  vim.opt.clipboard = "unnamedplus"
  -- We don't need to set vim.g.clipboard here; Neovim uses its default external helper.
end


-- if vim.fn.empty(vim.env.SSH_TTY) == 1 and is_devcontainer ~= "true" then
--   -- Running locally (no SSH_TTY and not in devcontainer)
--   vim.opt.clipboard = "unnamedplus"
-- else
--   -- Either in SSH session or in devcontainer - use OSC 52
--   vim.g.clipboard = osc52_clipboard
-- end

-- Always use the current working directory as the root.
vim.g.root_spec = { "cwd" }
