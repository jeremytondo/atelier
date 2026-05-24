-- ==============================================================================
-- Gitsigns.nvim
-- ==============================================================================
vim.pack.add({ 'https://github.com/lewis6991/gitsigns.nvim' })

require("gitsigns").setup({
  -- Performance and background tracking configuration
  watch_gitdir = {
    interval = 1000,
    follow_files = true
  },
  attach_to_untracked = true,
  sign_priority = 6,
  update_debounce = 100,

  -- Inline keymap bindings tied specifically to active buffers
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Instantly view a side-by-side diff layout against HEAD
    map('n', '<leader>gd', gs.diffthis, { desc = 'Git Diff This File' })

    -- Jump directly to the next/previous modified code blocks using standard brackets
    map('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, { expr = true, desc = 'Next Git Hunk' })

    map('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, { expr = true, desc = 'Previous Git Hunk' })
  end
})
