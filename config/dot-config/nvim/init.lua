-- ==============================================================================
-- CORE OPTIONS
-- ==============================================================================
-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- basic editor settings
vim.opt.number = true         -- show absolute line numbers
vim.opt.relativenumber = true -- show relative line numbers
vim.opt.signcolumn = "no"     -- hide sign column
vim.opt.tabstop = 2           -- number of spaces a <tab> counts for
vim.opt.shiftwidth = 2        -- number of spaces to use for each step of indent
vim.opt.expandtab = true      -- use spaces instead of tabs
vim.opt.smartindent = true    -- smarter auto-indentation

-- Clipboard setup
vim.opt.clipboard = "unnamedplus" -- Route yanks/deletes directly to system registers
vim.g.clipboard = "osc52"         -- Stream register text via terminal ANSI (works over SSH)

-- Clean command-line layout options
vim.opt.wildoptions = "pum"            -- Display completion matches in a pop-up menu (pum)
vim.opt.wildmode = "longest:full,full" -- First Tab completes longest match, next Tab cycles choices
vim.opt.cmdheight = 0                  -- Hide command line when not typing a command

-- Netrw (File Explorer) settings
vim.g.netrw_liststyle = 3 -- Set Netrw to tree view by default
vim.g.netrw_banner = 0    -- Hide the bulky top banner text
vim.g.netrw_winsize = 25  -- Sidebar window width percentage for :Lexplore

-- ==============================================================================
-- PACKAGE MANAGEMENT (vim.pack)
-- ==============================================================================
-- Automatically clone and manage plugins using the native git interface
vim.pack.add({ 'https://github.com/ibhagwan/fzf-lua' })
vim.pack.add({ 'https://github.com/stevearc/conform.nvim' })
vim.pack.add({ 'https://github.com/catppuccin/nvim' })

-- ==============================================================================
-- UI & OPTIONS
-- ==============================================================================
-- Enable the experimental decoupled UI streams
require('vim._core.ui2').enable({})

-- Turn on Neovim 0.12's built-in asynchronous completion engine
vim.opt.autocomplete = true

-- Theme
require("catppuccin").setup({
  flavour = "mocha",             -- Target mocha palette options
  transparent_background = true, -- Clear main window backgrounds
  float = {
    transparent = true,          -- HERE: Natively strips backgrounds from floating windows and borders!
  },
})

-- Load the colorscheme natively
vim.cmd.colorscheme("catppuccin")

-- ==============================================================================
-- TRANSPARENCY & HIGHLIGHTS
-- ==============================================================================
-- Force transparency even if colorschemes are loaded later
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
    vim.api.nvim_set_hl(0, "StatusLine", { bg = "none", reverse = false })
    vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "none", reverse = false })
  end,
})

-- Trigger it once manually for the default look immediately on boot
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
vim.api.nvim_set_hl(0, "StatusLine", { bg = "none", reverse = false })
vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "none", reverse = false })

-- ==============================================================================
-- STATUSLINE
-- ==============================================================================
function _G.MyCustomStatusLine()
  -- %f = relative path to the file, %m = modified indicator, %r = read-only indicator
  -- %= pushes everything after it to the far right, keeping it clear of commands
  return " %f %m%r%="
end

vim.opt.statusline = "%!v:lua.MyCustomStatusLine()"
vim.opt.laststatus = 3 -- Single global statusline spanning all windows

-- ==============================================================================
-- KEYMAPS
-- ==============================================================================
-- Toggle Netrw Sidebar explorer
vim.keymap.set("n", "<leader>e", "<cmd>Lexplore<CR>", { desc = "Toggle Netrw Sidebar" })

-- Clear search highlighting with Escape key
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

-- Delete the current buffer using default Vim behavior
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete current buffer" })

-- Window navigation shortcuts
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Fzf-lua (Fuzzy Search Palette) Keymaps
vim.keymap.set("n", "<leader><leader>", "<cmd>FzfLua files<CR>", { desc = "Fuzzy find files" })
vim.keymap.set("n", "<leader>,", "<cmd>FzfLua buffers<CR>", { desc = "Fuzzy find buffers" })
vim.keymap.set("n", "<leader>:", "<cmd>FzfLua commands<CR>", { desc = "Fuzzy find Neovim commands" })

-- Show diagnostic/LSP messages in a floating window
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Line diagnostics" })

-- ==============================================================================
-- Language Servers (LSP)
-- ==============================================================================
-- LSP list - https://microsoft.github.io/language-server-protocol/implementors/servers/
-- LSP list (with file names) - https://github.com/neovim/nvim-lspconfig/tree/master/lsp
vim.lsp.enable({ "bashls", "lua_ls" })


-- ==============================================================================
-- Conform.nvim
-- ==============================================================================
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

-- ==============================================================================
-- LazyGit
-- ==============================================================================
local lg_buf = nil
local lg_win = nil

local function toggle_lazygit()
  -- If window is already open and valid, hide it (Preserve buffer state)
  if lg_win and vim.api.nvim_win_is_valid(lg_win) then
    vim.api.nvim_win_close(lg_win, true)
    lg_win = nil
    return
  end

  -- Ensure buffer exists and is valid, otherwise build a fresh scratch buffer
  if not lg_buf or not vim.api.nvim_buf_is_valid(lg_buf) then
    lg_buf = vim.api.nvim_create_buf(false, true) -- listed = false, scratch = true
  end

  -- Calculate dynamic layout targets (90% width and height of current terminal)
  local width = math.floor(vim.o.columns * 0.99)
  local height = math.floor(vim.o.lines * 0.99)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  -- Open the native floating window container
  lg_win = vim.api.nvim_open_win(lg_buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = "rounded",
  })

  -- If the scratch buffer isn't running a terminal process yet, spawn it
  if vim.bo[lg_buf].buftype ~= "terminal" then
    vim.api.nvim_buf_call(lg_buf, function()
      vim.cmd("terminal lazygit")
    end)

    -- Cleanup: When lazygit exits process, destroy window and buffer trackers
    vim.api.nvim_create_autocmd("TermClose", {
      buffer = lg_buf,
      callback = function()
        if lg_win and vim.api.nvim_win_is_valid(lg_win) then
          vim.api.nvim_win_close(lg_win, true)
        end
        lg_win = nil
        lg_buf = nil
      end,
    })
  end

  -- Instantly focus the terminal input mode
  vim.cmd("startinsert")
end

-- Keymap definition
vim.keymap.set("n", "<leader>gg", toggle_lazygit, { desc = "Toggle LazyGit" })
