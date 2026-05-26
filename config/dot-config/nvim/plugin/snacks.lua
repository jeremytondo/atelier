-- ==============================================================================
-- Snacks.nvim
-- ==============================================================================
-- Add plugin
vim.pack.add({ "https://github.com/folke/snacks.nvim" })

local Snacks = require("snacks")

-- Plugin config
Snacks.setup({
  -- Placing 'explorer' at the root level enables it and automatically replaces netrw
  explorer = {
    enabled = true,
    replace_netrw = true, -- Explicitly stated for clarity, though true by default
  },

  picker = {
    enabled = true,
  },

  input = {
    enabled = true,
  },

  lazygit = {
    enabled = true,
    win = {
      width = 0,
      height = 0,
    },

  },

  terminal = {
    enabled = true,
  }
})

-- Keymaps
vim.keymap.set("n", "<leader><leader>", function() Snacks.picker.smart() end, { desc = "Smart Find Files" })
vim.keymap.set("n", "<leader>,", function() Snacks.picker.buffers() end, { desc = "Buffers" })
vim.keymap.set("n", "<leader>e", function() Snacks.explorer() end, { desc = "Toggle Netrw Sidebar" })
vim.keymap.set("n", "<leader>gg", function() Snacks.lazygit() end, { desc = "LazyGit" })
vim.keymap.set({ "n", "i", "t" }, "<C-/>", function() Snacks.terminal.toggle() end, { desc = "Toggle Terminal" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
