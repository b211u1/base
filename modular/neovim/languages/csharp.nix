# neovim/languages/csharp.nix
{ pkgs }:

{
  name = "csharp";

  plugins = with pkgs.vimPlugins; [
    omnisharp-extended-lsp-nvim
    friendly-snippets  # VSCode-style snippets for C#
  ];

  packages = with pkgs; [
    dotnet-sdk_8
    omnisharp-roslyn
    csharpier
    netcoredbg
  ];

  config = ''
    -- Load C# snippets from friendly-snippets
    require("luasnip.loaders.from_vscode").lazy_load({
      include = { "csharp" }
    })

    -- C# / .NET (OmniSharp)
    local omnisharp_bin = "${pkgs.omnisharp-roslyn}/bin/OmniSharp"

    require("lspconfig").omnisharp.setup({
      capabilities = _G.lsp_capabilities,
      cmd = { omnisharp_bin },

      -- Use omnisharp-extended for better go-to-definition
      handlers = {
        ["textDocument/definition"] = require("omnisharp_extended").definition_handler,
        ["textDocument/references"] = require("omnisharp_extended").references_handler,
        ["textDocument/implementation"] = require("omnisharp_extended").implementation_handler,
      },

      settings = {
        FormattingOptions = {
          EnableEditorConfigSupport = true,
          OrganizeImports = true,
        },
        MsBuild = {
          LoadProjectsOnDemand = false,
        },
        RoslynExtensionsOptions = {
          EnableAnalyzersSupport = true,
          EnableImportCompletion = true,
          AnalyzeOpenDocumentsOnly = false,
        },
      },

      -- Better handling for decompiled sources
      enable_roslyn_analyzers = true,
      organize_imports_on_format = true,
      enable_import_completion = true,
    })

    -- C#-specific settings
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "cs",
      callback = function()
        vim.opt_local.shiftwidth = 4
        vim.opt_local.tabstop = 4

        -- Format with CSharpier on save
        vim.api.nvim_create_autocmd("BufWritePre", {
          buffer = 0,
          callback = function()
            vim.lsp.buf.format({ async = false })
          end,
        })
      end,
    })
  '';
}
