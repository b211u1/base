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
    -- Nix LSP (nil)
    require("lspconfig").nil_ls.setup({
      capabilities = _G.lsp_capabilities,
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
    })

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
