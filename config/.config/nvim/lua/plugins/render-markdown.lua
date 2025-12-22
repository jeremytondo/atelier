return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      heading = {
        -- This removes the full-line colored backgrounds
        backgrounds = {},
        -- This ensures the text stays aligned to the left
        width = "block",
      },
      code = {
        -- Tones down the code block background
        style = "language",
        highlight = "RenderMarkdownCode",
      },
    },
  },
}
