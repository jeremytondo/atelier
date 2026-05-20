return {
  {
    "folke/sidekick.nvim",
    opts = {
      nes = { enabled = false },
      copilot = { status = { enabled = false } },
      cli = {
        win = {
          -- layout = "float",
          -- float = {
          --   width = 1.0,
          --   height = 1.0,
          --   border = "rounded",
          --   title = "",
          -- }
          split = { width = 93 },
        },
        tools = {
          gemini = require("config.utils").has_tag("google3") and {
            cmd = {
              "/google/bin/releases/gemini-cli/tools/gemini",
            },
          } or nil,
        },
      },
    },
    keys = {
      {
        "<leader>ag",
        function()
          require("sidekick.cli").toggle({ name = "gemini", focus = true })
        end,
        desc = "Sidekick Toggle Gemini",
      },
    },
  },
}
