-- ==============================================================================
-- Flash.nvim
-- ==============================================================================
-- Add plugin
vim.pack.add({ "https://github.com/folke/flash.nvim" })
local Flash = require("flash")

-- Plugin config
Flash.setup({})

-- Keymaps
vim.keymap.set({ "n", "x", "o" }, "s", function() Flash.jump() end, { desc = "Flash" })
vim.keymap.set({ "n", "x", "o" }, "S", function() Flash.treesitter() end, { desc = "Flash Treesitter" })
vim.keymap.set("o", "r", function() Flash.remote() end, { desc = "Remote Flash" })
vim.keymap.set({ "o", "x" }, "R", function() Flash.treesitter_search() end, { desc = "Treesitter Search" })
vim.keymap.set("c", "<c-s>", function() Flash.toggle() end, { desc = "Toggle Flash Search" })
