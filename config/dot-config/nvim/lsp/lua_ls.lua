return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT', -- Tells lua_ls that Neovim uses LuaJIT
      },
      diagnostics = {
        globals = { 'vim' }, -- Stops the server from complaining about the global 'vim' variable
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true), -- Makes the server aware of Neovim's internal APIs
      },
    },
  },
}
