return {
  {
    "NickvanDyke/opencode.nvim",
    dependencies = {
      -- Recommended for `ask()` and `select()`.
      -- Required for `snacks` provider.
      ---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
      "folke/snacks.nvim",
    },
    config = function()
      ---@type opencode.Opts
      vim.g.opencode_opts = {
        -- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition".
      }

      -- NVIM 0.11 Fix: Clamp blink.cmp extmarks to avoid "Invalid end_col" errors
      -- This wraps the documentation highlighter in a pcall to prevent crashes
      local ok, blink_source = pcall(require, "opencode.cmp.blink")
      if ok then
        local old_resolve = blink_source.resolve
        blink_source.resolve = function(self, item, callback)
          old_resolve(self, item, function(resolved_item)
            if resolved_item.documentation and resolved_item.documentation.draw then
              local old_draw = resolved_item.documentation.draw
              resolved_item.documentation.draw = function(opts)
                pcall(old_draw, opts)
              end
            end
            callback(resolved_item)
          end)
        end
      end

      -- Required for `opts.events.reload`.
      vim.o.autoread = true

      -- Keymaps
      vim.keymap.set({ "n", "x" }, "<leader>oa", function()
        require("opencode").ask("@ask @this: ", { submit = true })
      end, { desc = "Ask opencode" })

      vim.keymap.set({ "n", "x" }, "<C-x>", function()
        require("opencode").select()
      end, { desc = "Execute opencode action…" })

      vim.keymap.set({ "n", "x" }, "go", function()
        return require("opencode").operator("@this ")
      end, { expr = true, desc = "Add range to opencode" })

      vim.keymap.set("n", "goo", function()
        return require("opencode").operator("@this ") .. "_"
      end, { expr = true, desc = "Add line to opencode" })

      -- You may want these if you stick with the opinionated "<C-a>" and "<C-x>" above — otherwise consider "<leader>o".
      vim.keymap.set("n", "+", "<C-a>", { desc = "Increment", noremap = true })
      vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement", noremap = true })
    end,
  },
}
