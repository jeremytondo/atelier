-- ==============================================================================
-- WhichKey.nvim
-- ==============================================================================
-- Add plugin
vim.pack.add({ "https://github.com/folke/which-key.nvim" })

local Snacks = require("which-key")

-- Plugin config
Snacks.setup({
  preset = "helix"
})
