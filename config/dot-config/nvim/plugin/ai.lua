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

local function current_file_path()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then return nil end

  path = vim.fs.normalize(path)

  local root = vim.fs.root(0, { ".git" }) or vim.fn.getcwd()
  root = vim.fs.normalize(root)

  if path:sub(1, #root + 1) == root .. "/" then
    return path:sub(#root + 2)
  end

  return vim.fn.fnamemodify(path, ":~")
end

local function current_file_context(start_line, end_line)
  local path = current_file_path()
  if not path then return nil end

  if start_line and end_line then
    if start_line > end_line then start_line, end_line = end_line, start_line end
    if start_line == end_line then return string.format("@%s:%d", path, start_line) end
    return string.format("@%s:%d-%d", path, start_line, end_line)
  end

  return "@" .. path
end

local function copy_context_to_clipboard(start_line, end_line)
  start_line = start_line or vim.fn.line(".")
  end_line = end_line or start_line

  local text = current_file_context(start_line, end_line)
  if not text then
    vim.notify("No file context to copy", vim.log.levels.WARN)
    return
  end

  local ok, err = pcall(vim.fn.setreg, "+", text)
  if not ok then
    vim.notify("Could not copy file context: " .. err, vim.log.levels.ERROR)
    return
  end

  vim.fn.setreg('"', text)
  vim.notify("Copied " .. text)
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
    s.job = vim.fn.jobstart(cmd, { -- launch once
      term = true,
      on_exit = function()
        vim.schedule(function()
          if valid(s.buf) then vim.api.nvim_buf_delete(s.buf, { force = true }) end
          s.buf = nil
          s.job = nil
        end)
      end,
    })
  end

  vim.cmd("startinsert")
end

local function ensure_ai_terminal()
  toggle(last.name, last.cmd)
  return state[last.name]
end

local function send_context_to_ai(start_line, end_line)
  local text = current_file_context(start_line, end_line)
  if not text then
    vim.notify("No file context to send", vim.log.levels.WARN)
    return
  end

  local s = ensure_ai_terminal()
  if not s or not s.job then
    vim.notify("AI terminal is not available", vim.log.levels.ERROR)
    return
  end

  vim.fn.chansend(s.job, text)
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
vim.keymap.set("n", "<leader>aj", function() toggle("jetski", "jetski") end, { desc = "JetSki" })
vim.keymap.set("n", "<leader>as", function() send_context_to_ai() end, { desc = "Send file context to AI" })
vim.keymap.set("v", "<leader>as", function()
  send_context_to_ai(vim.fn.line("'<"), vim.fn.line("'>"))
end, { desc = "Send selection context to AI" })

vim.keymap.set("n", "<leader>ag", function() copy_context_to_clipboard() end, { desc = "Copy AI file context" })
vim.keymap.set("v", "<leader>ag", function()
  copy_context_to_clipboard(vim.fn.line("'<"), vim.fn.line("'>"))
end, { desc = "Copy AI file context" })

-- Quick toggle of the last-used AI terminal, from normal or terminal mode
vim.keymap.set({ "n", "t" }, "<C-.>", smart_toggle, { desc = "Toggle AI terminal" })
