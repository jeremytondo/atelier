-- ==============================================================================
-- AI
-- ==============================================================================
-- Toggle AI CLI tools.

local state = {}
local last = { name = "codex", cmd = "codex" } -- most recently opened tool

local function valid(b) return b and vim.api.nvim_buf_is_valid(b) end

local function is_ours(buf)
  for _, s in pairs(state) do
    if s.buf == buf then return true end
  end
  return false
end

local function toggle(name, cmd)
  local s = state[name] or {}
  state[name] = s
  last = { name = name, cmd = cmd }

  -- Already showing it -> go back to the previous buffer.
  if valid(s.buf) and vim.api.nvim_get_current_buf() == s.buf then
    vim.cmd("buffer #")
    return
  end

  if valid(s.buf) then
    vim.api.nvim_set_current_buf(s.buf) -- reuse the running session
  else
    s.buf = vim.api.nvim_create_buf(false, false)
    vim.api.nvim_set_current_buf(s.buf)
    vim.fn.jobstart(cmd, { -- launch once
      term = true,
      on_exit = function()
        vim.schedule(function()
          if valid(s.buf) then vim.api.nvim_buf_delete(s.buf, { force = true }) end
          s.buf = nil
        end)
      end,
    })
  end

  vim.cmd("startinsert")
end

-- One chord for everywhere: hide if focused on an AI terminal, else open the last one.
local function smart_toggle()
  if is_ours(vim.api.nvim_get_current_buf()) then
    vim.cmd("buffer #")
  else
    toggle(last.name, last.cmd)
  end
end

-- Direct-to-tool
vim.keymap.set("n", "<leader>ai", function() toggle("codex", "codex") end, { desc = "Codex" })
vim.keymap.set("n", "<leader>ac", function() toggle("claude", "claude") end, { desc = "Claude" })

-- Quick toggle of the last-used AI terminal, from normal or terminal mode
vim.keymap.set({ "n", "t" }, "<C-.>", smart_toggle, { desc = "Toggle AI terminal" })
