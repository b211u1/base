# neovim/languages/nix.nix
{ pkgs }:

{
  name = "nix";

  plugins = with pkgs.vimPlugins; [ ];

  packages = with pkgs; [
    nil
    nixpkgs-fmt
    nixfmt-rfc-style
    statix
    deadnix
  ];

  config = ''
    -- Nix LSP (nil) using native vim.lsp.config
    vim.lsp.config.nil_ls = {
      cmd = { "nil" },
      filetypes = { "nix" },
      root_markers = { "flake.nix", ".git" },
      settings = {
        ["nil"] = {
          formatting = {
            command = { "nixpkgs-fmt" },
          },
          nix = {
            flake = {
              autoArchive = true,
            },
          },
        },
      },
    }
    vim.lsp.enable("nil_ls")

    -- Nix-specific settings
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "nix",
      callback = function()
        vim.opt_local.shiftwidth = 2
        vim.opt_local.tabstop = 2
      end,
    })
  '';
}
