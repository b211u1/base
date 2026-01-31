# neovim/languages/typescript.nix
{ pkgs }:

{
  name = "typescript";

  plugins = with pkgs.vimPlugins; [
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

    -- TypeScript LSP using native vim.lsp.config
    vim.lsp.config.ts_ls = {
      cmd = { "typescript-language-server", "--stdio" },
      filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
      root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
      settings = {
        typescript = {
          inlayHints = {
            includeInlayParameterNameHints = "all",
            includeInlayEnumMemberValueHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
            includeInlayVariableTypeHints = true,
          },
        },
        javascript = {
          inlayHints = {
            includeInlayParameterNameHints = "all",
            includeInlayEnumMemberValueHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
            includeInlayVariableTypeHints = true,
          },
        },
      },
    }
    vim.lsp.enable("ts_ls")

    -- Biome for formatting/linting (if project uses it)
    vim.lsp.config.biome = {
      cmd = { "biome", "lsp-proxy" },
      filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "json", "jsonc" },
      root_markers = { "biome.json", "biome.jsonc" },
    }
    -- Only enable biome if config exists (checked at runtime)
    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = { "*.js", "*.jsx", "*.ts", "*.tsx", "*.json" },
      callback = function()
        local root = vim.fs.root(0, { "biome.json", "biome.jsonc" })
        if root then
          vim.lsp.enable("biome")
        end
      end,
      once = true,
    })

    -- TypeScript-specific keymaps
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
      callback = function()
        vim.keymap.set("n", "<leader>to", function()
          vim.lsp.buf.execute_command({ command = "_typescript.organizeImports", arguments = { vim.api.nvim_buf_get_name(0) } })
        end, { buffer = true, desc = "Organize imports" })
      end,
    })
  '';
}
