# neovim/languages/csharp.nix
{ pkgs }:

{
  name = "csharp";

  plugins = with pkgs.vimPlugins; [
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

    -- C# / .NET (OmniSharp) using native vim.lsp.config
    vim.lsp.config.omnisharp = {
      cmd = { "${pkgs.omnisharp-roslyn}/bin/OmniSharp", "--languageserver" },
      filetypes = { "cs" },
      root_markers = { "*.sln", "*.csproj", ".git" },
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
    }
    vim.lsp.enable("omnisharp")

    -- C#-specific settings
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "cs",
      callback = function()
        vim.opt_local.shiftwidth = 4
        vim.opt_local.tabstop = 4
      end,
    })

    -- Format on save for C#
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*.cs",
      callback = function()
        vim.lsp.buf.format({ async = false })
      end,
    })
  '';
}
