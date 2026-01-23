return {
  {
    "folke/sidekick.nvim",
    opts = {
      nes = { enabled = false }, -- This disables Copilot NES features
      copilot = {
        status = { enabled = false },
      },
      cli = {
        win = {
          split = {
            width = 95, -- Increase width from default 80 to 100 columns
          },
        },
      },
    },
    keys = {
      {
        "<leader>ag",
        function() require("sidekick.cli").toggle({ name = "gemini", focus = true }) end,
        desc = "Sidekick Toggle Gemini",
      },
    }
  },
}
