return {
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        markdown = {}, -- This clears the linters for markdown files
      },
    },
  },
}
