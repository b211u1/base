# neovim/languages/typescript.nix
{ pkgs }:

{
  name = "typescript";

  plugins = with pkgs.vimPlugins; [
    typescript-tools-nvim
    friendly-snippets  # VSCode-style snippets for JS/TS
  ];

  packages = with pkgs; [
    nodejs
    nodePackages.typescript
    nodePackages.typescript-language-server
    nodePackages.prettier
    biome
  ];

  config = ''
    -- Load TypeScript/JavaScript snippets from friendly-snippets
    require("luasnip.loaders.from_vscode").lazy_load({
      include = { "javascript", "typescript", "typescriptreact", "javascriptreact" }
    })

    -- TypeScript Tools (better than vanilla tsserver)
    require("typescript-tools").setup({
      capabilities = _G.lsp_capabilities,
      settings = {
        separate_diagnostic_server = true,
        publish_diagnostic_on = "insert_leave",
        tsserver_file_preferences = {
          includeInlayParameterNameHints = "all",
          includeInlayEnumMemberValueHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayVariableTypeHints = true,
        },
      },
    })

    -- Biome for formatting/linting (if project uses it)
    require("lspconfig").biome.setup({
      capabilities = _G.lsp_capabilities,
      root_dir = require("lspconfig.util").root_pattern("biome.json", "biome.jsonc"),
      single_file_support = false,
    })

    -- TypeScript-specific keymaps
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
      callback = function()
        vim.keymap.set("n", "<leader>to", "<cmd>TSToolsOrganizeImports<cr>", { buffer = true, desc = "Organize imports" })
        vim.keymap.set("n", "<leader>ta", "<cmd>TSToolsAddMissingImports<cr>", { buffer = true, desc = "Add missing imports" })
        vim.keymap.set("n", "<leader>tf", "<cmd>TSToolsFixAll<cr>", { buffer = true, desc = "Fix all" })
        vim.keymap.set("n", "<leader>tr", "<cmd>TSToolsRenameFile<cr>", { buffer = true, desc = "Rename file" })
      end,
    })
  '';
}
