-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.colorcolumn = "80" -- Set the line length to 80 characters

-- If running locally and not in an ssh session, use the unnamedplus clipboard.
if vim.fn.empty(vim.env.SSH_TTY) == 1 then -- Running locally (no SSH_TTY)
  vim.opt.clipboard = "unnamedplus"
end

-- The following is some attemts to get the clipboard working well via ssh
-- and when an shpool session is running. Turns out most of this is not needed.
-- Looks like this was an issue with the SSH_TTY environment variable getting
-- passed through to the shpool session. I added that to the shpool config
-- and I think things are working now. Leaving this all here for now though in
-- case I need to go back to it.
-- vim.opt.clipboard = "unnamed"
-- vim.opt.clipboard = ""

-- Force OSC 52 so that copy to system clipboard works even inside an shpool session.
-- vim.g.clipboard = {
--   name = "OSC 52",
--   copy = {
--     ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
--     ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
--   },
--   paste = {
--     ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
--     ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
--   },
-- }
