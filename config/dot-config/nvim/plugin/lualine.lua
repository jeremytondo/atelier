-- ==============================================================================
-- LUALINE
-- ==============================================================================

vim.pack.add({
  'https://github.com/nvim-tree/nvim-web-devicons',
  'https://github.com/nvim-lualine/lualine.nvim'
})

local LuaLine = require('lualine')

local custom_theme = {
  normal = {
    a = { bg = 'NONE', fg = '#ffffff' }, -- Replace with your editor's dark bg color
    b = { bg = 'NONE', fg = '#ffffff' },
    c = { bg = 'NONE', fg = '#ffffff' },
  },
  insert = {
    a = { bg = 'NONE', fg = '#ffffff' },
    b = { bg = 'NONE', fg = '#ffffff' },
    c = { bg = 'NONE', fg = '#ffffff' },
  },
  -- Repeat for visual, command, etc. if you want them all identical
}

LuaLine.setup {
  options = {
    theme = custom_theme,
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    globalstatus = true,
  },
  sections = {
    lualine_a = {
      {
        'mode',
        fmt = function(str)
          return "⟦ " .. str .. " ⟧"
        end,
        padding = { left = 1, right = 1 }
      }
    },
    lualine_b = { 'branch' },
    lualine_c = { '' },
    lualine_x = {
      {
        'filename',
        path = 1, -- 0: Just filename, 1: Relative path (parent/file.lua), 2: Absolute path
        shorting_target = 40,
        fmt = function(str)
          -- Match the last directory and the filename (e.g., "parent/file.ext")
          -- This regex grabs everything from the second-to-last slash onward
          local short_path = str:match("([^/]+/[^/]+)$")

          -- Fallback just in case the file is in the root directory (no parent slash)
          return short_path or str
        end,
        symbols = {
          modified = ' ●', -- Xcode-style unsaved indicator
          readonly = ' ', -- Clean lock icon for read-only files
          unnamed = '[No Name]',
          newfile = '[New]',
        }
      }
    },
    lualine_y = { 'diff' },
    lualine_z = { 'filetype' },
  },
}
