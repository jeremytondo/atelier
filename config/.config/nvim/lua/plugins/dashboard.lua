return {
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        sections = {
          -- We simply omit the { section = "header" } line here
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
        },
      },
    },
  },
}
