-- ==============================================================================
-- Conform.nvim
-- ==============================================================================
vim.pack.add({ 'https://github.com/stevearc/conform.nvim' })

require("conform").setup({
  -- Map specific standalone CLI utilities to your language filetypes
  formatters_by_ft = {
    bash = { "shfmt" },
    sh = { "shfmt" },

    -- We leave out Lua here because lua_ls natively handles formatting.
    -- Conform will see that Lua is empty and drop down to the lsp_format fallback!

  },

  -- Configure the format-on-save trigger
  format_on_save = {
    timeout_ms = 500,        -- Don't stall file-saves for more than half a second
    lsp_format = "fallback", -- CRITICAL: Use pure native LSP formatting if no CLI tool is mapped above
  },
})
