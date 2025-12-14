-- In progress terminal keyboard customization.
local function new_snacks_terminal()
  require("snacks").terminal.new()
end

return {
  "snacks.nvim",
  opts = {
    terminal = {
      win = {
        keys = {
          nav_a = { "<C-a>", new_snacks_terminal, desc = "Do something cool", expr = true, mode = "t" },
        },
      },
    },
  },
}
