return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        sourcekit = {
          mason = false,
          cmd = {
            "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/sourcekit-lsp",
          },
          filetypes = { "swift", "c", "cpp", "objective-c", "objective-cpp" },
          root_dir = require("lspconfig.util").root_pattern("buildServer.json", "Package.swift", ".git"),
        },
      },
      setup = {
        sourcekit = function(_, opts)
          require("lspconfig").sourcekit.setup(opts)
          return true
        end,
      },
    },
  },
}
