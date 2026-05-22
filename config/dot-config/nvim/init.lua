-- ==============================================================================
-- CORE OPTIONS
-- ==============================================================================

local opt = vim.opt

-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Enable the experimental UI
require('vim._core.ui2').enable({})

-- basic editor settings
opt.number = true         -- Line numbers
opt.relativenumber = true -- Relative line numbers
opt.cursorline = true     -- Highlight current line
opt.wrap = false          -- Don't wrap lines
opt.scrolloff = 10        -- Keep 10 lines above/below cursor
opt.sidescrolloff = 8     -- Keep 8 columns left/right of cursor

-- Indentation
opt.tabstop = 2        -- Tab width
opt.shiftwidth = 2     -- Indent width
opt.softtabstop = 2    -- Soft tab stop
opt.expandtab = true   -- Use spaces instead of tabs
opt.smartindent = true -- Smart auto-indenting
opt.autoindent = true  -- Copy indent from current line
opt.shiftround = true  -- Round indent

-- Search
opt.ignorecase = true -- Case insensitive search
opt.smartcase = true  -- Case sensitive if uppercase in search
opt.incsearch = true  -- Show matches as you type

-- Visual
opt.termguicolors = true  -- Enable 24-bit colors
opt.signcolumn = "yes"    -- Always show sign column
opt.showmatch = true      -- Highlight matching brackets
opt.matchtime = 2         -- How long to show matching bracket
opt.cmdheight = 0         -- Command line height
opt.showmode = false      -- Don't show mode in command line
opt.pumheight = 10        -- Popup menu height
opt.pumblend = 10         -- Popup menu transparency
opt.winblend = 0          -- Floating window transparency
opt.completeopt = "menu,menuone,noselect"
opt.conceallevel = 2      -- Hide * markup for bold and italic, but not markers with substitutions
opt.confirm = true        -- Confirm to save changes before exiting modified buffer
opt.concealcursor = ""    -- Don't hide cursor line markup
opt.synmaxcol = 300       -- Syntax highlighting limit
opt.ruler = false         -- Disable the default ruler
opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
opt.winminwidth = 5       -- Minimum window width
opt.winborder = "rounded" -- Floating window border

-- File handling
opt.backup = false                            -- Don't create backup files
opt.writebackup = false                       -- Don't create backup before writing
opt.swapfile = false                          -- Don't create swap files
opt.undofile = true                           -- Persistent undo
opt.undolevels = 10000
opt.undodir = vim.fn.expand("~/.vim/undodir") -- Undo directory
opt.updatetime = 300                          -- Faster completion
opt.timeoutlen = 300                          -- Lower than default (1000) to quickly trigger which-key
opt.ttimeoutlen = 0                           -- Key code timeout
opt.autoread = true                           -- Auto reload files changed outside vim
opt.autowrite = true                          -- Auto save

-- Behavior settings
opt.hidden = true                  -- Allow hidden buffers
opt.errorbells = false             -- No error bells
opt.backspace = "indent,eol,start" -- Better backspace behavior
opt.autochdir = false              -- Don't auto change directory
opt.iskeyword:append("-")          -- Treat dash as part of word
opt.path:append("**")              -- include subdirectories in search
opt.selection = "exclusive"        -- Selection behavior
opt.mouse = "a"                    -- Enable mouse support
opt.modifiable = true              -- Allow buffer modifications
opt.encoding = "UTF-8"             -- Set encoding

-- Folding settings
opt.smoothscroll = true
vim.wo.foldmethod = "expr"
opt.foldlevel = 99             -- Start with all folds open
opt.formatoptions = "jcroqlnt" -- Default tcqj
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"

-- Split behavior
opt.splitbelow = true -- Horizontal splits go below
opt.splitright = true -- Vertical splits go right
opt.splitkeep = "screen"

-- Command-line completion
opt.wildmenu = true
opt.wildmode = "noselect,full"
opt.wildignore:append({
  "*.o", "*.obj", "*.pyc", "*.class", "*.jar",
  "*/.git/*", "*/node_modules/*", "*/.DS_Store"
})
opt.wildignorecase = true
opt.wildoptions = "pum,fuzzy"
opt.cmdheight = 0 -- Hide command line when not typing a command

-- Command-line auto show completions
vim.api.nvim_create_autocmd("CmdlineChanged", {
  group = vim.api.nvim_create_augroup("NativeCmdlineAutocompletion", { clear = true }),
  pattern = { ":", "/", "?" }, -- Works for Ex commands and search prompts
  callback = function()
    vim.fn.wildtrigger()
  end,
})

-- Autocomplete
vim.o.autocomplete = true                  -- Globally enables native, pluginless autocomplete
vim.o.autocompletedelay = 100              -- Debounce delay in ms before the menu pops up
opt.complete = ".,w,b,k,o"                 -- Scan current buffer, other windows, and active buffers
opt.completeopt = "menuone,noselect,fuzzy" -- Native fuzzy matching inside the popup!

vim.api.nvim_create_autocmd("FileType", {
  pattern = "snacks_picker_input",
  callback = function()
    vim.bo.autocomplete = false
  end,
})

-- Better diff options
opt.diffopt:append("linematch:60")

-- Performance improvements
opt.redrawtime = 10000
opt.maxmempattern = 20000

-- Clipboard setup
opt.clipboard = "unnamedplus" -- Route yanks/deletes directly to system registers
vim.g.clipboard = "osc52"     -- Stream register text via terminal ANSI (works over SSH)

-- Create undo directory if it doesn't exist
local undodir = vim.fn.expand("~/.vim/undodir")
if vim.fn.isdirectory(undodir) == 0 then
  vim.fn.mkdir(undodir, "p")
end

-- ==============================================================================
-- KEYMAPS
-- ==============================================================================
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete current buffer" })

-- Window navigation shortcuts
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Show diagnostic/LSP messages in a floating window
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Line diagnostics" })

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
-- Language Servers (LSP)
-- ==============================================================================
-- LSP list - https://microsoft.github.io/language-server-protocol/implementors/servers/
-- LSP list (with file names) - https://github.com/neovim/nvim-lspconfig/tree/master/lsp

vim.pack.add({ 'https://github.com/neovim/nvim-lspconfig' })

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },
})

vim.lsp.enable({ "bashls", "lua_ls" })

-- ==============================================================================
-- PACKAGE MANAGEMENT (vim.pack)
-- ==============================================================================
-- Automatically clone and manage plugins using the native git interface
vim.pack.add({ 'https://github.com/stevearc/conform.nvim' })
vim.pack.add({ 'https://github.com/catppuccin/nvim' })
vim.pack.add { { src = "https://github.com/folke/snacks.nvim", name = "snacks.nvim" } }

vim.cmd.packadd("nvim.difftool")

-- ==============================================================================
-- THEME
-- ==============================================================================
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
-- Snacks.nvim
-- ==============================================================================
require("snacks").setup({
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
  }
})

vim.keymap.set("n", "<leader><leader>", function() Snacks.picker.files() end, { desc = "Find Files" })
vim.keymap.set("n", "<leader>e", function() Snacks.explorer() end, { desc = "Toggle Netrw Sidebar" })
vim.keymap.set("n", "<leader>gg", function() Snacks.lazygit() end, { desc = "LazyGit" })

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
