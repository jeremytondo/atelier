return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      flavour = "mocha",
      transparent_background = true,
      custom_highlights = function(colors)
        return {
          -- Force Neo-tree (Explorer) to use the main editor background
          NeoTreeNormal = { bg = colors.base },
          NeoTreeNormalNC = { bg = colors.base }, -- Non-focused window
          -- Force Floating Windows (Snacks Picker / Leader Leader) to use the main editor background
          NormalFloat = { bg = colors.base },
          -- FloatBorder = { bg = colors.base, fg = colors.surface0 }, -- Optional: Make the border blends in

          -- Explicitly target Snacks Picker (just to be safe)
          SnacksPickerNormal = { bg = colors.base },
          SnacksPickerBorder = { bg = colors.base, fg = colors.surface0 },

          -- 1. HEADERS: Blues and Purples (Text Only)
          ["@markup.heading.1.markdown"] = { fg = colors.mauve, bold = true }, -- Soft Purple
          ["@markup.heading.2.markdown"] = { fg = colors.blue, bold = true }, -- Standard Blue
          ["@markup.heading.3.markdown"] = { fg = colors.sky, bold = true }, -- Light Blue
          ["@markup.heading.4.markdown"] = { fg = colors.lavender, bold = true }, -- Light Purple-Grey
          ["@markup.heading.5.markdown"] = { fg = colors.sapphire, bold = true }, -- Mid Blue

          -- 2. PLUGIN ICONS: Match the text colors above
          RenderMarkdownH1 = { fg = colors.mauve },
          RenderMarkdownH2 = { fg = colors.blue },
          RenderMarkdownH3 = { fg = colors.sky },
          RenderMarkdownH4 = { fg = colors.lavender },

          -- 3. BOLD & ITALICS: No extra colors, just formatting
          ["@markup.strong.markdown_inline"] = { fg = colors.text, bold = true },
          ["@markup.italic.markdown_inline"] = { fg = colors.text, italic = true },
          RenderMarkdownBold = { fg = colors.text, bold = true },

          -- 4. BULLETS & DASHES: Subtle lavender accents
          RenderMarkdownBullet = { fg = colors.lavender },
          RenderMarkdownDash = { fg = colors.surface2 }, -- Subtle line for '---'

          -- 5. CODE BLOCKS: Subtle surface backgrounds instead of green
          ["@markup.raw.markdown_inline"] = { bg = colors.surface0, fg = colors.subtext0 },
          RenderMarkdownCode = { bg = colors.mantle },
          RenderMarkdownCodeInline = { bg = colors.surface0, fg = colors.subtext0 },

          -- 6. REMOVE ALL BACKGROUND BARS (Safety Override)
          RenderMarkdownH1Bg = { bg = "none" },
          RenderMarkdownH2Bg = { bg = "none" },
          RenderMarkdownH3Bg = { bg = "none" },
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
