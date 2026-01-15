return {
  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        default = { "lazynotes", "lsp", "path", "snippets", "buffer" },
        providers = {
          lazynotes = {
            name = "lazynotes",
            module = "lazynotes.completion",
            score_offset = 100,
          },
        },
      },
    },
  },
}
