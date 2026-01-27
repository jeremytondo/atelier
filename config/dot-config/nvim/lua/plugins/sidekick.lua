local is_float = false

local function update_opts(opts, layout, target_key, win_opts)
  if not opts then return end
  opts.layout = layout
  opts[target_key] = vim.tbl_extend("force", opts[target_key] or {}, win_opts)
end

local function toggle_layout()
  is_float = not is_float

  local layout = is_float and "float" or "right"
  local target_key = is_float and "float" or "split"
  local win_opts = is_float and { width = 1, height = 1, border = "rounded" } or { width = 100 }

  -- Update Global Config
  local ok_cfg, Config = pcall(require, "sidekick.config")
  if ok_cfg and Config.cli then
    update_opts(Config.cli.win, layout, target_key, win_opts)
  end

  -- Update Live Instances
  local ok_state, State = pcall(require, "sidekick.cli.state")
  if not ok_state then return end

  for _, state in ipairs(State.get({ name = "gemini" }) or {}) do
    local term = state.terminal
    if term then
      update_opts(term.opts, layout, target_key, win_opts)
      -- Only refresh if the window is currently visible
      if term.win and vim.api.nvim_win_is_valid(term.win) then
        pcall(vim.api.nvim_win_close, term.win, true)
        term.win = nil
        term:focus()
      end
    end
  end
end

return {
  {
    "folke/sidekick.nvim",
    opts = {
      nes = { enabled = false },
      copilot = { status = { enabled = false } },
      cli = {
        win = {
          split = { width = 93 },
        },
      },
    },
    keys = {
      {
        "<leader>ag",
        function() require("sidekick.cli").toggle({ name = "gemini", focus = true }) end,
        desc = "Sidekick Toggle Gemini",
      },
      {
        "<C-,>",
        toggle_layout,
        mode = { "n", "t" },
        desc = "Sidekick Toggle Layout",
      },
    },
  },
}

