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
opt.colorcolumn = "100"   -- Show a guide at column 100
opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
opt.winminwidth = 5       -- Minimum window width
opt.winborder = "rounded" -- Floating window border
opt.laststatus = 3        -- Single global statusline spanning all windows

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

-- Disable native autocomplete in snacks picker
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
local osc52 = require("vim.ui.clipboard.osc52")

local function paste()
  return { vim.split(vim.fn.getreg('"'), "\n"), vim.fn.getregtype('"') }
end

opt.clipboard = "unnamedplus"

vim.g.clipboard = {
  name = "osc52",
  copy = {
    ["+"] = osc52.copy("+"),
    ["*"] = osc52.copy("*"),
  },
  paste = {
    ["+"] = paste,
    ["*"] = paste,
  },
}

-- Create undo directory if it doesn't exist
local undodir = vim.fn.expand("~/.vim/undodir")
if vim.fn.isdirectory(undodir) == 0 then
  vim.fn.mkdir(undodir, "p")
end

-- Undotree
vim.cmd.packadd("nvim.undotree")
vim.keymap.set("n", "<leader>u", "<cmd>Undotree<CR>", { desc = "Toggle undo tree" })

-- ==============================================================================
-- BUFFER NAVIGATION
-- ==============================================================================
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- auto close pairs
map("i", "`", "``<left>")
map("i", '"', '""<left>')
map("i", "(", "()<left>")
map("i", "[", "[]<left>")
map("i", "{", "{}<left>")
map("i", "<", "<><left>")

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
-- Language Servers (LSP)
-- ==============================================================================
vim.pack.add({ 'https://github.com/neovim/nvim-lspconfig' })

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" }, -- Stops "Undefined global: vim"
      },
      workspace = {
        library = { vim.env.VIMRUNTIME }, -- Autocomplete for Neovim APIs
        checkThirdParty = false,          -- Stops annoying prompts
      },
    },
  },
})

vim.lsp.enable({ "bashls", "lua_ls" })

-- ==============================================================================
-- Markdown Viewing & Editing
-- ==============================================================================
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
    vim.opt_local.breakindentopt = "list:-1"
  end,
})
