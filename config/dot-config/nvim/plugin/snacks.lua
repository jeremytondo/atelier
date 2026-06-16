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
  },

  zen = {
    enabled = true,
    toggles = {
      dim = false,
      git_signs = true,
    },
    show = {
      statusline = true,
    },
    win = {
      width = 100,
    },
  }
})

-- Keymaps
vim.keymap.set("n", "<leader><leader>", function() Snacks.picker.git_files({ untracked = true }) end, { desc = "Find Project Files" })
vim.keymap.set("n", "<leader>,", function() Snacks.picker.buffers() end, { desc = "Buffers" })
vim.keymap.set("n", "<leader>e", function() Snacks.explorer() end, { desc = "Toggle Netrw Sidebar" })
vim.keymap.set("n", "<leader>gg", function() Snacks.lazygit() end, { desc = "LazyGit" })
vim.keymap.set("n", "<leader>z", function() Snacks.zen() end, { desc = "Zen" })
vim.keymap.set({ "n", "i", "t" }, "<C-/>", function() Snacks.terminal.toggle() end, { desc = "Toggle Terminal" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
