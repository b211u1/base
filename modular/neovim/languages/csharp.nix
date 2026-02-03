# neovim/languages/csharp.nix
{ pkgs, isDarwin ? false }:

{
  name = "csharp";

  plugins = with pkgs.vimPlugins; [
    friendly-snippets  # VSCode-style snippets for C#
  ];

  packages = with pkgs; [
    dotnet-sdk_8
    csharpier
  ] ++ pkgs.lib.optionals (!isDarwin) [
    omnisharp-roslyn  # omnisharp has darwin SDK compatibility issues
    netcoredbg
  ];

  config = ''
    -- Load C# snippets from friendly-snippets
    require("luasnip.loaders.from_vscode").lazy_load({
      include = { "csharp" }
    })

    -- C#-specific settings
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "cs",
      callback = function()
        vim.opt_local.shiftwidth = 4
        vim.opt_local.tabstop = 4
      end,
    })
  '' + (if isDarwin then ''
    -- C# / .NET: OmniSharp not available on Darwin due to SDK compatibility
    -- Use dotnet CLI tools directly for development
  '' else ''
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

    -- Format on save for C#
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*.cs",
      callback = function()
        vim.lsp.buf.format({ async = false })
      end,
    })
  '');
}
