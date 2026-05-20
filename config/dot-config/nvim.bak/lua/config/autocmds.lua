-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    -- Only affects Markdown files
    vim.opt_local.breakindent = true
    vim.opt_local.linebreak = true

    -- The 'shift' actually respects the starting indentation.
    -- If a line has 0 indent (no bullet), it shifts 0.
    -- If it's a bullet, it adds the extra 2 to align under the text.
    vim.opt_local.breakindentopt = "list:2"

    -- This tells Neovim to treat bullets as list markers for wrapping
    vim.opt_local.formatoptions:append("n")
  end,
})
