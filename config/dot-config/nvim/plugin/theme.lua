-- ==============================================================================
-- THEME
-- ==============================================================================
vim.pack.add({ 'https://github.com/catppuccin/nvim' })

require("catppuccin").setup({
  flavour = "mocha",
  transparent_background = true,
  float = {
    transparent = true,
  },
})

-- Load the colorscheme
vim.cmd.colorscheme("catppuccin")
