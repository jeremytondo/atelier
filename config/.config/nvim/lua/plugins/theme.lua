return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      flavour = "mocha",
      transparent_background = true,
      custom_highlights = function(colors)
        return {
          -- 1. Force Neo-tree (Explorer) to use the main editor background
          NeoTreeNormal = { bg = colors.base },
          NeoTreeNormalNC = { bg = colors.base }, -- Non-focused window
          -- 2. Force Floating Windows (Snacks Picker / Leader Leader) to use the main editor background
          NormalFloat = { bg = colors.base },
          -- FloatBorder = { bg = colors.base, fg = colors.surface0 }, -- Optional: Make the border blends in

          -- 3. Explicitly target Snacks Picker (just to be safe)
          SnacksPickerNormal = { bg = colors.base },
          SnacksPickerBorder = { bg = colors.base, fg = colors.surface0 },
        }
      end,
    },
  },

  -- Configure LazyVim to use catppuccin as the default colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
